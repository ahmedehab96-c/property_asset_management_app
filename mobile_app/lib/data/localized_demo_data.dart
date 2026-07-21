import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// بيانات تجريبية ثنائية اللغة للشاشات الداخلية.
class LocalizedDemoData {
  const LocalizedDemoData({required this.l10n, required this.isArabic});

  final AppLocalizations l10n;
  final bool isArabic;

  String _t(String ar, String en) => isArabic ? ar : en;

  static const filterAll = 'all';
  static const filterPaid = 'paid';
  static const filterPending = 'pending';
  static const filterRented = 'rented';
  static const filterVacant = 'vacant';

  static const empGov = 'gov';
  static const empPrivate = 'private';
  static const empFreelance = 'freelance';
  static const empRetired = 'retired';

  List<Map<String, String>> employmentOptions() => [
        {'key': empGov, 'label': l10n.governmentEmployee},
        {'key': empPrivate, 'label': l10n.privateEmployee},
        {'key': empFreelance, 'label': l10n.freelancer},
        {'key': empRetired, 'label': l10n.retired},
      ];

  List<Map<String, dynamic>> payments() => [
        {
          'id': 1,
          'property': _t('فيلا الياسمين', 'Jasmine Villa'),
          'tenant': _t('عبد الله العامري', 'Abdullah Al Amri'),
          'amount': '8,000',
          'date': '01/07/2024',
          'statusType': filterPaid,
          'type': l10n.monthlyRent,
        },
        {
          'id': 2,
          'property': _t('شقة الرياض', 'Riyadh Apartment'),
          'tenant': _t('محمد أحمد', 'Mohammed Ahmed'),
          'amount': '25,000',
          'date': '15/07/2024',
          'statusType': filterPending,
          'type': l10n.monthlyRent,
        },
        {
          'id': 3,
          'property': _t('مكتب جدة', 'Jeddah Office'),
          'tenant': _t('علي حسن', 'Ali Hassan'),
          'amount': '50,000',
          'date': '05/07/2024',
          'statusType': filterPaid,
          'type': l10n.monthlyRent,
        },
      ];

  List<Map<String, dynamic>> mapProperties() => [
        {
          'id': 1,
          'name': _t('فيلا الياسمين', 'Jasmine Villa'),
          'location': _t('الرياض، حي الياسمين', 'Riyadh, Al Yasmin'),
          'latitude': 24.7136,
          'longitude': 46.6753,
          'statusType': filterRented,
          'statusColor': AppColors.accentGold,
          'rentAmount': '8,000 ${l10n.aed}',
        },
        {
          'id': 2,
          'name': _t('شقة الرياض', 'Riyadh Apartment'),
          'location': _t('الرياض، حي العليا', 'Riyadh, Al Olaya'),
          'latitude': 24.6877,
          'longitude': 46.6844,
          'statusType': filterVacant,
          'statusColor': Colors.green,
          'rentAmount': '5,500 ${l10n.aed}',
        },
        {
          'id': 3,
          'name': _t('مكتب النخيل', 'Palm Office'),
          'location': _t('الرياض، حي النخيل', 'Riyadh, Al Nakheel'),
          'latitude': 24.7136,
          'longitude': 46.6753,
          'statusType': filterRented,
          'statusColor': AppColors.accentGold,
          'rentAmount': '12,000 ${l10n.aed}',
        },
      ];

  String paymentStatusLabel(String statusType) {
    switch (statusType) {
      case filterPaid:
        return l10n.paidStatus;
      case filterPending:
        return l10n.pending;
      default:
        return statusType;
    }
  }

  String propertyStatusLabel(String statusType) {
    switch (statusType) {
      case filterRented:
        return l10n.rented;
      case filterVacant:
        return l10n.vacant;
      default:
        return statusType;
    }
  }

  List<Map<String, String>> reportTypes() => [
        {'key': 'revenue', 'label': l10n.revenueExpenseReport},
        {'key': 'rented', 'label': l10n.rentedPropertiesReport},
        {'key': 'projects', 'label': l10n.constructionProjectsReport},
      ];

  static const reportRevenue = 'revenue';
  static const reportRented = 'rented';
  static const reportProjects = 'projects';

