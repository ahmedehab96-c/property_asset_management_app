<?php

namespace App\Services;

use Illuminate\Support\Facades\Storage;

class ImageAnalysisService
{
    public function __construct(private readonly GeminiService $gemini) {}

    /**
     * @param  list<string>  $paths  Storage paths on the public disk (or absolute paths)
     * @return array{provider: string, overall: string, findings: list<array<string, mixed>>, meta: array<string, mixed>}
     */
    public function analyze(array $paths, ?array $portfolioContext = null): array
    {
        $localFindings = [];
        $meta = [
            'image_count' => count($paths),
            'images' => [],
        ];

        foreach ($paths as $path) {
            $absolute = $this->resolvePath($path);
            $stats = $this->localImageStats($absolute);
            $meta['images'][] = array_merge(['path' => $path], $stats);
            $localFindings = array_merge($localFindings, $this->findingsFromStats($stats));
        }

        if ($portfolioContext) {
            $localFindings = array_merge(
                $localFindings,
                $this->findingsFromPortfolio($portfolioContext)
            );
        }

        $vision = $this->tryGeminiVision($paths);
        if ($vision !== null) {
            return [
                'provider' => 'gemini_vision',
                'overall' => $vision['overall'] ?? $this->overallFromFindings($localFindings),
                'findings' => $vision['findings'] ?? $localFindings,
                'meta' => array_merge($meta, ['vision' => true]),
            ];
        }

        return [
            'provider' => 'local_heuristics',
            'overall' => $this->overallFromFindings($localFindings),
            'findings' => $localFindings,
            'meta' => array_merge($meta, ['vision' => false]),
        ];
    }

    private function resolvePath(string $path): string
    {
        if (str_starts_with($path, '/') && is_file($path)) {
            return $path;
        }

        $public = Storage::disk('public')->path($path);
        if (is_file($public)) {
            return $public;
        }

        return $path;
    }

    /**
     * @return array{width: ?int, height: ?int, bytes: int, brightness: ?float, sharpness_hint: string}
     */
    private function localImageStats(string $absolute): array
    {
        $bytes = is_file($absolute) ? (int) filesize($absolute) : 0;
        $width = null;
        $height = null;
        $brightness = null;
        $sharpness = 'unknown';

        if (is_file($absolute) && function_exists('getimagesize')) {
            $info = @getimagesize($absolute);
            if (is_array($info)) {
                $width = $info[0] ?? null;
                $height = $info[1] ?? null;
            }
        }

        if (is_file($absolute) && function_exists('imagecreatefromstring')) {
            $blob = @file_get_contents($absolute);
            if ($blob !== false) {
                $img = @imagecreatefromstring($blob);
                if ($img !== false) {
                    $w = imagesx($img);
                    $h = imagesy($img);
                    $samples = 0;
                    $sum = 0.0;
                    $stepX = max(1, (int) floor($w / 20));
                    $stepY = max(1, (int) floor($h / 20));
                    for ($y = 0; $y < $h; $y += $stepY) {
                        for ($x = 0; $x < $w; $x += $stepX) {
                            $rgb = imagecolorat($img, $x, $y);
                            $r = ($rgb >> 16) & 0xFF;
                            $g = ($rgb >> 8) & 0xFF;
                            $b = $rgb & 0xFF;
                            $sum += (0.299 * $r) + (0.587 * $g) + (0.114 * $b);
                            $samples++;
                        }
                    }
                    imagedestroy($img);
                    if ($samples > 0) {
                        $brightness = round($sum / $samples, 1);
                    }
                }
            }
        }

        if ($width && $height) {
            $mp = ($width * $height) / 1_000_000;
            $sharpness = $mp >= 2 ? 'good' : ($mp >= 0.5 ? 'acceptable' : 'low');
        }

        return [
            'width' => $width,
            'height' => $height,
            'bytes' => $bytes,
            'brightness' => $brightness,
            'sharpness_hint' => $sharpness,
        ];
    }

