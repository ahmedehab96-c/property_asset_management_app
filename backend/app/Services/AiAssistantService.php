<?php

namespace App\Services;

class AiAssistantService
{
    public function __construct(
        private readonly GeminiService $gemini,
        private readonly PortfolioContextService $portfolio,
    ) {}

    /**
     * @param  list<array{role: string, content: string}>  $history
     * @return array{reply: string, provider: string, configured: bool}
     */
    public function chat(
        string $message,
        array $history = [],
        string $locale = 'ar',
        bool $includePortfolio = true,
    ): array {
        $configured = $this->gemini->isConfigured();
        $systemPrompt = $this->systemPrompt($locale, $includePortfolio);

        if ($configured) {
            $reply = $this->gemini->chat($systemPrompt, $message, $history);
            if ($reply !== null) {
                return [
                    'reply' => $reply,
                    'provider' => 'gemini',
                    'configured' => true,
                ];
            }
        }

        return [
            'reply' => $this->fallbackReply($message, $locale),
            'provider' => 'fallback',
            'configured' => $configured,
        ];
    }

    /**
     * @param  array<string, mixed>  $portfolio
     * @return array<string, mixed>
     */
    public function marketAnalysis(string $city, string $propertyType, array $portfolio, string $locale = 'ar'): array
    {
        $prompt = $locale === 'ar'
            ? "حلّل سوق الإيجار للمدينة: {$city} ونوع العقار: {$propertyType}. استخدم بيانات المحفظة المرفقة. أعد JSON فقط بالمفاتيح: avg_rent (number), min_rent (number), max_rent (number), monthly_change (string), yearly_change (string), occupancy_rate (number), recommendations (array of strings)."
            : "Analyze the rental market for city: {$city}, property type: {$propertyType}. Use the attached portfolio data. Return JSON only with keys: avg_rent (number), min_rent (number), max_rent (number), monthly_change (string), yearly_change (string), occupancy_rate (number), recommendations (array of strings).";

        $userPrompt = $prompt."\n\nPortfolio:\n".json_encode($portfolio, JSON_UNESCAPED_UNICODE);

        $system = $locale === 'ar'
            ? 'أنت محلل سوق عقاري في الإمارات والخليج. أجب بJSON صالح فقط.'
            : 'You are a GCC real-estate market analyst. Reply with valid JSON only.';

        $result = $this->gemini->jsonPrompt($system, $userPrompt);

        if ($result !== null) {
            return array_merge($result, ['provider' => 'gemini']);
        }

        return $this->fallbackMarketAnalysis($portfolio, $locale);
    }

    /**
     * @param  array<string, mixed>  $input
     * @param  array<string, mixed>  $portfolio
     * @return array<string, mixed>
     */
    public function tenantAnalysis(array $input, array $portfolio, string $locale = 'ar'): array
    {
        $system = $locale === 'ar'
            ? 'أنت مستشار مخاطر مستأجرين. أعد JSON فقط بالمفاتيح: risk_score (0-100), financial_capacity (string), employment_stability (string), rental_history (string), recommendation (string), summary (string).'
            : 'You are a tenant risk advisor. Return JSON only with keys: risk_score (0-100), financial_capacity (string), employment_stability (string), rental_history (string), recommendation (string), summary (string).';

        $userPrompt = ($locale === 'ar' ? 'بيانات المستأجر:' : 'Tenant data:')
            ."\n".json_encode($input, JSON_UNESCAPED_UNICODE)
            ."\n\n".($locale === 'ar' ? 'المحفظة:' : 'Portfolio:')
            ."\n".json_encode($portfolio, JSON_UNESCAPED_UNICODE);

        $result = $this->gemini->jsonPrompt($system, $userPrompt);

        if ($result !== null) {
            return array_merge($result, ['provider' => 'gemini']);
        }

        return $this->fallbackTenantAnalysis($input, $portfolio, $locale);
    }

