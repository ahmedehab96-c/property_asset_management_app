import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/providers/service_providers.dart';
import 'package:property_asset_management_app/repositories/calendar_repository.dart';
import 'package:property_asset_management_app/repositories/contract_repository.dart';
import 'package:property_asset_management_app/repositories/dashboard_repository.dart';
import 'package:property_asset_management_app/repositories/lawsuit_repository.dart';
import 'package:property_asset_management_app/repositories/maintenance_repository.dart';
import 'package:property_asset_management_app/repositories/maps_repository.dart';
import 'package:property_asset_management_app/repositories/notification_repository.dart';
import 'package:property_asset_management_app/repositories/payments_repository.dart';
import 'package:property_asset_management_app/repositories/project_repository.dart';
import 'package:property_asset_management_app/repositories/property_repository.dart';
import 'package:property_asset_management_app/repositories/report_repository.dart';
import 'package:property_asset_management_app/repositories/search_repository.dart';
import 'package:property_asset_management_app/repositories/service_request_repository.dart';
import 'package:property_asset_management_app/repositories/tenant_repository.dart';
import 'package:property_asset_management_app/repositories/wallet_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(
    ref.watch(ownerApiServiceProvider),
    ref.watch(userProfileServiceProvider),
  ),
);

final propertyRepositoryProvider = Provider<PropertyRepository>(
  (ref) => PropertyRepository(ref.watch(ownerApiServiceProvider)),
);

final contractRepositoryProvider = Provider<ContractRepository>(
  (ref) => ContractRepository(ref.watch(ownerApiServiceProvider)),
);

final tenantRepositoryProvider = Provider<TenantRepository>(
  (ref) => TenantRepository(ref.watch(ownerApiServiceProvider)),
);

final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => WalletRepository(
    ref.watch(ownerApiServiceProvider),
    ref.watch(userProfileServiceProvider),
  ),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(ref.watch(ownerApiServiceProvider)),
);

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>(
  (ref) => MaintenanceRepository(ref.watch(ownerApiServiceProvider)),
);

final calendarRepositoryProvider = Provider<CalendarRepository>(
  (ref) => CalendarRepository(ref.watch(ownerApiServiceProvider)),
);

final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => ProjectRepository(ref.watch(ownerApiServiceProvider)),
);

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => ReportRepository(
    ref.watch(ownerApiServiceProvider),
    ref.watch(userProfileServiceProvider),
  ),
);

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(ref.watch(ownerApiServiceProvider)),
);

final mapsRepositoryProvider = Provider<MapsRepository>(
  (ref) => MapsRepository(ref.watch(ownerApiServiceProvider)),
);

final lawsuitRepositoryProvider = Provider<LawsuitRepository>(
  (ref) => LawsuitRepository(ref.watch(ownerApiServiceProvider)),
);

final serviceRequestRepositoryProvider = Provider<ServiceRequestRepository>(
  (ref) => ServiceRequestRepository(ref.watch(ownerApiServiceProvider)),
);

final paymentsRepositoryProvider = Provider<PaymentsRepository>(
  (ref) => PaymentsRepository(ref.watch(ownerApiServiceProvider)),
);