  String normalizeReportType(String type) {
    switch (type) {
      case 'income':
        return reportRevenue;
      case 'properties':
        return reportRented;
      default:
        return type;
    }
  }

  String reportDetailTitle(String typeKey) {
    switch (normalizeReportType(typeKey)) {
      case reportRevenue:
        return l10n.revenueExpenseReport;
      case reportRented:
        return l10n.rentedPropertiesReport;
      case reportProjects:
        return l10n.constructionProjectsReport;
      default:
        return '';
    }
  }

  String reportDetailSubtitle(String typeKey) {
    switch (normalizeReportType(typeKey)) {
      case reportRevenue:
        return l10n.revenueExpenseSubtitle;
      case reportRented:
        return l10n.rentedPropertiesSubtitle;
      case reportProjects:
        return l10n.constructionProjectsSubtitle;
      default:
        return '';
    }
  }

  String get reportPeriodDemo => isArabic ? 'يناير 2024' : 'January 2024';

  String get reportCreatedDemo => formatDateLabel(15, 1, 2024);

  List<Map<String, dynamic>> reportDetailMetrics(String typeKey) {
    switch (normalizeReportType(typeKey)) {
      case reportRevenue:
        return [
          {
            'title': l10n.reportTotalIncome,
            'value': '52,000 ${l10n.aed}',
            'icon': Icons.account_balance_wallet,
            'color': AppColors.accentGold,
          },
          {
            'title': l10n.reportTransactionCount,
            'value': '8',
            'icon': Icons.receipt,
            'color': Colors.blueAccent,
          },
          {
            'title': l10n.reportAvgMonthlyIncome,
            'value': '48,500 ${l10n.aed}',
            'icon': Icons.trending_up,
            'color': Colors.greenAccent,
          },
        ];
      case reportRented:
        return [
          {
            'title': l10n.reportTotalProperties,
            'value': '8',
            'icon': Icons.house,
            'color': AppColors.accentGold,
          },
          {
            'title': l10n.rentedProperties,
            'value': '6',
            'icon': Icons.check_circle,
            'color': Colors.greenAccent,
          },
          {
            'title': l10n.reportVacantProperties,
            'value': '2',
            'icon': Icons.cancel,
            'color': Colors.orange,
          },
        ];
      case reportProjects:
        return [
          {
            'title': l10n.reportActiveProjects,
            'value': '3',
            'icon': Icons.construction,
            'color': AppColors.accentGold,
          },
          {
            'title': l10n.reportAvgCompletion,
            'value': '60%',
            'icon': Icons.trending_up,
            'color': Colors.blueAccent,
          },
          {
            'title': l10n.totalCost,
            'value': '2,500,000 ${l10n.aed}',
            'icon': Icons.account_balance,
            'color': Colors.greenAccent,
          },
        ];
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> imageAnalysisResults() => [
        {
          'title': _t('حالة الجدران', 'Wall condition'),
          'description': _t('الجدران بحالة جيدة مع بعض التشققات البسيطة', 'Walls are in good condition with minor cracks'),
          'severity': _t('منخفض', 'Low'),
          'color': Colors.green,
          'recommendation': _t('معالجة التشققات خلال 3 أشهر', 'Repair cracks within 3 months'),
        },
        {
          'title': _t('السباكة', 'Plumbing'),
          'description': _t('يوجد تسريب بسيط في الحمام', 'Minor leak detected in the bathroom'),
          'severity': _t('متوسط', 'Medium'),
          'color': Colors.orange,
          'recommendation': _t('فحص السباكة فوراً', 'Inspect plumbing immediately'),
        },
        {
          'title': _t('الكهرباء', 'Electrical'),
          'description': _t('النظام الكهربائي يعمل بشكل طبيعي', 'Electrical system is operating normally'),
          'severity': _t('جيد', 'Good'),
          'color': Colors.green,
          'recommendation': _t('لا حاجة لإجراء فوري', 'No immediate action required'),
        },
      ];

  Map<String, dynamic> tenantAnalysisResult({
    required double income,
    required String employmentKey,
    required bool hasPreviousRentals,
    double? portfolioAvgRent,
    bool existingTenantMatch = false,
  }) {
    final financialScore = _financialScore(income, portfolioAvgRent);
    final employmentScore = switch (employmentKey) {
      empGov => 90,
      empPrivate => 75,
      empFreelance => 60,
      empRetired => 70,
      _ => 70,
    };
    var recordScore = hasPreviousRentals ? 80 : 50;
    if (existingTenantMatch) {
      recordScore = (recordScore + 15).clamp(0, 100);
    }
    final riskScore =
        ((financialScore + employmentScore + recordScore) / 3).round();

    String recommendation;
    if (riskScore < 50) {
      recommendation = l10n.tenantRiskHighRecommendation;
    } else if (riskScore < 70) {
      recommendation = l10n.tenantRiskMediumRecommendation;
    } else {
      recommendation = l10n.tenantRiskLowRecommendation;
    }

    if (portfolioAvgRent != null && portfolioAvgRent > 0) {
      final rentLabel = portfolioAvgRent.round().toString();
      recommendation = isArabic
          ? '$recommendation · متوسط إيجار محفظتك ≈ $rentLabel ${l10n.aed}'
          : '$recommendation · Portfolio avg rent ≈ $rentLabel ${l10n.aed}';
    }

    return {
      'riskScore': riskScore,
      'financialCapacity': financialScore >= 80
          ? l10n.excellent
          : financialScore >= 65
              ? l10n.good
              : l10n.weak,
      'financialScore': financialScore,
      'employmentStability':
          employmentKey == empGov ? l10n.veryStable : l10n.stable,
      'employmentScore': employmentScore,
      'previousRecord': existingTenantMatch
          ? (isArabic ? 'مستأجر حالي في النظام' : 'Existing tenant in system')
          : (hasPreviousRentals ? l10n.available : l10n.notAvailable),
      'recordScore': recordScore,
      'recommendation': recommendation,
      'portfolioAvgRent': portfolioAvgRent,
      'existingTenantMatch': existingTenantMatch,
    };
  }

  int _financialScore(double income, double? portfolioAvgRent) {
    if (portfolioAvgRent != null && portfolioAvgRent > 0) {
      final ratio = income / portfolioAvgRent;
      if (ratio >= 3.5) return 90;
      if (ratio >= 3.0) return 80;
      if (ratio >= 2.0) return 65;
      return 45;
    }
    if (income > 20000) return 85;
    if (income > 15000) return 70;
    return 50;
  }

  String riskLabel(int score) {
    if (score < 50) return l10n.riskHigh;
    if (score < 70) return l10n.riskMedium;
    return l10n.riskLow;
  }

  String formatDateLabel(int day, int month, int year) {
    final months = [
      l10n.january,
      l10n.february,
      l10n.march,
      l10n.april,
      l10n.may,
      l10n.june,
      l10n.july,
      l10n.august,
      l10n.september,
      l10n.october,
      l10n.november,
      l10n.december,
    ];
    final monthName = months[month - 1];
    return isArabic ? '$day $monthName، $year' : '$monthName $day, $year';
  }

  List<Map<String, dynamic>> calendarEvents() {
    final now = DateTime.now();
    final y = now.year;
    final m = now.month;
    return [
        {
          'date': DateTime(y, m, 1),
          'title': _t('استحقاق إيجار فيلا الياسمين', 'Rent due - Jasmine Villa'),
          'type': 'payment',
          'property': _t('فيلا الياسمين - دبي مارينا', 'Jasmine Villa - Dubai Marina'),
          'amount': '8,000 ${l10n.aed}',
          'time': '10:00',
        },
        {
          'date': DateTime(y, m, 5),
          'title': _t('صيانة شقة الرياض', 'Maintenance - Riyadh Apartment'),
          'type': 'maintenance',
          'property': _t('شقة الرياض - أبوظبي', 'Riyadh Apartment - Abu Dhabi'),
          'time': '14:00',
        },
        {
          'date': DateTime(y, m, 15),
          'title': _t('استحقاق إيجار شقة الرياض', 'Rent due - Riyadh Apartment'),
          'type': 'payment',
          'property': _t('شقة الرياض - أبوظبي', 'Riyadh Apartment - Abu Dhabi'),
          'amount': '25,000 ${l10n.aed}',
          'time': '09:00',
        },
        {
          'date': DateTime(y, m, 20),
          'title': _t('انتهاء عقد فيلا الياسمين', 'Contract end - Jasmine Villa'),
          'type': 'contract',
          'property': _t('فيلا الياسمين - دبي مارينا', 'Jasmine Villa - Dubai Marina'),
          'time': '12:00',
        },
      ];
  }

  List<Map<String, dynamic>> reportTransactions() => [
        {
          'title': _t('إيجار شقة الرياض', 'Riyadh Apartment rent'),
          'amount': '+ 25,000 ${l10n.aed}',
          'date': formatDateLabel(15, 6, 2024),
          'isIncome': true,
        },
        {
          'title': _t('صيانة فيلا الياسمين', 'Jasmine Villa maintenance'),
          'amount': '- 3,500 ${l10n.aed}',
          'date': formatDateLabel(12, 6, 2024),
          'isIncome': false,
        },
        {
          'title': _t('إيجار مكتب جدة', 'Jeddah Office rent'),
          'amount': '+ 50,000 ${l10n.aed}',
          'date': formatDateLabel(5, 6, 2024),
          'isIncome': true,
        },
      ];

  Map<String, String> searchResultProperty() => {
        'name': _t('فيلا الياسمين', 'Jasmine Villa'),
        'location': _t('الرياض، حي الياسمين', 'Riyadh, Al Yasmin'),
        'fullLocation': _t(
          'طريق الملك فهد، حي الياسمين، الرياض',
          'King Fahd Road, Al Yasmin, Riyadh',
        ),
        'price': '8,000 ${l10n.aed}/${l10n.perMonth}',
        'area': isArabic ? '350 م²' : '350 m²',
      };

  List<Map<String, dynamic>> myProperties() => [
        {
          'name': _t('فيلا الياسمين', 'Jasmine Villa'),
          'location': _t('الرياض، حي الياسمين', 'Riyadh, Al Yasmin'),
          'statusType': filterRented,
          'statusLabel': l10n.rented,
          'statusColor': AppColors.accentGold,
          'tenantName': _t('عبد الله العامري', 'Abdullah Al Amri'),
          'tenantDisplay': '${l10n.tenantLabel}${_t('عبد الله العامري', 'Abdullah Al Amri')}',
          'contractEnd': '${l10n.contractEndsOn} 24/12/2024',
          'isVacant': false,
          'imagePaths': [
            'assetss/images/home1.jpg',
            'assetss/images/home2.jpg',
            'assetss/images/home3.jpg',
            'assetss/images/home4.jpg',
            'assetss/images/home5.jpg',
            'assetss/images/home6.jpg',
          ],
          'detail': {
            'name': _t('فيلا الياسمين', 'Jasmine Villa'),
            'location': _t(
              'طريق الملك فهد، حي الياسمين، الرياض',
              'King Fahd Road, Al Yasmin, Riyadh',
            ),
            'status': l10n.rented,
            'tenantName': _t('عبد الله العامري', 'Abdullah Al Amri'),
            'rentAmount': '8,000',
            'rentEndDate': '24/12/2024',
            'nextDueDate': '01/07/2024',
            'imagePath': 'assetss/images/home1.jpg',
            'description': _t(
              'فيلا فاخرة بتصميم عصري مكونة من طابقين، تحتوي على حديقة خاصة ومسبح. تقع في حي هادئ وراقي، ومزودة بأحدث وسائل الراحة والأمان.',
              'A luxury villa with modern design spanning two floors, featuring a private garden and pool. Located in a quiet upscale neighborhood with the latest comfort and security features.',
            ),
            'area': '350',
            'bathrooms': 3,
            'bedrooms': 4,
          },
        },
        {
          'name': _t('شقة الرياض', 'Riyadh Apartment'),
          'location': _t('الرياض، حي العليا', 'Riyadh, Al Olaya'),
          'statusType': filterVacant,
          'statusLabel': l10n.vacant,
          'statusColor': Colors.green,
          'tenantName': l10n.noTenant,
          'tenantDisplay': l10n.noTenant,
          'contractEnd': l10n.readyForRent,
          'isVacant': true,
          'imagePaths': [
            'assetss/images/home2.jpg',
            'assetss/images/home4.jpg',
            'assetss/images/home5.jpg',
            'assetss/images/home6.jpg',
            'assetss/images/home7.jpg',
            'assetss/images/home8.jpg',
          ],
          'detail': {
            'name': _t('شقة الرياض', 'Riyadh Apartment'),
            'location': _t('الرياض، حي العليا', 'Riyadh, Al Olaya'),
            'status': l10n.vacant,
            'imagePath': 'assetss/images/home2.jpg',
          },
        },
        {
          'name': _t('فيلا النخيل', 'Palm Villa'),
          'location': _t('جدة، حي النخيل', 'Jeddah, Al Nakheel'),
          'statusType': filterRented,
          'statusLabel': l10n.rented,
          'statusColor': AppColors.accentGold,
          'tenantName': _t('محمد السعيد', 'Mohammed Al Saeed'),
          'tenantDisplay': '${l10n.tenantLabel}${_t('محمد السعيد', 'Mohammed Al Saeed')}',
          'contractEnd': '${l10n.contractEndsOn} 15/11/2024',
          'isVacant': false,
          'imagePaths': [
            'assetss/images/home3.jpg',
            'assetss/images/home5.jpg',
            'assetss/images/home7.jpg',
            'assetss/images/home1.jpg',
            'assetss/images/home8.jpg',
          ],
          'detail': {
            'name': _t('فيلا النخيل', 'Palm Villa'),
            'location': _t('جدة، حي النخيل', 'Jeddah, Al Nakheel'),
            'status': l10n.rented,
            'tenantName': _t('محمد السعيد', 'Mohammed Al Saeed'),
            'rentAmount': '12,000',
            'rentEndDate': '15/11/2024',
            'nextDueDate': '01/08/2024',
            'imagePath': 'assetss/images/home3.jpg',
            'description': _t(
              'فيلا راقية بموقع ممتاز قريبة من البحر، تحتوي على 4 غرف نوم و3 حمامات وحديقة واسعة.',
              'An upscale villa in an excellent location near the sea, with 4 bedrooms, 3 bathrooms, and a spacious garden.',
            ),
            'area': '420',
            'bathrooms': 3,
            'bedrooms': 4,
          },
        },
      ];

  static const accountTypeCurrent = 'current';
  static const accountTypeOther = 'other';

  List<Map<String, String>> bankAccountTypes() => [
        {'key': accountTypeCurrent, 'label': l10n.myCurrentAccount},
        {'key': accountTypeOther, 'label': l10n.otherAccount},
      ];

  List<Map<String, String>> transferBanks() => [
        {
          'key': 'emirates_nbd',
          'label': _t('بنك الإمارات دبي الوطني', 'Emirates NBD'),
        },
        {
          'key': 'adcb',
          'label': _t('بنك أبوظبي التجاري', 'Abu Dhabi Commercial Bank'),
        },
        {
          'key': 'fab',
          'label': _t('بنك أبوظبي الأول', 'First Abu Dhabi Bank'),
        },
        {'key': 'mashreq', 'label': _t('بنك المشرق', 'Mashreq Bank')},
        {
          'key': 'dib',
          'label': _t('بنك دبي الإسلامي', 'Dubai Islamic Bank'),
        },
        {'key': 'rakbank', 'label': _t('راك بنك', 'RAKBANK')},
        {'key': 'other', 'label': l10n.otherBank},
      ];

  String transferBankLabel(String key) {
    for (final bank in transferBanks()) {
      if (bank['key'] == key) {
        return bank['label']!;
      }
    }
    return key;
  }

  String localizedContractStatus(String? statusType) {
    switch (statusType) {
      case 'active':
        return l10n.active;
      case 'expiring':
        return l10n.expiring;
      case 'ended':
        return l10n.ended;
      default:
        return statusType ?? l10n.active;
    }
  }

  String formatContractRemaining(int? days) {
    if (days == null) return '-';
    if (days < 0) return l10n.endedDaysAgo(-days);
    return l10n.daysCount(days);
  }

  Map<String, dynamic> _contractSeedById(int id) {
    switch (id) {
      case 1:
        return {
          'propertyName': _t('شقة العليا - الدور 2', 'Al Olaya Apartment - Floor 2'),
          'tenantName': _t('فاطمة الزهراني', 'Fatima Al Zahrani'),
          'monthlyRent': '25,000',
          'startDate': '01/11/2023',
          'nextPayment': '01/11/2024',
          'tenantPhone': '+971 50 111 2233',
          'tenantEmail': 'fatima@example.com',
        };
      case 2:
        return {
          'propertyName': _t('فيلا الروضة - وحدة 3', 'Al Rawdah Villa - Unit 3'),
          'tenantName': _t('عبد الله العامري', 'Abdullah Al Amri'),
          'monthlyRent': '8,000',
          'startDate': '20/11/2023',
          'nextPayment': '20/11/2024',
          'tenantPhone': '+971 55 444 5566',
          'tenantEmail': 'abdullah@example.com',
        };
      case 3:
        return {
          'propertyName': _t('مكتب النخيل - طابق 5', 'Al Nakheel Office - Floor 5'),
          'tenantName': _t('شركة التقنية الحديثة', 'Modern Tech Company'),
          'monthlyRent': '50,000',
          'startDate': '03/10/2023',
          'nextPayment': '-',
          'tenantPhone': '+971 4 123 4567',
          'tenantEmail': 'info@moderntech.example',
        };
      default:
        return {};
    }
  }

  List<Map<String, dynamic>> contracts() => [
        {
          'id': 1,
          'statusType': 'expiring',
          'endDate': '30/10/2024',
          'daysRemaining': 5,
          ..._contractSeedById(1),
        },
        {
          'id': 2,
          'statusType': 'active',
          'endDate': '20/11/2024',
          'daysRemaining': 25,
          ..._contractSeedById(2),
        },
        {
          'id': 3,
          'statusType': 'ended',
          'endDate': '03/10/2024',
          'daysRemaining': -12,
          ..._contractSeedById(3),
        },
      ];

  List<Map<String, dynamic>> projects() => [
        {
          'id': 1,
          'name': _t('مشروع فيلا سكنية', 'Residential Villa Project'),
          'location': _t('الرياض، حي المطار', 'Riyadh, Airport District'),
          'progress': 0.65,
          'startDate': '01/01/2023',
          'expectedDate': '30/06/2024',
          'totalCost': '1,500,000',
          'totalCostDisplay': '1,500,000 ${l10n.aed}',
          'paidAmount': '975,000',
          'remainingAmount': '525,000',
          'imagePath': 'assetss/images/home3.jpg',
        },
        {
          'id': 2,
          'name': _t('مجمع شقق سكنية', 'Residential Apartment Complex'),
          'location': _t('جدة، حي الحمراء', 'Jeddah, Al Hamra'),
          'progress': 0.35,
          'startDate': '01/06/2023',
          'expectedDate': '31/12/2024',
          'totalCost': '3,200,000',
          'totalCostDisplay': '3,200,000 ${l10n.aed}',
          'paidAmount': '1,120,000',
          'remainingAmount': '2,080,000',
          'imagePath': 'assetss/images/home4.jpg',
        },
        {
          'id': 3,
          'name': _t('عمارة تجارية', 'Commercial Building'),
          'location': _t('الدمام، حي الكورنيش', 'Dammam, Corniche'),
          'progress': 0.80,
          'startDate': '01/03/2023',
          'expectedDate': '30/09/2024',
          'totalCost': '2,800,000',
          'totalCostDisplay': '2,800,000 ${l10n.aed}',
          'paidAmount': '2,240,000',
          'remainingAmount': '560,000',
          'imagePath': 'assetss/images/home5.jpg',
        },
      ];

  Map<String, dynamic> enrichProjectDetail(
    Map<String, dynamic> project, {
    bool fillMissingWithDemo = true,
  }) {
    final id = project['id'];
    final seed = fillMissingWithDemo && id is int
        ? projects().firstWhere(
            (item) => item['id'] == id,
            orElse: () => <String, dynamic>{},
          )
        : <String, dynamic>{};
    final result = Map<String, dynamic>.from(project);

    if (seed.isNotEmpty) {
      for (final entry in seed.entries) {
        result.putIfAbsent(entry.key, () => entry.value);
      }
      result['progress'] = project['progress'] ?? result['progress'];
    }

    if (fillMissingWithDemo) {
      final fallback = {
        'name': _t('برج النخيل السكني', 'Palm Tower Residential'),
        'location': _t('أبوظبي، الإمارات', 'Abu Dhabi, UAE'),
        'progress': 0.75,
        'imagePath': 'assetss/images/home3.jpg',
        'expectedDate': isArabic ? 'ديسمبر 2025' : 'December 2025',
        'manager': _t('شركة البناء المتحدة', 'United Building Company'),
      };

      for (final entry in fallback.entries) {
        result.putIfAbsent(entry.key, () => entry.value);
      }

      result['lastUpdate'] = l10n.lastUpdateOn(formatDateLabel(2, 8, 2024));
      result['lastSiteUpdate'] = l10n.daysAgoShort(3);
    }

    return result;
  }

  static const cancelReasonContractEnd = 'contract_end';
  static const cancelReasonTenantViolation = 'tenant_violation';
  static const cancelReasonTenantRequest = 'tenant_request';
  static const cancelReasonOther = 'other';

  List<Map<String, String>> contractCancelReasons() => [
        {'key': cancelReasonContractEnd, 'label': l10n.cancelReasonContractEnd},
        {
          'key': cancelReasonTenantViolation,
          'label': l10n.cancelReasonTenantViolation,
        },
        {'key': cancelReasonTenantRequest, 'label': l10n.cancelReasonTenantRequest},
        {'key': cancelReasonOther, 'label': l10n.cancelReasonOther},
      ];

  String contractCancelReasonLabel(String key) {
    for (final reason in contractCancelReasons()) {
      if (reason['key'] == key) {
        return reason['label']!;
      }
    }
    return key;
  }

  static const lawsuitTypeRentNonpayment = 'rent_nonpayment';
  static const lawsuitTypePropertyDamage = 'property_damage';
  static const lawsuitTypeContractViolation = 'contract_violation';
  static const lawsuitTypeOther = 'other';

  List<Map<String, String>> lawsuitTypes() => [
        {
          'key': lawsuitTypeRentNonpayment,
          'label': l10n.lawsuitTypeRentNonpayment,
        },
        {
          'key': lawsuitTypePropertyDamage,
          'label': l10n.lawsuitTypePropertyDamage,
        },
        {
          'key': lawsuitTypeContractViolation,
          'label': l10n.lawsuitTypeContractViolation,
        },
        {'key': lawsuitTypeOther, 'label': l10n.lawsuitTypeOther},
      ];

  String get privacyPolicyLastUpdated =>
      l10n.lastUpdateOn(formatDateLabel(1, 1, 2024));

  List<Map<String, String>> privacyPolicySections() => [
        {
          'title': l10n.privacySection1Title,
          'content': l10n.privacySection1Content,
        },
        {
          'title': l10n.privacySection2Title,
          'content': l10n.privacySection2Content,
        },
        {
          'title': l10n.privacySection3Title,
          'content': l10n.privacySection3Content,
        },
        {
          'title': l10n.privacySection4Title,
          'content': l10n.privacySection4Content,
        },
      ];

  List<Map<String, dynamic>> tenants() => [
        {
          'name': _t('عبد الله العامري', 'Abdullah Al Amri'),
          'property': _t('فيلا الياسمين', 'Jasmine Villa'),
          'phone': '+971 50 123 4567',
          'email': 'a.alamri@email.com',
          'rentAmount': '8,000 ${l10n.aed}',
          'contractEnd': '24/12/2024',
          'status': l10n.active,
        },
        {
          'name': _t('محمد أحمد', 'Mohammed Ahmed'),
          'property': _t('شقة الرياض', 'Riyadh Apartment'),
          'phone': '+971 55 234 5678',
          'email': 'm.ahmed@email.com',
          'rentAmount': '25,000 ${l10n.aed}',
          'contractEnd': '15/07/2024',
          'status': l10n.active,
        },
        {
          'name': _t('علي حسن', 'Ali Hassan'),
          'property': _t('مكتب جدة', 'Jeddah Office'),
          'phone': '+971 50 345 6789',
          'email': 'a.hassan@email.com',
          'rentAmount': '50,000 ${l10n.aed}',
          'contractEnd': '05/08/2024',
          'status': l10n.active,
        },
      ];

  String get tenantsTotalMonthlyRent => '83,000 ${l10n.aed}';

  List<Map<String, String>> supportedCurrencies() => [
        {'code': 'AED', 'name': l10n.aedCurrency, 'symbol': l10n.aed},
        {'code': 'SAR', 'name': l10n.sarCurrency, 'symbol': l10n.sarSymbol},
        {'code': 'USD', 'name': l10n.usd, 'symbol': r'$'},
        {'code': 'EUR', 'name': l10n.eur, 'symbol': '€'},
        {'code': 'GBP', 'name': l10n.gbp, 'symbol': '£'},
      ];

  Map<String, dynamic> enrichContractDetail(
    Map<String, dynamic> contract, {
    bool fillMissingWithDemo = true,
  }) {
    final id = contract['id'];
    final seed = fillMissingWithDemo && id is int
        ? _contractSeedById(id)
        : <String, dynamic>{};
    final result = Map<String, dynamic>.from(contract);

    if (seed.isNotEmpty) {
      result.addAll(seed);
      result['statusType'] = contract['statusType'] ?? result['statusType'];
      result['endDate'] = contract['endDate'] ?? result['endDate'];
      result['daysRemaining'] = contract['daysRemaining'] ?? result['daysRemaining'];
    }

    final propertyName = result['propertyName'] as String? ??
        result['property_name'] as String? ??
        (fillMissingWithDemo ? _t('فيلا الياسمين', 'Jasmine Villa') : '-');

    if (fillMissingWithDemo) {
      result.putIfAbsent('startDate', () => '01/01/2024');
      result.putIfAbsent('monthlyRent', () => '8,000');
      result.putIfAbsent('nextPayment', () => '01/11/2024');
      result.putIfAbsent('tenantPhone', () => '+971 50 123 4567');
      result.putIfAbsent('tenantEmail', () => 'tenant@example.com');
      result.putIfAbsent(
        'tenantName',
        () => _t('عبد الله العامري', 'Abdullah Al Amri'),
      );
      result.putIfAbsent('endDate', () => '-');
      result.putIfAbsent(
        'contractPdf',
        () =>
            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      );
    }

    result['propertyName'] = propertyName;
    result['title'] = l10n.contractRentalTitle(propertyName);
    result['status'] = localizedContractStatus(result['statusType'] as String?);
    if (result['monthlyRent'] != null) {
      result['monthlyRentDisplay'] = '${result['monthlyRent']} ${l10n.aed}';
    }
    result['remainingDisplay'] =
        formatContractRemaining(result['daysRemaining'] as int?);

    return result;
  }

  /// قيم افتراضية لشاشة تفاصيل العقار عند غياب بيانات من القائمة.
  Map<String, dynamic> propertyDetailFallback() => {
        'name': _t('فيلا الياسمين', 'Jasmine Villa'),
        'location': _t(
          'طريق الملك فهد، حي الياسمين، الرياض',
          'King Fahd Road, Al Yasmin, Riyadh',
        ),
        'status': l10n.rented,
        'tenantName': _t('عبد الله العامري', 'Abdullah Al Amri'),
        'rentAmount': '8,000',
        'rentEndDate': '24/12/2024',
        'nextDueDate': '01/07/2024',
        'imagePath': 'assetss/images/home1.jpg',
        'description': _t(
          'فيلا فاخرة بتصميم عصري مكونة من طابقين، تحتوي على حديقة خاصة ومسبح. تقع في حي هادئ وراقي، ومزودة بأحدث وسائل الراحة والأمان.',
          'A luxury villa with modern design spanning two floors, featuring a private garden and pool. Located in a quiet upscale neighborhood with the latest comfort and security features.',
        ),
        'area': '350',
        'bathrooms': 3,
        'bedrooms': 4,
      };
}
