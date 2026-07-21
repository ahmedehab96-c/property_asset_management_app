import 'package:flutter/material.dart';
import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/api_response_mappers.dart';

/// تحويل استجابات Laravel إلى خرائط واجهة تطبيق المالك.
class OwnerApiMappers {
  OwnerApiMappers._();

  static const _defaultImages = [
    'assetss/images/home1.jpg',
    'assetss/images/home2.jpg',
    'assetss/images/home3.jpg',
    'assetss/images/home4.jpg',
    'assetss/images/home5.jpg',
    'assetss/images/home6.jpg',
  ];

  static List<dynamic> extractList(dynamic res) => ApiResponseMappers.extractList(res);

  static Map<String, dynamic>? unwrapObject(dynamic res) => ApiResponseMappers.unwrapObject(res);

  static Map<String, dynamic> toMyPropertyCard(
    Map<String, dynamic> raw,
    AppLocalizations l10n,
  ) {
    final statusRaw = (_field(raw, 'status') ?? '').toString().toLowerCase();
    final vacant = _isVacant(statusRaw);
    final tenantName = (_field(raw, 'tenantName', 'tenant_name') ??
            _field(raw, 'tenant') ??
            '')
        .toString();
    final tenantDisplay = vacant || tenantName.isEmpty || tenantName == '-'
        ? l10n.noTenant
        : '${l10n.tenantLabel}$tenantName';
    final contractEndRaw =
        (_field(raw, 'contractEnd', 'contract_end') ?? '').toString();
    final contractEnd = vacant
        ? l10n.readyForRent
        : _formatContractEnd(contractEndRaw, l10n);
    final name = (_field(raw, 'name', 'title') ?? '-').toString();
    final location =
        (_field(raw, 'location', 'address') ?? '').toString();
    final id = (raw['id'] as num?)?.toInt();
    final contractId = (_field(raw, 'contractId', 'contract_id') as num?)?.toInt();

    final detail = <String, dynamic>{
      'id': id,
      'name': name,
      'location': location,
      'status': vacant ? l10n.vacant : l10n.rented,
      if (!vacant && tenantName.isNotEmpty && tenantName != '-') 'tenantName': tenantName,
      if (_field(raw, 'rentAmount', 'rent_amount') != null)
        'rentAmount': _field(raw, 'rentAmount', 'rent_amount').toString(),
      if (_field(raw, 'monthlyRevenue', 'monthly_revenue') != null &&
          _field(raw, 'rentAmount', 'rent_amount') == null)
        'rentAmount': _field(raw, 'monthlyRevenue', 'monthly_revenue').toString(),
      if (contractEndRaw.isNotEmpty) 'rentEndDate': contractEndRaw,
      if (_field(raw, 'nextDueDate', 'next_due_date') != null)
        'nextDueDate': _field(raw, 'nextDueDate', 'next_due_date').toString(),
      'imagePath': _imagePaths(raw).first,
      if (_field(raw, 'description') != null)
        'description': _field(raw, 'description').toString(),
      if (_field(raw, 'area') != null) 'area': _field(raw, 'area').toString(),
      if (_field(raw, 'bedrooms') != null)
        'bedrooms': _field(raw, 'bedrooms'),
      if (_field(raw, 'bathrooms') != null)
        'bathrooms': _field(raw, 'bathrooms'),
    };

    return {
      'id': id,
      'contractId': ?contractId,
      'name': name,
      'location': location,
      'statusType': vacant ? LocalizedDemoData.filterVacant : LocalizedDemoData.filterRented,
      'statusLabel': vacant ? l10n.vacant : l10n.rented,
      'statusColor': vacant ? Colors.green : AppColors.accentGold,
      'tenantName': vacant ? l10n.noTenant : tenantName,
      'tenantDisplay': tenantDisplay,
      'contractEnd': contractEnd,
      'isVacant': vacant,
      'imagePaths': _imagePaths(raw),
      'detail': detail,
    };
  }

  static dynamic _field(Map<String, dynamic> obj, String camel, [String? snake]) {
    final s = snake ??
        camel.replaceAllMapped(
          RegExp(r'[A-Z]'),
          (m) => '_${m.group(0)!.toLowerCase()}',
        );
    return obj[camel] ?? obj[s];
  }