    /**
     * @param  array<string, mixed>  $portfolio
     * @return array<string, mixed>
     */
    public function financialPredictions(string $period, array $portfolio, string $locale = 'ar'): array
    {
        $months = match ($period) {
            'six' => 6,
            'twelve' => 12,
            default => 3,
        };

        $system = $locale === 'ar'
            ? 'أنت محلل مالي لمحافظ عقارية. أعد JSON فقط بالمفاتيح: revenue_forecast (array of {month, amount, trend}), expense_forecast (array of {label, amount, trend}), net_profit (number), summary (string). المبالغ بالدرهم.'
            : 'You are a real-estate portfolio financial analyst. Return JSON only with keys: revenue_forecast (array of {month, amount, trend}), expense_forecast (array of {label, amount, trend}), net_profit (number), summary (string). Amounts in AED.';

        $userPrompt = ($locale === 'ar' ? "توقعات لـ {$months} أشهر قادمة.\n\nالمحفظة:\n" : "Forecast for next {$months} months.\n\nPortfolio:\n")
            .json_encode($portfolio, JSON_UNESCAPED_UNICODE);

        $result = $this->gemini->jsonPrompt($system, $userPrompt);

        if ($result !== null) {
            return array_merge($result, ['provider' => 'gemini']);
        }

        return $this->fallbackFinancialPredictions($portfolio, $months, $locale);
    }

    /**
     * @return array{configured: bool, provider: string}
     */
    public function status(): array
    {
        return [
            'configured' => $this->gemini->isConfigured(),
            'provider' => 'gemini',
        ];
    }

    private function systemPrompt(string $locale, bool $includePortfolio): string
    {
        $base = $locale === 'ar'
            ? 'أنت مساعد ذكي متخصص في إدارة العقارات في الإمارات والخليج. أجب بالعربية بشكل واضح ومفيد وعملي.'
            : 'You are a smart assistant specialized in property management in the UAE and GCC. Reply clearly and helpfully in English.';

        if (! $includePortfolio) {
            return $base;
        }

        $portfolio = $this->portfolio->build();
        $label = $locale === 'ar' ? 'بيانات محفظة المستخدم:' : 'User portfolio data:';

        return $base."\n\n{$label}\n".json_encode($portfolio, JSON_UNESCAPED_UNICODE);
    }

    private function fallbackReply(string $message, string $locale): string
    {
        $normalized = mb_strtolower($message);

        if ($this->containsAny($normalized, ['تقدير', 'estimate', 'valuation', 'سعر', 'price'])) {
            return $locale === 'ar'
                ? 'يمكنني مساعدتك في تقدير سعر الإيجار. أخبرني بموقع العقار ونوعه ومساحته وحالته.'
                : 'I can help estimate rent. Share the property location, type, size, and condition.';
        }

        if ($this->containsAny($normalized, ['عقد', 'إيجار', 'contract', 'rent', 'lease'])) {
            return $locale === 'ar'
                ? 'يمكنني مساعدتك في صياغة عقد إيجار. زوّدني باسم العقار والمستأجر وقيمة الإيجار ومدة العقد.'
                : 'I can help draft a rental contract. Provide property name, tenant, rent amount, and lease term.';
        }

        if ($this->containsAny($normalized, ['إعلان', 'ad', 'advert', 'listing'])) {
            return $locale === 'ar'
                ? 'يمكنني كتابة إعلان عقاري. أخبرني بنوع العقار والموقع والمساحة والمميزات والسعر.'
                : 'I can write a property listing. Share type, location, size, features, and price.';
        }

        if ($this->containsAny($normalized, ['تحليل', 'أداء', 'analysis', 'analyze', 'performance'])) {
            return $locale === 'ar'
                ? 'يمكنني تحليل أداء محفظتك. فعّل مفتاح Gemini على الخادم للحصول على تحليل ذكي مباشر من بياناتك.'
                : 'I can analyze your portfolio performance. Enable Gemini on the server for live AI analysis from your data.';
        }

        return $locale === 'ar'
            ? 'مرحباً! أنا مساعدك لإدارة العقارات. فعّل GEMINI_API_KEY على الخادم للردود الذكية، أو اسألني عن العقود والإعلانات والصيانة.'
            : 'Hello! I am your property assistant. Set GEMINI_API_KEY on the server for smart replies, or ask about contracts, listings, and maintenance.';
    }