    /**
     * @param  array{width: ?int, height: ?int, bytes: int, brightness: ?float, sharpness_hint: string}  $stats
     * @return list<array<string, mixed>>
     */
    private function findingsFromStats(array $stats): array
    {
        $findings = [];

        if (($stats['bytes'] ?? 0) < 40_000) {
            $findings[] = [
                'title' => 'Low file size',
                'description' => 'Image may be compressed too aggressively for listing quality.',
                'severity' => 'Medium',
                'recommendation' => 'Upload higher-resolution photos (at least 1–2 MP).',
            ];
        }

        if (($stats['sharpness_hint'] ?? '') === 'low') {
            $findings[] = [
                'title' => 'Low resolution',
                'description' => 'Detected resolution looks low for marketing use.',
                'severity' => 'Medium',
                'recommendation' => 'Retake photos with better lighting and higher resolution.',
            ];
        } elseif (($stats['sharpness_hint'] ?? '') === 'good') {
            $findings[] = [
                'title' => 'Resolution quality',
                'description' => 'Image resolution is suitable for listings.',
                'severity' => 'Good',
                'recommendation' => 'Keep consistent framing across rooms and exterior.',
            ];
        }

        $brightness = $stats['brightness'] ?? null;
        if ($brightness !== null) {
            if ($brightness < 55) {
                $findings[] = [
                    'title' => 'Dark exposure',
                    'description' => 'Average brightness is low; rooms may look gloomy.',
                    'severity' => 'Medium',
                    'recommendation' => 'Shoot with more natural light or soft indoor lighting.',
                ];
            } elseif ($brightness > 210) {
                $findings[] = [
                    'title' => 'Overexposed',
                    'description' => 'Image appears very bright; detail may be washed out.',
                    'severity' => 'Low',
                    'recommendation' => 'Avoid direct harsh light and rebalance exposure.',
                ];
            } else {
                $findings[] = [
                    'title' => 'Exposure',
                    'description' => 'Brightness looks balanced for property photos.',
                    'severity' => 'Good',
                    'recommendation' => 'Maintain similar lighting across the set.',
                ];
            }
        }

        return $findings;
    }

    /**
     * @param  array<string, mixed>  $portfolio
     * @return list<array<string, mixed>>
     */
    private function findingsFromPortfolio(array $portfolio): array
    {
        $open = (int) ($portfolio['open_maintenance'] ?? 0);
        $occupancy = (float) ($portfolio['occupancy_rate'] ?? 0);

        return [
            [
                'title' => 'Portfolio maintenance',
                'description' => "Open maintenance requests: {$open}",
                'severity' => $open > 2 ? 'Medium' : 'Good',
                'recommendation' => $open > 0
                    ? 'Resolve open maintenance before publishing listing photos.'
                    : 'No open maintenance blockers detected.',
            ],
            [
                'title' => 'Occupancy context',
                'description' => 'Portfolio occupancy: '.round($occupancy).'%',
                'severity' => $occupancy >= 70 ? 'Good' : 'Medium',
                'recommendation' => $occupancy >= 70
                    ? 'Strong occupancy — focus on premium presentation.'
                    : 'Use photos to highlight unique selling points for vacant units.',
            ],
        ];
    }

    /**
     * @param  list<array<string, mixed>>  $findings
     */
    private function overallFromFindings(array $findings): string
    {
        $hasMediumOrWorse = collect($findings)->contains(
            fn ($f) => in_array($f['severity'] ?? '', ['High', 'Medium'], true)
        );

        return $hasMediumOrWorse
            ? 'Fair condition — improve lighting/resolution before listing'
            : 'Property photo set looks good for listing';
    }

    /**
     * @param  list<string>  $paths
     * @return array{overall: string, findings: list<array<string, mixed>>}|null
     */
    private function tryGeminiVision(array $paths): ?array
    {
        if (! $this->gemini->isConfigured() || $paths === []) {
            return null;
        }

        $images = [];

        foreach (array_slice($paths, 0, 4) as $path) {
            $absolute = $this->resolvePath($path);
            if (! is_file($absolute)) {
                continue;
            }

            $images[] = [
                'mime_type' => mime_content_type($absolute) ?: 'image/jpeg',
                'data' => base64_encode((string) file_get_contents($absolute)),
            ];
        }

        if ($images === []) {
            return null;
        }

        $prompt = 'You are a property photo inspector. Return ONLY JSON with keys overall (string) and findings (array of {title, description, severity, recommendation}). Severity must be one of: High, Medium, Low, Good. Focus on condition, cleanliness, lighting, and listing readiness.';

        $decoded = $this->gemini->analyzeImages($prompt, $images);
        if (! is_array($decoded)) {
            return null;
        }

        return [
            'overall' => (string) ($decoded['overall'] ?? 'Vision analysis completed'),
            'findings' => array_values(array_filter(
                $decoded['findings'] ?? [],
                fn ($finding) => is_array($finding)
            )),
        ];
    }
}
