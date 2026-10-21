import '../core/api_endpoints.dart';
import '../models/models.dart';
import 'api_client.dart';

/// Real API data layer. Returns only what the backend sends. It never invents
/// data: demo data lives in `demo_data.dart` and is applied by controllers.
class DataApi {
  DataApi(this._api);
  final ApiClient _api;

  bool get isConfigured => _api.isConfigured;

  List<Map<String, dynamic>> _items(dynamic res, [String key = 'items']) {
    if (res is List) {
      return res
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (res is Map && res[key] is List) {
      return (res[key] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> _obj(dynamic res) =>
      res is Map ? Map<String, dynamic>.from(res) : <String, dynamic>{};

  // Business and agent
  Future<BusinessProfile?> getBusiness() async {
    final res = _obj(await _api.get(ApiEndpoints.business));
    return res.isEmpty ? null : BusinessProfile.fromJson(res);
  }

  Future<void> saveBusiness(BusinessProfile b) =>
      _api.put(ApiEndpoints.business, body: b.toJson());

  Future<AgentSettings?> getAgent() async {
    final res = _obj(await _api.get(ApiEndpoints.agent));
    return res.isEmpty ? null : AgentSettings.fromJson(res);
  }

  Future<void> saveAgent(AgentSettings a) =>
      _api.put(ApiEndpoints.agent, body: a.toJson());

  Future<List<KnowledgeEntry>> getKnowledge() async =>
      _items(await _api.get(ApiEndpoints.knowledge))
          .map(KnowledgeEntry.fromJson)
          .toList();

  Future<String> testAgent(String message) async {
    final res = _obj(
      await _api.post(ApiEndpoints.agentTest, body: {'message': message}),
    );
    return J.s(res['reply']);
  }

  // Dashboard
  Future<DashboardStats> getDashboard() async =>
      DashboardStats.fromJson(_obj(await _api.get(ApiEndpoints.dashboard)));

  // Inbox
  Future<List<Conversation>> getConversations() async =>
      _items(await _api.get(ApiEndpoints.conversations))
          .map(Conversation.fromJson)
          .toList();

  Future<Message> sendMessage(String conversationId, String text) async {
    final res = _obj(
      await _api.post(
        ApiEndpoints.conversationMessages(conversationId),
        body: {'text': text},
      ),
    );
    return Message.fromJson(res);
  }

  Future<void> setHandover(String conversationId, bool human) => _api.post(
    ApiEndpoints.conversationHandover(conversationId),
    body: {'human': human},
  );

  // Comments
  Future<List<FbComment>> getComments() async =>
      _items(await _api.get(ApiEndpoints.comments))
          .map(FbComment.fromJson)
          .toList();

  Future<void> replyToComment(String id, String text) =>
      _api.post(ApiEndpoints.commentReply(id), body: {'text': text});

  Future<void> privateReplyToComment(String id, String text) =>
      _api.post(ApiEndpoints.commentPrivateReply(id), body: {'text': text});

  Future<List<CommentRule>> getCommentRules() async =>
      _items(await _api.get(ApiEndpoints.commentRules))
          .map(CommentRule.fromJson)
          .toList();

  Future<List<ActivityLog>> getCommentLogs() async =>
      _items(await _api.get(ApiEndpoints.commentLogs))
          .map(ActivityLog.fromJson)
          .toList();

  // Products
  Future<List<Product>> getProducts() async =>
      _items(await _api.get(ApiEndpoints.products))
          .map(Product.fromJson)
          .toList();

  Future<Product> createProduct(Product p) async => Product.fromJson(
    _obj(await _api.post(ApiEndpoints.products, body: p.toJson())),
  );

  Future<Product> updateProduct(Product p) async => Product.fromJson(
    _obj(await _api.put(ApiEndpoints.product(p.id), body: p.toJson())),
  );

  Future<void> deleteProduct(String id) =>
      _api.delete(ApiEndpoints.product(id));

  // Orders
  Future<List<Order>> getOrders() async =>
      _items(await _api.get(ApiEndpoints.orders)).map(Order.fromJson).toList();

  Future<void> updateOrderStatus(
    String id,
    OrderStatus status, {
    String? note,
  }) => _api.patch(
    ApiEndpoints.orderStatus(id),
    body: {'status': status.name, 'note': ?note},
  );

  // Couriers
  Future<List<CourierInfo>> getCouriers() async =>
      _items(await _api.get(ApiEndpoints.couriers))
          .map(CourierInfo.fromJson)
          .toList();

  Future<List<Shipment>> getShipments() async =>
      _items(await _api.get(ApiEndpoints.shipments))
          .map(Shipment.fromJson)
          .toList();

  Future<Shipment> createShipment({
    required String courierId,
    required String orderId,
    required double weightKg,
    required double cod,
  }) async => Shipment.fromJson(
    _obj(
      await _api.post(
        ApiEndpoints.shipments,
        body: {
          'courier_id': courierId,
          'order_id': orderId,
          'weight_kg': weightKg,
          'cod_amount': cod,
        },
      ),
    ),
  );

  // Automation
  Future<List<AutomationRule>> getAutomations() async =>
      _items(await _api.get(ApiEndpoints.automations))
          .map(AutomationRule.fromJson)
          .toList();

  // Integrations
  Future<List<IntegrationInfo>> getIntegrations() async =>
      _items(await _api.get(ApiEndpoints.integrations))
          .map(IntegrationInfo.fromJson)
          .toList();

  /// Returns the authorisation URL the backend wants the user to open.
  Future<String?> startConnect(String id) async {
    final res = _obj(await _api.post(ApiEndpoints.integrationConnect(id)));
    final url = res['authorize_url'];
    return url is String && url.isNotEmpty ? url : null;
  }

  Future<void> disconnect(String id) =>
      _api.post(ApiEndpoints.integrationDisconnect(id));

  // Account
  Future<List<Plan>> getPlans() async =>
      _items(await _api.get(ApiEndpoints.plans)).map(Plan.fromJson).toList();

  Future<Subscription> getSubscription() async =>
      Subscription.fromJson(_obj(await _api.get(ApiEndpoints.subscription)));

  Future<List<AppNotification>> getNotifications() async =>
      _items(await _api.get(ApiEndpoints.notifications))
          .map(AppNotification.fromJson)
          .toList();

  Future<List<TeamMember>> getTeam() async =>
      _items(await _api.get(ApiEndpoints.team))
          .map(TeamMember.fromJson)
          .toList();

  Future<void> inviteMember(String email, TeamRole role) =>
      _api.post(ApiEndpoints.team, body: {'email': email, 'role': role.name});
}
