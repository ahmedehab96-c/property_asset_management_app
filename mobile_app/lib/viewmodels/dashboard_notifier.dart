import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';

class DashboardState {
  final ViewStatus status;
  final double totalBalance;
  final String growthPercent;
  final String rentedPropertiesCount;
  final String activeContractsCount;
  final bool fromDemo;
  final String? errorMessage;

  const DashboardState({
    this.status = ViewStatus.idle,
    this.totalBalance = 2450000,
    this.growthPercent = '+12%',
    this.rentedPropertiesCount = '8',
    this.activeContractsCount = '12',
    this.fromDemo = true,
    this.errorMessage,
  });

  DashboardState copyWith({
    ViewStatus? status,
    double? totalBalance,
    String? growthPercent,
    String? rentedPropertiesCount,
    String? activeContractsCount,
    bool? fromDemo,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      totalBalance: totalBalance ?? this.totalBalance,
      growthPercent: growthPercent ?? this.growthPercent,
      rentedPropertiesCount:
          rentedPropertiesCount ?? this.rentedPropertiesCount,
      activeContractsCount: activeContractsCount ?? this.activeContractsCount,
      fromDemo: fromDemo ?? this.fromDemo,
      errorMessage: errorMessage,
    );
  }
}

class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() => const DashboardState();

  Future<void> load() async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    try {
      final result = await ref.read(dashboardRepositoryProvider).load();
      state = DashboardState(
        status: ViewStatus.success,
        totalBalance: result.totalBalance,
        growthPercent: result.growthPercent,
        rentedPropertiesCount: result.rentedPropertiesCount,
        activeContractsCount: result.activeContractsCount,
        fromDemo: result.fromDemo,
      );
    } catch (e) {
      state = state.copyWith(
        status: ViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final dashboardProvider =
    NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);
