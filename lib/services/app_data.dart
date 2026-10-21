import 'package:flutter/foundation.dart';

import '../core/app_config.dart';
import '../core/load_state.dart';
import '../models/models.dart';
import 'api_exception.dart';
import 'data_api.dart';
import 'demo_data.dart';

/// Central store for business data shown in the app.
///
/// Rules:
/// * With a configured backend and a real session, data comes from [DataApi].
///   A failed request shows an error/offline state, never silently fake data.
/// * In explicit demo mode (or when no backend is configured and demo data is
///   allowed) the sample data from [DemoData] is used and [source] is
///   [DataSource.demo], so the UI can label it.
/// * Local edits (products, orders, rules...) are **not** confirmed. They are
///   kept in memory for the preview and the UI says so.
class AppData extends ChangeNotifier {
  AppData(this._api);
  final DataApi _api;

  bool _demo = false;

  LoadStatus status = LoadStatus.idle;
  DataSource source = DataSource.none;
  String? errorMessage;

  DashboardStats stats = const DashboardStats();
  BusinessProfile business = const BusinessProfile();
  AgentSettings agent = const AgentSettings();
  List<KnowledgeEntry> knowledge = [];
  List<Conversation> conversations = [];
  List<FbComment> comments = [];
  List<CommentRule> commentRules = [];
  List<ActivityLog> commentLogs = [];
  ModerationSettings moderation = const ModerationSettings();
  List<Product> products = [];
  List<Order> orders = [];
  List<CourierInfo> couriers = [];
  List<Shipment> shipments = [];
  List<AutomationRule> automations = [];
  List<IntegrationInfo> integrations = [];
  List<Plan> plans = [];
  Subscription? subscription;
  List<AppNotification> notifications = [];
  List<TeamMember> team = [];

  bool get isDemo => source == DataSource.demo;
  bool get backendConfigured => _api.isConfigured;

  int get connectedChannels => integrations
      .where(
        (i) =>
            (i.id == 'messenger' || i.id == 'whatsapp' || i.id == 'comments') &&
            i.state == LinkState.connected,
      )
      .length;
  int get totalChannels => integrations.where((i) => i.id != 'website').length;

  List<Product> get lowStockProducts => products
      .where(
        (p) =>
            p.stockLevel != StockLevel.inStock &&
            p.status != ProductStatus.archived,
      )
      .toList();

  int get unreadNotifications => notifications.where((n) => !n.read).length;

  /// Loads everything for the current session.
  Future<void> load({required bool demoSession}) async {
    _demo = demoSession;
    errorMessage = null;
    status = LoadStatus.loading;
    notifyListeners();

    if (demoSession && AppConfig.useDemoData) {
      _applyDemo();
      return;
    }
    if (!_api.isConfigured) {
      _clear();
      status = LoadStatus.ready;
      source = DataSource.none;
      notifyListeners();
      return;
    }
    await _loadFromApi();
  }

  Future<void> refresh() => load(demoSession: _demo);

  void _applyDemo() {
    business = DemoData.business;
    agent = DemoData.agent;
    knowledge = DemoData.knowledge();
    conversations = DemoData.conversations();
    comments = DemoData.comments();
    commentRules = DemoData.commentRules();
    commentLogs = DemoData.commentLogs();
    products = DemoData.products();
    orders = DemoData.orders();
    couriers = DemoData.couriers();
    shipments = [];
    automations = DemoData.automations();
    integrations = DemoData.integrations();
    plans = DemoData.plans();
    subscription = DemoData.subscription;
    notifications = DemoData.notifications();
    team = DemoData.team();
    stats = DemoData.stats;
    source = DataSource.demo;
    status = LoadStatus.ready;
    notifyListeners();
  }

  void _clear() {
    business = const BusinessProfile();
    agent = const AgentSettings();
    knowledge = [];
    conversations = [];
    comments = [];
    commentRules = [];
    commentLogs = [];
    products = [];
    orders = [];
    couriers = DemoData.couriers()
        .map((c) => CourierInfo(id: c.id, name: c.name))
        .toList(); // names only, all not connected
    shipments = [];
    automations = [];
    integrations = const [
      IntegrationInfo(id: 'messenger', nameKey: 'facebook_messenger'),
      IntegrationInfo(id: 'whatsapp', nameKey: 'whatsapp_business'),
      IntegrationInfo(id: 'comments', nameKey: 'facebook_comments'),
      IntegrationInfo(id: 'website', nameKey: 'website_domain_settings'),
    ];
    plans = [];
    subscription = null;
    notifications = [];
    team = [];
    stats = const DashboardStats();
  }

