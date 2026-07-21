import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';

class ImageAnalysisScreen extends ConsumerStatefulWidget {
  const ImageAnalysisScreen({super.key});

  @override
  ConsumerState<ImageAnalysisScreen> createState() => _ImageAnalysisScreenState();
}

class _ImageAnalysisScreenState extends ConsumerState<ImageAnalysisScreen> {
  final ImagePicker _picker = ImagePicker();
  final OwnerApiService _api = OwnerApiService();
  bool _isAnalyzing = false;
  List<Map<String, dynamic>> _analysisResults = [];
  List<String> _uploadedUrls = [];
  String? _overallRating;

  Future<void> _pickAndAnalyze(AppLocalizations l10n, bool isArabic) async {
    final files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResults = [];
      _uploadedUrls = [];
      _overallRating = null;
    });

    final paths = files.map((f) => f.path).toList();
    Map<String, dynamic>? analysis;
    try {
      analysis = await _api.analyzePropertyImages(paths);
    } catch (_) {
      analysis = null;
    }

    List<Map<String, dynamic>> results = const [];
    var overall = l10n.propertyConditionGood;
    List<String> urls = const [];
    var usedServer = false;

    if (analysis != null) {
      usedServer = true;
      overall = (analysis['overall'] ?? overall).toString();
      urls = ((analysis['urls'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList();
      final rawFindings = analysis['findings'];
      if (rawFindings is List) {
        results = rawFindings
            .whereType<Map>()
            .map((f) => {
                  'title': '${f['title'] ?? ''}',
                  'description': '${f['description'] ?? ''}',
                  'severity': _localizeSeverity('${f['severity'] ?? 'Medium'}', isArabic),
                  'recommendation': '${f['recommendation'] ?? ''}',
                })
            .toList();
      }
      final provider = analysis['provider']?.toString() ?? 'server';
      try {
        await _api.submitMobileRequest({
          'type': 'image_analysis',
          'title': 'Property image analysis',
          'description': 'provider=$provider; images=${files.length}',
          'attachments': urls,
          'payload': analysis,
        });
      } catch (_) {}
    } else {
      // Offline fallback: portfolio heuristics only.
      Map<String, dynamic>? analytics;
      try {
        analytics = await _api.getAnalyticsOverview();
      } catch (_) {}
      final openMaintenance =
          (analytics?['open_maintenance'] as num?)?.toInt() ?? 0;
      final occupancy =
          (analytics?['occupancy_rate'] as num?)?.toDouble() ?? 0;
      results = _buildResults(
        l10n: l10n,
        isArabic: isArabic,
        imageCount: files.length,
        uploaded: false,
        openMaintenance: openMaintenance,
        occupancy: occupancy,
      );
      overall = openMaintenance > 2
          ? (isArabic
              ? 'حالة متوسطة — راقب طلبات الصيانة المفتوحة'
              : 'Fair condition — watch open maintenance')
          : occupancy >= 70
              ? l10n.propertyConditionGood
              : (isArabic
                  ? 'حالة مقبولة مع فرص تحسين'
                  : 'Acceptable with room to improve');
    }

    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _uploadedUrls = urls;
      _analysisResults = results;
      _overallRating = overall;
    });

    if (!usedServer && mounted) {
      UiFeedback.showInfo(
        context,
        isArabic
            ? 'تعذّر التحليل على الخادم — عُرض تقييم محفظة محلي'
            : 'Server analysis unavailable — showing local portfolio estimate',
      );
    }
  }

  String _localizeSeverity(String severity, bool isArabic) {
    switch (severity) {
      case 'High':
        return isArabic ? 'عالي' : 'High';
      case 'Medium':
        return isArabic ? 'متوسط' : 'Medium';
      case 'Low':
        return isArabic ? 'منخفض' : 'Low';
      case 'Good':
        return isArabic ? 'جيد' : 'Good';
      default:
        return severity;
    }
  }

  List<Map<String, dynamic>> _buildResults({
    required AppLocalizations l10n,
    required bool isArabic,
    required int imageCount,
    required bool uploaded,
    required int openMaintenance,
    required double occupancy,
  }) {
    return [
      {
        'title': isArabic ? 'جودة الصور' : 'Image quality',
        'description': isArabic
            ? 'تم استلام $imageCount صورة${uploaded ? ' ورفعها للخادم' : ''}'
            : 'Received $imageCount image(s)${uploaded ? ' and uploaded' : ''}',
        'severity': uploaded
            ? (isArabic ? 'جيد' : 'Good')
            : (isArabic ? 'متوسط' : 'Medium'),
        'recommendation': isArabic
            ? 'ارفع صوراً واضحة للواجهات والداخل لتحسين التقييم'
            : 'Upload clear exterior/interior shots for better assessment',
      },
      {
        'title': isArabic ? 'الصيانة المرتبطة بالمحفظة' : 'Portfolio maintenance',
        'description': isArabic
            ? 'طلبات صيانة مفتوحة حالياً: $openMaintenance'
            : 'Open maintenance requests: $openMaintenance',
        'severity': openMaintenance > 2
            ? (isArabic ? 'متوسط' : 'Medium')
            : (isArabic ? 'جيد' : 'Good'),
        'recommendation': openMaintenance > 0
            ? (isArabic
                ? 'راجع طلبات الصيانة قبل تسويق الوحدة'
                : 'Review open maintenance before listing')
            : (isArabic
                ? 'لا توجد صيانة مفتوحة — جاهز للعرض'
                : 'No open maintenance — ready to present'),
      },
      {
        'title': l10n.occupancyRate,
        'description': isArabic
            ? 'معدل إشغال المحفظة: ${occupancy.toStringAsFixed(0)}%'
            : 'Portfolio occupancy: ${occupancy.toStringAsFixed(0)}%',
        'severity': occupancy >= 70
            ? (isArabic ? 'جيد' : 'Good')
            : (isArabic ? 'متوسط' : 'Medium'),
        'recommendation': occupancy >= 70
            ? (isArabic
                ? 'الإشغال قوي — ركّز على جودة العرض البصري'
                : 'Strong occupancy — focus on visual presentation')
            : (isArabic
                ? 'حسّن صور الوحدة لجذب مستأجرين جدد'
                : 'Improve unit photos to attract new tenants'),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.watch(isArabicProvider);
    final theme = Theme.of(context);
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: context.estate.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.smartImageAnalysis,
          style: TextStyle(color: context.estate.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.estate.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: AppColors.accentGold,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.uploadPropertyImage,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.estate.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.uploadMultipleImagesHint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.estate.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isAnalyzing
                            ? null
                            : () => _pickAndAnalyze(l10n, isArabic),
                        icon: const Icon(Icons.upload_file),
                        label: Text(l10n.chooseImage),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentGold,
                          side: const BorderSide(
                            color: AppColors.accentGold,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (_uploadedUrls.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        isArabic
                            ? 'تم رفع ${_uploadedUrls.length} صورة'
                            : '${_uploadedUrls.length} image(s) uploaded',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_isAnalyzing)
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.analyzing,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: context.estate.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_analysisResults.isNotEmpty && !_isAnalyzing) ...[
                Text(
                  l10n.analysisResults,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.estate.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ..._analysisResults.map(
                  (result) => _AnalysisResultCard(
                    title: result['title'],
                    description: result['description'],
                    severity: result['severity'],
                    recommendation: result['recommendation'],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.estate.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.assessment,
                            color: AppColors.accentGold,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.overallRating,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.estate.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _overallRating ?? l10n.propertyConditionGood,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalysisResultCard extends StatelessWidget {
  final String title;
  final String description;
  final String severity;
  final String recommendation;

  const _AnalysisResultCard({
    required this.title,
    required this.description,
    required this.severity,
    required this.recommendation,
  });

  Color _getSeverityColor() {
    switch (severity) {
      case 'عالي':
      case 'High':
        return Colors.red;
      case 'متوسط':
      case 'Medium':
        return Colors.orange;
      case 'منخفض':
      case 'Low':
        return Colors.yellow;
      case 'جيد':
      case 'Good':
        return Colors.green;
      default:
        return AppColors.grey;
    }
  }

  IconData _getSeverityIcon() {
    switch (severity) {
      case 'عالي':
      case 'High':
        return Icons.warning;
      case 'متوسط':
      case 'Medium':
        return Icons.info;
      case 'منخفض':
      case 'Low':
        return Icons.check_circle_outline;
      case 'جيد':
      case 'Good':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = _getSeverityColor();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.estate.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getSeverityIcon(),
                  color: severityColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.estate.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: severityColor, width: 1),
                ),
                child: Text(
                  severity,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: severityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.estate.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.accentGold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.estate.textPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
