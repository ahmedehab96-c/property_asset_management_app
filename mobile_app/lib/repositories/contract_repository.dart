import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/demo_mode.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

class ContractsLoadResult {
  final List<Map<String, dynamic>> contracts;
  final bool fromDemo;
  final bool hasMore;

  const ContractsLoadResult({
    required this.contracts,
    required this.fromDemo,
    this.hasMore = false,
  });
}

class ContractDetailLoadResult {
  final Map<String, dynamic> contract;
  final bool fromDemo;

  const ContractDetailLoadResult({
    required this.contract,
    required this.fromDemo,
  });
}

class ContractOperationResult {
  final bool success;
  final bool fromDemo;
  final String? message;

  const ContractOperationResult({
    required this.success,
    this.fromDemo = false,
    this.message,
  });
}

/// عقود المالك: API أولاً، ثم بيانات تجريبية عند الفشل أو الوضع التجريبي.
class ContractRepository {
  ContractRepository([OwnerApiService? api]) : _api = api ?? OwnerApiService();

  final OwnerApiService _api;

  static const defaultPerPage = 20;

  List<Map<String, dynamic>> _demoContracts(
    AppLocalizations l10n,
    bool isArabic,
  ) =>
      LocalizedDemoData(l10n: l10n, isArabic: isArabic).contracts();

  Future<ContractsLoadResult> loadContracts({
    required AppLocalizations l10n,
    required bool isArabic,
    int page = 1,
    int perPage = defaultPerPage,
  }) async {
    if (DemoMode.isActive) {
      return ContractsLoadResult(
        contracts: _demoContracts(l10n, isArabic),
        fromDemo: true,
      );
    }

    try {
      final raw = await _api.getContracts(
        query: {'page': page, 'per_page': perPage},
      );
      final mapped =
          raw.map((c) => OwnerApiMappers.toContractCard(c, l10n)).toList();
      return ContractsLoadResult(
        contracts: mapped,
        fromDemo: false,
        hasMore: raw.length >= perPage,
      );
    } catch (_) {
      return const ContractsLoadResult(contracts: [], fromDemo: false);
    }
  }

  Future<ContractDetailLoadResult> loadContractDetailForScreen({
    required Map<String, dynamic> seed,
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    final demo = LocalizedDemoData(l10n: l10n, isArabic: isArabic);
    final id = (seed['id'] as num?)?.toInt();
    if (DemoMode.isActive || id == null) {
      return ContractDetailLoadResult(
        contract: demo.enrichContractDetail(
          Map<String, dynamic>.from(seed),
          fillMissingWithDemo: true,
        ),
        fromDemo: true,
      );
    }

    try {
      final raw = await _api.getContractDetail(id);
      if (raw != null) {
        final card = OwnerApiMappers.toContractCard(raw, l10n);
        return ContractDetailLoadResult(
          contract: demo.enrichContractDetail(
            {...seed, ...card, ...raw},
            fillMissingWithDemo: false,
          ),
          fromDemo: false,
        );
      }
    } catch (_) {}

    return ContractDetailLoadResult(
      contract: demo.enrichContractDetail(
        Map<String, dynamic>.from(seed),
        fillMissingWithDemo: false,
      ),
      fromDemo: false,
    );
  }

  Future<ContractOperationResult> extendContract({
    required int? contractId,
    required DateTime newEndDate,
    String? notes,
  }) async {
    if (DemoMode.isActive || contractId == null) {
      return const ContractOperationResult(success: true, fromDemo: true);
    }

    try {
      await _api.extendContract(contractId, {
        'end_date': _formatApiDate(newEndDate),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      });
      return const ContractOperationResult(success: true);
    } catch (e) {
      return ContractOperationResult(success: false, message: e.toString());
    }
  }

  Future<ContractOperationResult> cancelContract({
    required int? contractId,
    required String reasonKey,
    String? details,
  }) async {
    if (DemoMode.isActive || contractId == null) {
      return const ContractOperationResult(success: true, fromDemo: true);
    }

    try {
      await _api.cancelContract(contractId, {
        'reason': reasonKey,
        if (details != null && details.trim().isNotEmpty) 'details': details.trim(),
      });
      return const ContractOperationResult(success: true);
    } catch (e) {
      return ContractOperationResult(success: false, message: e.toString());
    }
  }

  static String _formatApiDate(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