  /// Fetches every dataset. Individual optional datasets fall back to empty so
  /// that one missing endpoint does not hide the rest of the app.
  Future<void> _loadFromApi() async {
    _clear();
    try {
      stats = await _api.getDashboard();
      final results = await Future.wait<Object?>([
        _optional(_api.getBusiness()),
        _optional(_api.getAgent()),
        _optional(_api.getKnowledge()),
        _optional(_api.getConversations()),
        _optional(_api.getComments()),
        _optional(_api.getCommentRules()),
        _optional(_api.getCommentLogs()),
        _optional(_api.getProducts()),
        _optional(_api.getOrders()),
        _optional(_api.getCouriers()),
        _optional(_api.getShipments()),
        _optional(_api.getAutomations()),
        _optional(_api.getIntegrations()),
        _optional(_api.getPlans()),
        _optional(_api.getSubscription()),
        _optional(_api.getNotifications()),
        _optional(_api.getTeam()),
      ]);
      business = (results[0] as BusinessProfile?) ?? business;
      agent = (results[1] as AgentSettings?) ?? agent;
      knowledge = (results[2] as List<KnowledgeEntry>?) ?? [];
      conversations = (results[3] as List<Conversation>?) ?? [];
      comments = (results[4] as List<FbComment>?) ?? [];
      commentRules = (results[5] as List<CommentRule>?) ?? [];
      commentLogs = (results[6] as List<ActivityLog>?) ?? [];
      products = (results[7] as List<Product>?) ?? [];
      orders = (results[8] as List<Order>?) ?? [];
      final c = results[9] as List<CourierInfo>?;
      if (c != null && c.isNotEmpty) couriers = c;
      shipments = (results[10] as List<Shipment>?) ?? [];
      automations = (results[11] as List<AutomationRule>?) ?? [];
      final integ = results[12] as List<IntegrationInfo>?;
      if (integ != null && integ.isNotEmpty) integrations = integ;
      plans = (results[13] as List<Plan>?) ?? [];
      subscription = results[14] as Subscription?;
      notifications = (results[15] as List<AppNotification>?) ?? [];
      team = (results[16] as List<TeamMember>?) ?? [];
      source = DataSource.api;
      status = LoadStatus.ready;
    } on ApiException catch (e) {
      source = DataSource.none;
      errorMessage = e.message;
      status = e.isOffline ? LoadStatus.offline : LoadStatus.error;
    }
    notifyListeners();
  }

  /// Runs an optional request; a non-fatal failure becomes null. Session
  /// expiry and connectivity loss still propagate.
  Future<Object?> _optional<T extends Object?>(Future<T> f) async {
    try {
      return await f;
    } on ApiException catch (e) {
      if (e.isSessionExpired || e.isOffline) rethrow;
      return null;
    }
  }

  // ---- Local, unconfirmed edits -------------------------------------------------

  void saveAgentLocal(AgentSettings a) {
    agent = a;
    notifyListeners();
  }

  void saveBusinessLocal(BusinessProfile b) {
    business = b;
    notifyListeners();
  }

  void upsertKnowledge(KnowledgeEntry e) {
    final i = knowledge.indexWhere((k) => k.id == e.id);
    knowledge = [...knowledge];
    if (i >= 0) {
      knowledge[i] = e;
    } else {
      knowledge.add(e);
    }
    notifyListeners();
  }

  void removeKnowledge(String id) {
    knowledge = knowledge.where((k) => k.id != id).toList();
    notifyListeners();
  }

  void upsertProduct(Product p) {
    final i = products.indexWhere((x) => x.id == p.id);
    products = [...products];
    if (i >= 0) {
      products[i] = p;
    } else {
      products.insert(0, p);
    }
    notifyListeners();
  }

  void removeProduct(String id) {
    products = products.where((p) => p.id != id).toList();
    notifyListeners();
  }

  void setOrderStatus(String id, OrderStatus s) {
    orders = [for (final o in orders) o.id == id ? o.copyWith(status: s) : o];
    notifyListeners();
  }

  void setOrderNote(String id, String note) {
    orders = [for (final o in orders) o.id == id ? o.copyWith(note: note) : o];
    notifyListeners();
  }

  void markConversationRead(String id) {
    conversations = [
      for (final c in conversations)
        c.id == id ? c.copyWith(unreadCount: 0) : c,
    ];
    notifyListeners();
  }

  void setHandover(String id, bool human) {
    conversations = [
      for (final c in conversations)
        c.id == id ? c.copyWith(humanHandled: human) : c,
    ];
    notifyListeners();
  }

