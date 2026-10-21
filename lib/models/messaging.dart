import 'enums.dart';

class Message {
  const Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.sentAt,
    this.failed = false,
  });

  final String id;
  final String text;
  final SenderType sender;
  final DateTime sentAt;

  /// True when a manual reply could not be delivered by the backend.
  final bool failed;

  factory Message.fromJson(Map<String, dynamic> j) => Message(
    id: J.s(j['id']),
    text: J.s(j['text']),
    sender: enumByName(SenderType.values, j['sender'], SenderType.customer),
    sentAt: J.dt(j['sent_at']),
  );
}

class Customer {
  const Customer({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.totalOrders = 0,
    this.totalSpent = 0,
  });
  final String id;
  final String name;
  final String phone;
  final String email;
  final int totalOrders;
  final double totalSpent;

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
    id: J.s(j['id']),
    name: J.s(j['name']),
    phone: J.s(j['phone']),
    email: J.s(j['email']),
    totalOrders: J.i(j['total_orders']),
    totalSpent: J.d(j['total_spent']),
  );
}

class Conversation {
  const Conversation({
    required this.id,
    required this.customer,
    required this.channel,
    required this.messages,
    this.unreadCount = 0,
    this.humanHandled = false,
  });

  final String id;
  final Customer customer;
  final Channel channel;
  final List<Message> messages;
  final int unreadCount;
  final bool humanHandled;

  Message? get last => messages.isEmpty ? null : messages.last;
  DateTime get updatedAt =>
      last?.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  Conversation copyWith({
    List<Message>? messages,
    int? unreadCount,
    bool? humanHandled,
  }) => Conversation(
    id: id,
    customer: customer,
    channel: channel,
    messages: messages ?? this.messages,
    unreadCount: unreadCount ?? this.unreadCount,
    humanHandled: humanHandled ?? this.humanHandled,
  );

  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
    id: J.s(j['id']),
    customer: Customer.fromJson(
      Map<String, dynamic>.from(j['customer'] as Map? ?? {}),
    ),
    channel: enumByName(Channel.values, j['channel'], Channel.messenger),
    messages: J.list(j['messages']).map(Message.fromJson).toList(),
    unreadCount: J.i(j['unread_count']),
    humanHandled: J.b(j['human_handled']),
  );
}
