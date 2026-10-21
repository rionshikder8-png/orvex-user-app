enum Channel { messenger, whatsapp }

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

enum PaymentStatus { unpaid, cod, paid, refunded }

enum ProductStatus { published, draft, archived }

enum StockLevel { inStock, low, out }

enum CommentReplyStatus { pending, awaitingApproval, replied, hidden, failed }

enum LinkState { notConnected, connected, error }

enum CommentAction { publicReply, privateMessage, both }

enum RuleTrigger { keyword, newOrder, lowStock, noReply }

enum RuleAction { aiReply, notifyTeam, tagConversation, handover }

enum SenderType { customer, ai, agent }

enum TeamRole { owner, manager, support }

T enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  if (name is! String) return fallback;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

String _str(Object? v, [String d = '']) =>
    v is String ? v : (v?.toString() ?? d);
int _int(Object? v, [int d = 0]) =>
    v is int ? v : (v is num ? v.toInt() : (int.tryParse('$v') ?? d));
double _dbl(Object? v, [double d = 0]) =>
    v is num ? v.toDouble() : (double.tryParse('$v') ?? d);
bool _bool(Object? v, [bool d = false]) => v is bool ? v : d;
DateTime _date(Object? v) =>
    (v is String ? DateTime.tryParse(v) : null) ??
    DateTime.fromMillisecondsSinceEpoch(0);

/// Small parsing helpers shared by the model `fromJson` constructors.
class J {
  J._();
  static String s(Object? v, [String d = '']) => _str(v, d);
  static int i(Object? v, [int d = 0]) => _int(v, d);
  static double d(Object? v, [double d = 0]) => _dbl(v, d);
  static bool b(Object? v, [bool d = false]) => _bool(v, d);
  static DateTime dt(Object? v) => _date(v);
  static List<Map<String, dynamic>> list(Object? v) => v is List
      ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : <Map<String, dynamic>>[];
}
