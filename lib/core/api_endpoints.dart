/// Central list of REST endpoints expected from the future PHP backend.
/// Paths are relative to [AppConfig.apiBaseUrl].
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String google = '/auth/google';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String me = '/auth/me';

  // Business
  static const String business = '/business';
  static const String agent = '/agent';
  static const String agentTest = '/agent/test';
  static const String knowledge = '/agent/knowledge';

  // Dashboard
  static const String dashboard = '/dashboard';

  // Inbox
  static const String conversations = '/conversations';
  static String conversationMessages(String id) =>
      '/conversations/$id/messages';
  static String conversationHandover(String id) =>
      '/conversations/$id/handover';

  // Facebook comments
  static const String comments = '/comments';
  static String commentReply(String id) => '/comments/$id/reply';
  static String commentPrivateReply(String id) => '/comments/$id/private-reply';
  static const String commentRules = '/comments/rules';
  static const String commentLogs = '/comments/logs';

  // Catalog
  static const String products = '/products';
  static String product(String id) => '/products/$id';

  // Orders
  static const String orders = '/orders';
  static String order(String id) => '/orders/$id';
  static String orderStatus(String id) => '/orders/$id/status';

  // Courier
  static const String couriers = '/couriers';
  static const String shipments = '/shipments';

  // Automation & insights
  static const String automations = '/automations';
  static const String insights = '/insights';

  // Integrations
  static const String integrations = '/integrations';
  static String integrationConnect(String id) => '/integrations/$id/connect';
  static String integrationDisconnect(String id) =>
      '/integrations/$id/disconnect';

  // Account
  static const String subscription = '/subscription';
  static const String plans = '/plans';
  static const String notifications = '/notifications';
  static const String team = '/team';
  static const String profile = '/profile';
}
