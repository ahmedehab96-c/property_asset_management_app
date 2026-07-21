import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/repositories/service_request_repository.dart';

class ServiceRequestState {
  final ViewStatus status;
  final String? errorMessage;

  const ServiceRequestState({
    this.status = ViewStatus.idle,
    this.errorMessage,
  });

  ServiceRequestState copyWith({
    ViewStatus? status,
    String? errorMessage,
  }) {
    return ServiceRequestState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class ServiceRequestNotifier extends Notifier<ServiceRequestState> {
  @override
  ServiceRequestState build() => const ServiceRequestState();

  Future<ServiceRequestResult> submit({
    required String serviceType,
    required String description,
    String? priority,
    String? cleaningType,
    String? scheduledAt,
    String? notes,
    int? propertyId,
    List<String> imagePaths = const [],
  }) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    final result = await ref.read(serviceRequestRepositoryProvider).submit(
          serviceType: serviceType,
          description: description,
          priority: priority,
          cleaningType: cleaningType,
          scheduledAt: scheduledAt,
          notes: notes,
          propertyId: propertyId,
          imagePaths: imagePaths,
        );
    state = state.copyWith(
      status: result.success ? ViewStatus.success : ViewStatus.error,
      errorMessage: result.success ? null : result.message,
    );
    return result;
  }
}

final serviceRequestProvider = NotifierProvider<ServiceRequestNotifier, ServiceRequestState>(
  ServiceRequestNotifier.new,
);