  void upsertAutomation(AutomationRule r) {
    final i = automations.indexWhere((x) => x.id == r.id);
    automations = [...automations];
    if (i >= 0) {
      automations[i] = r;
    } else {
      automations.insert(0, r);
    }
    notifyListeners();
  }

  void removeAutomation(String id) {
    automations = automations.where((r) => r.id != id).toList();
    notifyListeners();
  }

  void upsertCommentRule(CommentRule r) {
    final i = commentRules.indexWhere((x) => x.id == r.id);
    commentRules = [...commentRules];
    if (i >= 0) {
      commentRules[i] = r;
    } else {
      commentRules.insert(0, r);
    }
    notifyListeners();
  }

  void removeCommentRule(String id) {
    commentRules = commentRules.where((r) => r.id != id).toList();
    notifyListeners();
  }

  void updateComment(FbComment c) {
    comments = [for (final x in comments) x.id == c.id ? c : x];
    notifyListeners();
  }

  void setModeration(ModerationSettings m) {
    moderation = m;
    notifyListeners();
  }

  void markNotificationsRead() {
    notifications = notifications.map((n) => n.markRead()).toList();
    notifyListeners();
  }

  void addPendingMember(TeamMember m) {
    team = [...team, m];
    notifyListeners();
  }

  // ---- Backend-confirmed operations --------------------------------------------

  /// Sends a manual reply. Returns null on confirmed success, else an error
  /// localisation key. The message is only added to the thread when confirmed.
  Future<String?> sendReply(String conversationId, String text) async {
    if (isDemo || !_api.isConfigured) return 'send_needs_backend';
    try {
      final m = await _api.sendMessage(conversationId, text);
      conversations = [
        for (final c in conversations)
          c.id == conversationId ? c.copyWith(messages: [...c.messages, m]) : c,
      ];
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.isOffline ? 'offline_msg' : 'send_failed';
    }
  }

  /// Persists an order status change via the API. Returns an error key or null
  /// when the backend confirmed the change. Never claims success on its own.
  Future<String?> confirmOrderStatus(String id, OrderStatus s) async {
    if (isDemo || !_api.isConfigured) {
      setOrderStatus(id, s);
      return 'status_change_local';
    }
    try {
      await _api.updateOrderStatus(id, s);
      setOrderStatus(id, s);
      return null;
    } on ApiException catch (e) {
      return e.isOffline ? 'offline_msg' : 'error_generic';
    }
  }

  /// Saves a product. Returns null when the backend confirmed it, otherwise a
  /// notice key explaining that the product exists on this device only.
  Future<String?> saveProduct(Product p, {required bool isNew}) async {
    if (isDemo || !_api.isConfigured) {
      upsertProduct(p);
      return 'product_saved_local';
    }
    try {
      final saved = isNew
          ? await _api.createProduct(p)
          : await _api.updateProduct(p);
      upsertProduct(saved);
      return null;
    } on ApiException catch (e) {
      return e.isOffline ? 'offline_msg' : 'error_generic';
    }
  }

  Future<String?> deleteProduct(String id) async {
    if (isDemo || !_api.isConfigured) {
      removeProduct(id);
      return 'product_saved_local';
    }
    try {
      await _api.deleteProduct(id);
      removeProduct(id);
      return null;
    } on ApiException catch (e) {
      return e.isOffline ? 'offline_msg' : 'error_generic';
    }
  }

  /// Starts the backend-driven connect flow. Returns the authorisation URL or
  /// an error key. Nothing is marked connected locally.
  Future<({String? url, String? errorKey})> startConnect(String id) async {
    if (isDemo || !_api.isConfigured) {
      return (url: null, errorKey: 'oauth_not_available');
    }
    try {
      final url = await _api.startConnect(id);
      return (url: url, errorKey: url == null ? 'error_generic' : null);
    } on ApiException catch (e) {
      return (
        url: null,
        errorKey: e.isOffline ? 'offline_msg' : 'error_generic',
      );
    }
  }

  Future<String?> disconnect(String id) async {
    if (isDemo || !_api.isConfigured) return 'oauth_not_available';
    try {
      await _api.disconnect(id);
      await refresh();
      return null;
    } on ApiException catch (e) {
      return e.isOffline ? 'offline_msg' : 'error_generic';
    }
  }

  Future<String?> testAgent(
    String message,
    void Function(String reply) onReply,
  ) async {
    if (isDemo || !_api.isConfigured) return 'test_unavailable_msg';
    try {
      final r = await _api.testAgent(message);
      if (r.isEmpty) return 'test_unavailable_msg';
      onReply(r);
      return null;
    } on ApiException catch (e) {
      return e.isOffline ? 'offline_msg' : 'test_unavailable_msg';
    }
  }
}
