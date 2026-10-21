import 'enums.dart';

class AutomationRule {
  const AutomationRule({
    required this.id,
    required this.name,
    required this.trigger,
    required this.action,
    this.conditionValue = '',
    this.enabled = true,
  });

  final String id;
  final String name;
  final RuleTrigger trigger;
  final RuleAction action;
  final String conditionValue;
  final bool enabled;

  AutomationRule copyWith({
    String? name,
    RuleTrigger? trigger,
    RuleAction? action,
    String? conditionValue,
    bool? enabled,
  }) => AutomationRule(
    id: id,
    name: name ?? this.name,
    trigger: trigger ?? this.trigger,
    action: action ?? this.action,
    conditionValue: conditionValue ?? this.conditionValue,
    enabled: enabled ?? this.enabled,
  );

  factory AutomationRule.fromJson(Map<String, dynamic> j) => AutomationRule(
    id: J.s(j['id']),
    name: J.s(j['name']),
    trigger: enumByName(RuleTrigger.values, j['trigger'], RuleTrigger.keyword),
    action: enumByName(RuleAction.values, j['action'], RuleAction.aiReply),
    conditionValue: J.s(j['condition_value']),
    enabled: J.b(j['enabled'], true),
  );
}

class IntegrationInfo {
  const IntegrationInfo({
    required this.id,
    required this.nameKey,
    this.state = LinkState.notConnected,
    this.accountLabel = '',
    this.permissions = const {},
    this.errorMessage = '',
  });

  /// `messenger`, `whatsapp`, `comments` or `website`.
  final String id;
  final String nameKey;
  final LinkState state;
  final String accountLabel;

  /// permission key -> granted
  final Map<String, bool> permissions;
  final String errorMessage;

  factory IntegrationInfo.fromJson(Map<String, dynamic> j) => IntegrationInfo(
    id: J.s(j['id']),
    nameKey: J.s(j['name_key'], J.s(j['id'])),
    state: enumByName(LinkState.values, j['state'], LinkState.notConnected),
    accountLabel: J.s(j['account_label']),
    permissions: (j['permissions'] is Map)
        ? Map<String, bool>.from(
            (j['permissions'] as Map).map((k, v) => MapEntry('$k', v == true)),
          )
        : <String, bool>{},
    errorMessage: J.s(j['error_message']),
  );
}

class CourierInfo {
  const CourierInfo({
    required this.id,
    required this.name,
    this.state = LinkState.notConnected,
  });
  final String id; // pathao | steadfast | redx
  final String name;
  final LinkState state;

  factory CourierInfo.fromJson(Map<String, dynamic> j) => CourierInfo(
    id: J.s(j['id']),
    name: J.s(j['name']),
    state: enumByName(LinkState.values, j['state'], LinkState.notConnected),
  );
}

class Shipment {
  const Shipment({
    required this.id,
    required this.courierId,
    required this.orderNumber,
    required this.trackingId,
    required this.status,
    required this.createdAt,
  });
  final String id;
  final String courierId;
  final String orderNumber;
  final String trackingId;
  final String status;
  final DateTime createdAt;

  factory Shipment.fromJson(Map<String, dynamic> j) => Shipment(
    id: J.s(j['id']),
    courierId: J.s(j['courier_id']),
    orderNumber: J.s(j['order_number']),
    trackingId: J.s(j['tracking_id']),
    status: J.s(j['status']),
    createdAt: J.dt(j['created_at']),
  );
}

class Plan {
  const Plan({
    required this.id,
    required this.nameKey,
    required this.priceMonthly,
    required this.conversations,
    required this.aiReplies,
    required this.teamSeats,
    required this.products,
  });
  final String id;
  final String nameKey;
  final double priceMonthly;
  final int conversations;
  final int aiReplies;
  final int teamSeats;
  final int products;

  factory Plan.fromJson(Map<String, dynamic> j) => Plan(
    id: J.s(j['id']),
    nameKey: J.s(j['name_key']),
    priceMonthly: J.d(j['price_monthly']),
    conversations: J.i(j['conversations']),
    aiReplies: J.i(j['ai_replies']),
    teamSeats: J.i(j['team_seats']),
    products: J.i(j['products']),
  );
}

class Subscription {
  const Subscription({
    required this.planId,
    required this.usedConversations,
    required this.usedAiReplies,
    required this.usedSeats,
    required this.usedProducts,
    this.renewsAt,
  });
  final String planId;
  final int usedConversations;
  final int usedAiReplies;
  final int usedSeats;
  final int usedProducts;
  final DateTime? renewsAt;

  factory Subscription.fromJson(Map<String, dynamic> j) => Subscription(
    planId: J.s(j['plan_id']),
    usedConversations: J.i(j['used_conversations']),
    usedAiReplies: J.i(j['used_ai_replies']),
    usedSeats: J.i(j['used_seats']),
    usedProducts: J.i(j['used_products']),
    renewsAt: j['renews_at'] == null ? null : J.dt(j['renews_at']),
  );
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.at,
    this.read = false,
  });
  final String id;
  final String title;
  final String body;
  final DateTime at;
  final bool read;

  AppNotification markRead() =>
      AppNotification(id: id, title: title, body: body, at: at, read: true);

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id: J.s(j['id']),
    title: J.s(j['title']),
    body: J.s(j['body']),
    at: J.dt(j['at']),
    read: J.b(j['read']),
  );
}

class TeamMember {
  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.pending = false,
  });
  final String id;
  final String name;
  final String email;
  final TeamRole role;
  final bool pending;

  factory TeamMember.fromJson(Map<String, dynamic> j) => TeamMember(
    id: J.s(j['id']),
    name: J.s(j['name']),
    email: J.s(j['email']),
    role: enumByName(TeamRole.values, j['role'], TeamRole.support),
    pending: J.b(j['pending']),
  );
}

class DashboardStats {
  const DashboardStats({
    this.totalOrders = 0,
    this.pendingOrders = 0,
    this.revenue = 0,
    this.aiReplies = 0,
    this.aiReplyLimit = 0,
    this.revenueSeries = const [],
  });
  final int totalOrders;
  final int pendingOrders;
  final double revenue;
  final int aiReplies;
  final int aiReplyLimit;

  /// Last 7 days of revenue, oldest first. Empty means no data.
  final List<double> revenueSeries;

  factory DashboardStats.fromJson(Map<String, dynamic> j) => DashboardStats(
    totalOrders: J.i(j['total_orders']),
    pendingOrders: J.i(j['pending_orders']),
    revenue: J.d(j['revenue']),
    aiReplies: J.i(j['ai_replies']),
    aiReplyLimit: J.i(j['ai_reply_limit']),
    revenueSeries: (j['revenue_series'] is List)
        ? (j['revenue_series'] as List).map((e) => J.d(e)).toList()
        : <double>[],
  );
}