    /**
     * @param  array<string, mixed>  $portfolio
     * @return array<string, mixed>
     */
    private function fallbackMarketAnalysis(array $portfolio, string $locale): array
    {
        $avg = (float) ($portfolio['monthly_revenue'] ?? 8500);
        if ($avg <= 0) {
            $avg = 8500;
        }

        return [
            'provider' => 'fallback',
            'avg_rent' => $avg,
            'min_rent' => round($avg * 0.6),
            'max_rent' => round($avg * 1.4),
            'monthly_change' => '+3.2%',
            'yearly_change' => '+12.5%',
            'occupancy_rate' => $portfolio['occupancy_rate'] ?? 85,
            'recommendations' => $locale === 'ar'
                ? ['راجع أسعار الإيجار في المنطقة', 'حسّن التسويق للوحدات الشاغرة']
                : ['Review rent prices in the area', 'Improve marketing for vacant units'],
        ];
    }

    /**
     * @param  array<string, mixed>  $input
     * @param  array<string, mixed>  $portfolio
     * @return array<string, mixed>
     */
    private function fallbackTenantAnalysis(array $input, array $portfolio, string $locale): array
    {
        $income = (float) ($input['income'] ?? 0);
        $avgRent = (float) ($portfolio['monthly_revenue'] ?? 0) / max(1, (int) ($portfolio['properties_count'] ?? 1));
        $ratio = $avgRent > 0 ? $income / $avgRent : 1;
        $riskScore = match (true) {
            $ratio >= 3 => 85,
            $ratio >= 2 => 70,
            $ratio >= 1.5 => 55,
            default => 40,
        };

        return [
            'provider' => 'fallback',
            'risk_score' => $riskScore,
            'financial_capacity' => $locale === 'ar' ? 'تقدير محلي' : 'Local estimate',
            'employment_stability' => (string) ($input['employment'] ?? ''),
            'rental_history' => ($input['has_previous_rentals'] ?? false)
                ? ($locale === 'ar' ? 'سجل إيجار سابق' : 'Previous rental history')
                : ($locale === 'ar' ? 'لا يوجد سجل سابق' : 'No prior rental history'),
            'recommendation' => $riskScore >= 70
                ? ($locale === 'ar' ? 'مخاطر منخفضة — يمكن المتابعة' : 'Low risk — proceed')
                : ($locale === 'ar' ? 'مخاطر متوسطة — راجع الضمانات' : 'Medium risk — review guarantees'),
            'summary' => $locale === 'ar'
                ? 'تحليل محلي — فعّل Gemini على الخادم لتحليل أدق.'
                : 'Local analysis — enable Gemini on the server for deeper insights.',
        ];
    }

    /**
     * @param  array<string, mixed>  $portfolio
     * @return array<string, mixed>
     */
    private function fallbackFinancialPredictions(array $portfolio, int $months, string $locale): array
    {
        $base = (float) ($portfolio['monthly_revenue'] ?? 83000);
        $revenueForecast = [];
        for ($i = 1; $i <= $months; $i++) {
            $amount = round($base * (1 + ($i * 0.008)));
            $revenueForecast[] = [
                'month' => $i,
                'amount' => $amount,
                'trend' => '+'.round(2 + $i * 0.2, 1).'%',
            ];
        }

        return [
            'provider' => 'fallback',
            'revenue_forecast' => $revenueForecast,
            'expense_forecast' => [
                ['label' => $locale === 'ar' ? 'صيانة' : 'Maintenance', 'amount' => 15000, 'trend' => $locale === 'ar' ? 'مستقر' : 'Stable'],
                ['label' => $locale === 'ar' ? 'رسوم' : 'Fees', 'amount' => 8000, 'trend' => $locale === 'ar' ? 'مستقر' : 'Stable'],
            ],
            'net_profit' => collect($revenueForecast)->sum('amount') - 23000 * $months,
            'summary' => $locale === 'ar'
                ? 'توقعات محلية — فعّل Gemini على الخادم لتوقعات أدق.'
                : 'Local forecast — enable Gemini on the server for smarter predictions.',
        ];
    }

    /**
     * @param  list<string>  $keywords
     */
    private function containsAny(string $message, array $keywords): bool
    {
        foreach ($keywords as $keyword) {
            if (str_contains($message, mb_strtolower($keyword))) {
                return true;
            }
        }

        return false;
    }
}
