import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Configuration
/// This file contains all API endpoints and configuration
/// Update the .env file with your Laravel API base URL
class ApiConfig {
  static const String _defaultBaseUrl = 'http://127.0.0.1:8000/api/v1';

  // Base URL - Loaded from .env file, or default if .env missing/not loaded
  static String get baseUrl {
    try {
      return dotenv.env['API_BASE_URL'] ?? _defaultBaseUrl;
    } catch (_) {
      return _defaultBaseUrl;
    }
  }
  
  // API Endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String user = '/auth/user';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/email/resend-verification';
  static const String changePassword = '/auth/change-password';
  static const String twoFactor = '/auth/two-factor';

  // Dashboard (Admin)
  static const String dashboardMetrics = '/dashboard/metrics';
  static const String dashboardActivities = '/dashboard/activities';
  static const String dashboardFinancialFlow = '/dashboard/financial-flow';
  static const String dashboardAlerts = '/dashboard/alerts';
  static const String dashboardQuickStats = '/dashboard/quick-stats';
  
  // Properties
  static const String properties = '/properties';
  static String propertyById(int id) => '/properties/$id';
  static String propertyStats(int id) => '/properties/$id/stats';
  static String propertyFinancial(int id) => '/properties/$id/financial';
  static const String propertiesSearch = '/properties/search';
  static const String propertiesFilter = '/properties/filter';
  
  // Tenants
  static const String tenants = '/tenants';
  static String tenantById(int id) => '/tenants/$id';
  static String tenantPayments(int id) => '/tenants/$id/payments';
  static String tenantContracts(int id) => '/tenants/$id/contracts';
  static String tenantHistory(int id) => '/tenants/$id/history';
  
  // Contracts
  static const String contracts = '/contracts';
  static String contractById(int id) => '/contracts/$id';
  static const String contractsExpiring = '/contracts/expiring';
  static String contractRenew(int id) => '/contracts/$id/renew';
  static String contractPayments(int id) => '/contracts/$id/payments';
  static String contractExtend(int id) => '/contracts/$id/extend';
  static String contractCancel(int id) => '/contracts/$id/cancel';

  // Owners
  static const String owners = '/owners';
  static String ownerById(int id) => '/owners/$id';
  static String ownerProperties(int id) => '/owners/$id/properties';
  static String ownerFinancial(int id) => '/owners/$id/financial';

  // Financial
  static const String transfers = '/transfers';
  static const String financialSummary = '/financial/summary';
  
  // Maintenance / Operations
  static const String maintenanceRequests = '/maintenance-requests';

  // Calendar
  static const String calendarEvents = '/calendar/events';
  static const String calendarEventsUpcoming = '/calendar/events/upcoming';

  // Tasks
  static const String tasks = '/tasks';
  static String taskById(int id) => '/tasks/$id';
  static String taskStatus(int id) => '/tasks/$id/status';

  // Messages
  static const String conversations = '/conversations';
  static String conversationMessages(int id) => '/conversations/$id/messages';

  // Projects
  static const String projects = '/projects';
  static String projectById(int id) => '/projects/$id';

  // Analytics
  static const String analyticsOverview = '/analytics/overview';
  static const String analyticsRevenue = '/analytics/revenue';
  static const String analyticsOccupancy = '/analytics/occupancy';
  static const String analyticsImageAnalysis = '/analytics/image-analysis';

  // Mobile app requests
  static const String mobileRequests = '/mobile-requests';
  
  // Payments
  static const String payments = '/payments';
  static String paymentById(int id) => '/payments/$id';
  static const String paymentsUpcoming = '/payments/upcoming';
  static const String paymentsOverdue = '/payments/overdue';
  static const String paymentsStatistics = '/payments/statistics';
  
  // Reports
  static const String reports = '/reports';
  static String reportById(int id) => '/reports/$id';
  static const String reportsFinancial = '/reports/financial';
  static const String reportsTenant = '/reports/tenant';
  static const String reportsProperty = '/reports/property';
  static const String reportsContract = '/reports/contract';
  
  // Services
  static const String services = '/services';
  static String serviceById(int id) => '/services/$id';
  static const String servicesMaintenance = '/services/maintenance';
  static const String servicesRepair = '/services/repair';
  static const String servicesLegal = '/services/legal';
  static const String servicesEngineering = '/services/engineering';
  static String serviceStatus(int id) => '/services/$id/status';
  
  // Users
  static const String users = '/users';
  static String userById(int id) => '/users/$id';
  static const String usersRegistrationRequests = '/users/registration-requests';
  static String userApprove(int id) => '/users/$id/approve';
  static String userReject(int id) => '/users/$id/reject';
  static String userProfile(int id) => '/users/$id/profile';
  
  // File Upload
  static const String uploadImage = '/upload/image';
  static const String uploadDocument = '/upload/document';
  static const String uploadMultiple = '/upload/multiple';
  static String uploadDelete(int id) => '/upload/$id';
  
  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnread = '/notifications/unread';
  static String notificationRead(int id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationDelete(int id) => '/notifications/$id';
  
  // Request timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static Map<String, String> getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  static Map<String, String> getMultipartHeaders(String? token) {
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