  static bool _isVacant(String status) {
    if (status.isEmpty) return true;
    return status.contains('vacant') ||
        status.contains('available') ||
        status.contains('empty') ||
        status == 'free';
  }

  static String _formatContractEnd(String raw, AppLocalizations l10n) {
    if (raw.isEmpty || raw == '-') return l10n.readyForRent;
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      final d = parsed.day.toString().padLeft(2, '0');
      final m = parsed.month.toString().padLeft(2, '0');
      return '${l10n.contractEndsOn} $d/$m/${parsed.year}';
    }
    return '${l10n.contractEndsOn} $raw';
  }

  static List<String> _imagePaths(Map<String, dynamic> p) {
    final raw = p['images'] ?? p['image_urls'] ?? p['imageUrls'] ?? p['photos'];
    if (raw is List && raw.isNotEmpty) {
      final urls = raw
          .map((e) {
            if (e is String) return e;
            if (e is Map) return (e['url'] ?? e['path'] ?? '').toString();
            return '';
          })
          .where((s) => s.isNotEmpty)
          .cast<String>()
          .toList();
      if (urls.isNotEmpty) return urls;
    }
    final single = p['image'] ?? p['image_url'] ?? p['imageUrl'] ?? p['thumbnail'];
    if (single != null && single.toString().isNotEmpty) {
      return [single.toString()];
    }
    return List<String>.from(_defaultImages);
  }

  static Map<String, dynamic> toContractCard(
    Map<String, dynamic> raw,
    AppLocalizations l10n,
  ) {
    final id = (raw['id'] as num?)?.toInt();
    final endRaw = _field(raw, 'endDate', 'end_date')?.toString();
    final endDate = _parseDate(endRaw);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final daysRemaining =
        endDate != null ? endDate.difference(today).inDays : 0;
    final statusType = _resolveContractStatusType(raw, daysRemaining);
    final monthlyRent =
        (_field(raw, 'monthlyRent', 'monthly_rent') ?? '').toString();

    return {
      'id': id,
      'statusType': statusType,
      'endDate': endDate != null ? _formatShortDate(endDate) : (endRaw ?? '-'),
      'daysRemaining': daysRemaining,
      'propertyName': (_field(raw, 'propertyName', 'property_name') ??
              _field(raw, 'property') ??
              '-')
          .toString(),
      'tenantName': (_field(raw, 'tenantName', 'tenant_name') ??
              _field(raw, 'tenant') ??
              '-')
          .toString(),
      if (monthlyRent.isNotEmpty && monthlyRent != '-')
        'monthlyRent': monthlyRent,
      'startDate': _formatShortDate(
        _parseDate(_field(raw, 'startDate', 'start_date')?.toString()),
      ),
      if (_field(raw, 'nextPayment', 'next_payment') != null)
        'nextPayment': _field(raw, 'nextPayment', 'next_payment').toString(),
      if (_field(raw, 'tenantPhone', 'tenant_phone') != null)
        'tenantPhone': _field(raw, 'tenantPhone', 'tenant_phone').toString(),
      if (_field(raw, 'tenantEmail', 'tenant_email') != null)
        'tenantEmail': _field(raw, 'tenantEmail', 'tenant_email').toString(),
      if (_field(raw, 'contractPdf', 'contract_pdf') != null)
        'contractPdf': _field(raw, 'contractPdf', 'contract_pdf').toString(),
      if (_field(raw, 'pdfUrl', 'pdf_url') != null)
        'pdfUrl': _field(raw, 'pdfUrl', 'pdf_url').toString(),
    };
  }

  static Map<String, dynamic> toTenantCard(
    Map<String, dynamic> raw,
    AppLocalizations l10n,
  ) {
    final rentRaw = _field(raw, 'rentAmount', 'rent_amount') ??
        _field(raw, 'monthlyRent', 'monthly_rent');
    final rentNumeric = _parseAmount(rentRaw);
    final rentAmount = rentNumeric != null
        ? '${_formatThousands(rentNumeric.round())} ${l10n.aed}'
        : (rentRaw?.toString().isNotEmpty == true ? rentRaw.toString() : '-');

    return {
      'id': (raw['id'] as num?)?.toInt(),
      'name': (_field(raw, 'name', 'full_name') ?? '-').toString(),
      'property': (_field(raw, 'propertyName', 'property_name') ??
              _field(raw, 'property') ??
              '-')
          .toString(),
      'phone': (_field(raw, 'phone', 'mobile') ?? '-').toString(),
      'email': (_field(raw, 'email') ?? '').toString(),
      'rentAmount': rentAmount,
      '_rentNumeric': rentNumeric ?? 0,
      'contractEnd': _formatShortDate(
        _parseDate(_field(raw, 'contractEnd', 'contract_end')?.toString()),
      ),
      'status': _localizedTenantStatus(_field(raw, 'status')?.toString(), l10n),
    };
  }

  static String formatTenantsTotalRent(
    List<Map<String, dynamic>> tenants,
    AppLocalizations l10n,
  ) {
    var total = 0.0;
    for (final tenant in tenants) {
      total += (tenant['_rentNumeric'] as num?)?.toDouble() ?? 0;
    }
    if (total <= 0) return '0 ${l10n.aed}';
    return '${_formatThousands(total.round())} ${l10n.aed}';
  }

  static String formatMoney(double amount, AppLocalizations l10n, {bool signed = false}) {
    final prefix = signed ? (amount >= 0 ? '+ ' : '- ') : '';
    return '$prefix${_formatThousands(amount.abs().round())} ${l10n.aed}';
  }

  static double? parseBalance(Map<String, dynamic>? data) {
    if (data == null) return null;
    for (final key in [
      'walletBalance',
      'wallet_balance',
      'balance',
      'totalBalance',
      'total_balance',
      'availableBalance',
      'available_balance',
    ]) {
      final value = _parseAmount(data[key]);
      if (value != null) return value;
    }
    return null;
  }

  static double? parseRevenue(Map<String, dynamic>? data) {
    if (data == null) return null;
    for (final key in [
      'total_revenue',
      'totalRevenue',
      'monthly_revenue',
      'monthlyRevenue',
      'monthly_income',
      'monthlyIncome',
    ]) {
      final value = _parseAmount(_field(data, key));
      if (value != null) return value;
    }
    return null;
  }

  static double? parseExpenses(Map<String, dynamic>? data) {
    if (data == null) return null;
    for (final key in [
      'total_expenses',
      'totalExpenses',
      'monthly_expenses',
      'monthlyExpenses',
    ]) {
      final value = _parseAmount(_field(data, key));
      if (value != null) return value;
    }
    return null;
  }

  static String? parseGrowthPercent(Map<String, dynamic>? data) {
    if (data == null) return null;
    final raw = _field(data, 'growthRate', 'growth_rate') ??
        _field(data, 'revenueGrowth', 'revenue_growth') ??
        _field(data, 'growth');
    if (raw == null) return null;
    final text = raw.toString().trim();
    if (text.isEmpty || text == '-') return null;
    if (text.startsWith('+') || text.startsWith('-')) return text;
    return '+$text';
  }

  static WalletTransactionData toWalletTransaction(
    Map<String, dynamic> raw,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final amountValue = _parseAmount(_field(raw, 'amount')) ?? 0;
    final type =
        (_field(raw, 'type') ?? _field(raw, 'status') ?? '').toString().toLowerCase();
    final isExpense = type.contains('expense') ||
        type.contains('transfer') ||
        type.contains('withdraw') ||
        type.contains('maintenance') ||
        type.contains('fee');
    final isIncome = !isExpense &&
        (type.contains('income') ||
            type.contains('rent') ||
            type.contains('revenue') ||
            type.contains('paid') ||
            amountValue >= 0);

    final title = (_field(raw, 'description') ??
            _field(raw, 'title') ??
            _field(raw, 'propertyName', 'property_name') ??
            _field(raw, 'tenantName', 'tenant_name') ??
            l10n.payments)
        .toString();
    final dateRaw = (_field(raw, 'paymentDate', 'payment_date') ??
            _field(raw, 'dueDate', 'due_date') ??
            _field(raw, 'createdAt', 'created_at') ??
            '')
        .toString();
    final date = _parseDate(dateRaw) ?? DateTime.now();
    final demo = LocalizedDemoData(l10n: l10n, isArabic: isArabic);
    final signedValue = isIncome ? amountValue.abs() : -amountValue.abs();

    return WalletTransactionData(
      title: title,
      amount: formatMoney(signedValue, l10n, signed: true),
      dateLabel: demo.formatDateLabel(date.day, date.month, date.year),
      date: date,
      isIncome: isIncome,
    );
  }

  static int countRentedProperties(List<Map<String, dynamic>> properties) {
    return properties.where((property) {
      final status = (_field(property, 'status') ?? '').toString().toLowerCase();
      return status.contains('rent') ||
          status.contains('occupied') ||
          status.contains('leased') ||
          status.contains('active');
    }).length;
  }

  static int countActiveContracts(List<Map<String, dynamic>> contracts) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return contracts.where((contract) {
      final endDate =
          _parseDate((_field(contract, 'endDate', 'end_date') ?? '').toString());
      final daysRemaining = endDate?.difference(today).inDays ?? 0;
      return _resolveContractStatusType(contract, daysRemaining) != 'ended';
    }).length;
  }

  static Map<String, dynamic> toReportTransaction(
    Map<String, dynamic> raw,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final tx = toWalletTransaction(raw, l10n, isArabic);
    return {
      'title': tx.title,
      'amount': tx.amount,
      'date': tx.dateLabel,
      'isIncome': tx.isIncome,
    };
  }

  static NotificationItemData toNotificationItem(Map<String, dynamic> raw) {
    final type = (_field(raw, 'type') ?? '').toString().toLowerCase();
    final title = (_field(raw, 'title') ?? '').toString();
    final message =
        (_field(raw, 'message', 'body') ?? _field(raw, 'description') ?? '')
            .toString();
    return NotificationItemData(
      id: (raw['id'] as num?)?.toInt(),
      type: type,
      title: title.isNotEmpty ? title : message,
      subtitle: title.isNotEmpty ? message : '',
      time: (_field(raw, 'createdAt', 'created_at') ?? _field(raw, 'time') ?? '-')
          .toString(),
      icon: _notificationIcon(type),
      iconColor: _notificationColor(type),
      unread: !_notificationIsRead(raw),
    );
  }

  static bool _notificationIsRead(Map<String, dynamic> raw) {
    if (raw['read'] == true || raw['is_read'] == true) return true;
    return _field(raw, 'readAt', 'read_at') != null;
  }

  static IconData _notificationIcon(String type) {
    if (type.contains('payment') || type.contains('rent')) {
      return Icons.account_balance_wallet;
    }
    if (type.contains('contract')) return Icons.warning_amber_rounded;
    if (type.contains('project') || type.contains('construction')) {
      return Icons.construction;
    }
    if (type.contains('legal')) return Icons.gavel;
    return Icons.notifications_outlined;
  }

  static Color _notificationColor(String type) {
    if (type.contains('payment') || type.contains('rent')) return Colors.green;
    if (type.contains('contract')) return Colors.orange;
    if (type.contains('project') || type.contains('construction')) {
      return AppColors.accentGold;
    }
    if (type.contains('legal')) return Colors.blue;
    return AppColors.accentGold;
  }

  static String _resolveContractStatusType(
    Map<String, dynamic> raw,
    int daysRemaining,
  ) {
    final explicit =
        (_field(raw, 'statusType', 'status_type') ?? '').toString().toLowerCase();
    if (explicit == 'active' ||
        explicit == 'expiring' ||
        explicit == 'ended') {
      return explicit;
    }

    final status = (_field(raw, 'status') ?? '').toString().toLowerCase();
    if (status.contains('ended') ||
        status.contains('termin') ||
        status.contains('cancel') ||
        status.contains('expired') ||
        status.contains('closed')) {
      return 'ended';
    }
    if (daysRemaining < 0) return 'ended';
    if (status.contains('expir') || daysRemaining <= 30) return 'expiring';
    return 'active';
  }

  static String _localizedTenantStatus(String? raw, AppLocalizations l10n) {
    final status = (raw ?? 'active').toLowerCase();
    if (status.contains('active')) return l10n.active;
    if (status.contains('inactive') || status.contains('ended')) {
      return l10n.ended;
    }
    return raw ?? l10n.active;
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty || value == '-') return null;

    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;

    final slash = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(value);
    if (slash != null) {
      return DateTime(
        int.parse(slash.group(3)!),
        int.parse(slash.group(2)!),
        int.parse(slash.group(1)!),
      );
    }
    return null;
  }

  static String _formatShortDate(DateTime? date) {
    if (date == null) return '-';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  static double? _parseAmount(dynamic value) {
    if (value == null) return null;
    final cleaned = value.toString().replaceAll(RegExp(r'[^\d.]'), '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  static String _formatThousands(int value) {
    final negative = value < 0;
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }
    return negative ? '-${buffer.toString()}' : buffer.toString();
  }

  static Map<String, dynamic> toProjectCard(
    Map<String, dynamic> raw,
    AppLocalizations l10n,
  ) {
    final id = (raw['id'] as num?)?.toInt();
    var progress = _parseAmount(
          _field(raw, 'progress') ??
              _field(raw, 'completionRate', 'completion_rate') ??
              _field(raw, 'completion'),
        ) ??
        0.5;
    if (progress > 1) progress = progress / 100;

    final totalCost = _parseAmount(
      _field(raw, 'totalCost', 'total_cost') ??
          _field(raw, 'cost') ??
          _field(raw, 'amount') ??
          _field(raw, 'budget'),
    );
    final paid = _parseAmount(
      _field(raw, 'paidAmount', 'paid_amount') ?? _field(raw, 'paid'),
    );
    final remaining = _parseAmount(
      _field(raw, 'remainingAmount', 'remaining_amount') ??
          _field(raw, 'remaining'),
    );

    final total = totalCost ?? 0;
    final paidVal = paid ?? (total * progress).roundToDouble();
    final remainVal = remaining ?? (total - paidVal).clamp(0, double.infinity);

    return {
      'id': id,
      'name': (_field(raw, 'name', 'title') ?? '-').toString(),
      'location': (_field(raw, 'location', 'address') ?? '').toString(),
      'progress': progress.clamp(0.0, 1.0),
      'startDate': _formatShortDate(
        _parseDate((_field(raw, 'startDate', 'start_date') ?? '').toString()),
      ),
      'expectedDate': _formatShortDate(
        _parseDate(
          (_field(raw, 'endDate', 'end_date') ??
                  _field(raw, 'expectedDate', 'expected_date') ??
                  '')
              .toString(),
        ),
      ),
      'totalCost': total > 0 ? _formatThousands(total.round()) : '0',
      'totalCostDisplay': total > 0
          ? '${_formatThousands(total.round())} ${l10n.aed}'
          : '0 ${l10n.aed}',
      'paidAmount':
          paidVal > 0 ? _formatThousands(paidVal.round()) : '0',
      'remainingAmount':
          remainVal > 0 ? _formatThousands(remainVal.round()) : '0',
      'imagePath': _imagePaths(raw).first,
    };
  }

  static Map<String, dynamic> toMapPropertyPin(
    Map<String, dynamic> raw,
    AppLocalizations l10n,
  ) {
    final card = toMyPropertyCard(raw, l10n);
    final lat = _parseAmount(_field(raw, 'latitude') ?? _field(raw, 'lat'));
    final lng =
        _parseAmount(_field(raw, 'longitude') ?? _field(raw, 'lng'));
    final rentRaw = _field(raw, 'rentAmount', 'rent_amount') ??
        _field(raw, 'monthlyRent', 'monthly_rent') ??
        _field(raw, 'monthlyRevenue', 'monthly_revenue');
    final rentNumeric = _parseAmount(rentRaw);
    final rentDisplay = rentNumeric != null
        ? '${_formatThousands(rentNumeric.round())} ${l10n.aed}'
        : (rentRaw?.toString() ?? '-');

    return {
      'id': card['id'],
      'name': card['name'],
      'location': card['location'],
      'latitude': lat ?? 24.7136,
      'longitude': lng ?? 46.6753,
      'statusType': card['statusType'],
      'statusColor': card['statusColor'],
      'rentAmount': rentDisplay,
    };
  }

  static Map<String, dynamic> toMaintenanceRequestCard(
    Map<String, dynamic> raw,
    AppLocalizations l10n,
  ) {
    final statusRaw = (_field(raw, 'status') ?? '').toString().toLowerCase();
    final statusType = _maintenanceStatusType(statusRaw);
    final problemType = (_field(raw, 'problemType', 'problem_type') ??
            _field(raw, 'title') ??
            _field(raw, 'type') ??
            l10n.maintenance)
        .toString();
    final id = (raw['id'] as num?)?.toInt();
    final orderNum = _field(raw, 'orderNumber', 'order_number');
    final orderLabel =
        orderNum != null ? '#$orderNum' : '#${id ?? '-'}';
    final dateRaw = (_field(raw, 'date', 'created_at') ?? '-').toString();

    return {
      'id': id,
      'title': problemType,
      'orderNumber': orderLabel,
      'date': _formatMaintenanceDate(dateRaw),
      'status': statusType == 'completed' ? l10n.completed : l10n.inProgress,
      'statusType': statusType,
      'icon': _maintenanceIcon(problemType),
      'iconColor': AppColors.accentGold,
    };
  }

  static Map<String, dynamic> toCalendarEvent(
    Map<String, dynamic> raw,
    AppLocalizations l10n,
  ) {
    final dateRaw = _field(raw, 'date', 'start_at')?.toString() ?? '';
    final parsed = DateTime.tryParse(dateRaw);
    final date = parsed != null
        ? DateTime(parsed.year, parsed.month, parsed.day)
        : DateTime.now();
    final amount = _field(raw, 'amount');
    return {
      'id': (raw['id'] as num?)?.toInt(),
      'date': date,
      'title': (_field(raw, 'title', 'name') ?? '-').toString(),
      'type': (_field(raw, 'type') ?? 'maintenance').toString(),
      'property': (_field(raw, 'propertyName', 'property_name') ??
              _field(raw, 'property') ??
              '-')
          .toString(),
      'time': (_field(raw, 'time', 'start_time') ?? '09:00').toString(),
      if (amount != null) 'amount': formatMoney(amount, l10n),
    };
  }

  static bool isUnderConstructionProject(Map<String, dynamic> raw) {
    final status = (_field(raw, 'status') ?? '').toString().toLowerCase();
    final type = (_field(raw, 'type') ?? '').toString().toLowerCase();
    return status.contains('construction') ||
        status.contains('under_construction') ||
        status.contains('building') ||
        type.contains('construction') ||
        type.contains('project');
  }

  static bool isProjectReport(Map<String, dynamic> raw) {
    final type = (_field(raw, 'type') ?? '').toString().toLowerCase();
    return type.contains('project') || type.contains('construction');
  }

  static String _maintenanceStatusType(String status) {
    if (status.contains('complete') ||
        status.contains('done') ||
        status.contains('closed') ||
        status.contains('resolved') ||
        status.contains('cancel')) {
      return 'completed';
    }
    return 'in_progress';
  }

  static IconData _maintenanceIcon(String problemType) {
    final type = problemType.toLowerCase();
    if (type.contains('ac') || type.contains('تكييف')) {
      return Icons.ac_unit;
    }
    if (type.contains('water') ||
        type.contains('plumb') ||
        type.contains('سباكة')) {
      return Icons.water_drop;
    }
    if (type.contains('electric') || type.contains('كهرب')) {
      return Icons.flash_on;
    }
    if (type.contains('clean')) return Icons.cleaning_services;
    return Icons.build;
  }

  static String _formatMaintenanceDate(String raw) {
    final parsed = _parseDate(raw);
    if (parsed != null) return _formatShortDate(parsed);
    return raw;
  }

  static Map<String, dynamic> toSearchResultCard(
    Map<String, dynamic> raw,
    AppLocalizations l10n, {
    bool isArabic = true,
  }) {
    final card = toMyPropertyCard(raw, l10n);
    final rentRaw = _field(raw, 'rentAmount', 'rent_amount') ??
        _field(raw, 'monthlyRent', 'monthly_rent') ??
        _field(raw, 'monthlyRevenue', 'monthly_revenue');
    final rentNumeric = _parseAmount(rentRaw);
    final price = rentNumeric != null
        ? '${_formatThousands(rentNumeric.round())} ${l10n.aed}/${l10n.perMonth}'
        : (rentRaw?.toString() ?? '-');
    final areaRaw = _field(raw, 'area');
    final areaNum = _parseAmount(areaRaw);
    final area = areaNum != null
        ? (isArabic ? '${areaNum.round()} م²' : '${areaNum.round()} m²')
        : (areaRaw?.toString() ?? '-');

    return {
      'id': card['id'],
      'name': card['name'],
      'location': card['location'],
      'fullLocation':
          (_field(raw, 'address') ?? card['location']).toString(),
      'price': price,
      'area': area,
      'detail': card['detail'],
    };
  }

  static Map<String, dynamic> toPaymentCard(
    Map<String, dynamic> raw,
    AppLocalizations l10n, {
    bool isArabic = true,
  }) {
    final amountRaw = _parseAmount(
          _field(raw, 'amount') ?? _field(raw, 'value'),
        ) ??
        0.0;
    final statusRaw = (_field(raw, 'status') ?? '').toString().toLowerCase();
    final paid = statusRaw.contains('paid') ||
        statusRaw.contains('completed') ||
        statusRaw.contains('success');
    final dateRaw = (_field(raw, 'payment_date', 'paymentDate') ??
            _field(raw, 'due_date', 'dueDate') ??
            _field(raw, 'created_at', 'createdAt') ??
            '')
        .toString();

    return {
      'id': (raw['id'] as num?)?.toInt(),
      'property': (_field(raw, 'property_name', 'propertyName') ??
              _field(raw, 'property') ??
              '-')
          .toString(),
      'tenant': (_field(raw, 'tenant_name', 'tenantName') ??
              _field(raw, 'tenant') ??
              '-')
          .toString(),
      'amount': _formatThousands(amountRaw.round()).toString(),
      'amountRaw': amountRaw,
      'date': _formatShortDate(_parseDate(dateRaw)),
      'statusType':
          paid ? LocalizedDemoData.filterPaid : LocalizedDemoData.filterPending,
      'type': (_field(raw, 'method') ?? _field(raw, 'type') ?? l10n.monthlyRent)
          .toString(),
    };
  }

  static List<String> extractUploadUrls(dynamic res) {
    if (res == null) return const [];

    final urls = <String>[];

    void addUrl(dynamic value) {
      if (value is String && value.trim().isNotEmpty) {
        urls.add(value.trim());
      } else if (value is Map) {
        final map = Map<String, dynamic>.from(value);
        final candidate = map['url'] ??
            map['path'] ??
            map['file_url'] ??
            map['fileUrl'] ??
            map['src'];
        if (candidate is String && candidate.trim().isNotEmpty) {
          urls.add(candidate.trim());
        }
      }
    }

    if (res is List) {
      for (final item in res) {
        addUrl(item);
      }
      return urls;
    }

    if (res is! Map) return const [];
    final map = Map<String, dynamic>.from(res);
    final data = map['data'];

    if (data is Map) {
      addUrl(data['url'] ?? data['path']);
      final files = data['files'] ?? data['items'] ?? data['urls'];
      if (files is List) {
        for (final item in files) {
          addUrl(item);
        }
      }
    } else if (data is List) {
      for (final item in data) {
        addUrl(item);
      }
    }

    addUrl(map['url'] ?? map['path']);
    final files = map['files'] ?? map['items'] ?? map['urls'];
    if (files is List) {
      for (final item in files) {
        addUrl(item);
      }
    }

    return urls;
  }
}

class WalletTransactionData {
  final String title;
  final String amount;
  final String dateLabel;
  final DateTime date;
  final bool isIncome;

  const WalletTransactionData({
    required this.title,
    required this.amount,
    required this.dateLabel,
    required this.date,
    required this.isIncome,
  });
}

class NotificationItemData {
  final int? id;
  final String type;
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool unread;

  const NotificationItemData({
    this.id,
    this.type = '',
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.unread = false,
  });

  NotificationItemData copyWith({bool? unread}) {
    return NotificationItemData(
      id: id,
      type: type,
      title: title,
      subtitle: subtitle,
      time: time,
      icon: icon,
      iconColor: iconColor,
      unread: unread ?? this.unread,
    );
  }
}
