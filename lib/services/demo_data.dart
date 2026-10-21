import '../models/models.dart';

/// ----------------------------------------------------------------------------
/// DEMO DATA ONLY.
/// Every value here is fictional sample content used to preview the interface.
/// It is kept apart from `data_api.dart` (the real API layer) and the UI always
/// labels it as demo data. Names, numbers and addresses do not belong to real
/// people or businesses.
/// ----------------------------------------------------------------------------
class DemoData {
  DemoData._();

  static DateTime _ago({int minutes = 0, int hours = 0, int days = 0}) =>
      DateTime.now().subtract(
        Duration(minutes: minutes, hours: hours, days: days),
      );

  static const BusinessProfile business = BusinessProfile(
    name: 'Demo Fashion House',
    type: 'type_fashion',
    website: 'demo-fashion.example',
    contactEmail: 'hello@demo-fashion.example',
    contactPhone: '01700000000',
    description: 'Sample business used for previewing Orvex Ai.',
    defaultLanguage: 'bn',
  );

  static const AgentSettings agent = AgentSettings(
    enabled: true,
    name: 'Orvex Assistant',
    language: 'bn',
    tone: 'tone_friendly',
    instructions: 'Delivery inside Dhaka takes 1 to 2 days. Cash on delivery is available.',
  );

  static List<KnowledgeEntry> knowledge() => const [
    KnowledgeEntry(
      id: 'k1',
      question: 'What are your delivery charges?',
      answer: 'Inside Dhaka 60 BDT, outside Dhaka 120 BDT.',
    ),
    KnowledgeEntry(
      id: 'k2',
      question: 'Can I return a product?',
      answer: 'Yes, within 7 days if the product is unused and in original packaging.',
    ),
  ];

  static List<Product> products() => const [
    Product(
      id: 'p1',
      name: 'Cotton Panjabi',
      description: 'Soft cotton panjabi, regular fit.',
      sku: 'PJ-001',
      price: 1850,
      stock: 24,
      category: 'type_fashion',
    ),
    Product(
      id: 'p2',
      name: 'Linen Shirt',
      description: 'Breathable linen shirt for summer.',
      sku: 'SH-014',
      price: 1450,
      stock: 3,
      category: 'type_fashion',
    ),
    Product(
      id: 'p3',
      name: 'Wireless Earbuds',
      description: 'Bluetooth 5.3, 20 hour battery.',
      sku: 'EB-220',
      price: 2290,
      stock: 0,
      category: 'type_electronics',
    ),
    Product(
      id: 'p4',
      name: 'Herbal Face Wash',
      description: '100 ml, for all skin types.',
      sku: 'FW-050',
      price: 420,
      stock: 5,
      category: 'type_beauty',
    ),
    Product(
      id: 'p5',
      name: 'Ceramic Mug Set',
      description: 'Set of 4 mugs.',
      sku: 'MG-004',
      price: 980,
      stock: 40,
      category: 'type_home',
      status: ProductStatus.draft,
    ),
  ];

  static List<Order> orders() => [
    Order(
      id: 'o1',
      number: '#1042',
      customerName: 'Nusrat Jahan',
      phone: '01711000001',
      address: 'House 12, Road 5, Dhanmondi, Dhaka',
      items: const [
        OrderItem(name: 'Cotton Panjabi', quantity: 1, unitPrice: 1850),
        OrderItem(name: 'Herbal Face Wash', quantity: 2, unitPrice: 420),
      ],
      createdAt: _ago(hours: 2),
      status: OrderStatus.pending,
      payment: PaymentStatus.cod,
      deliveryFee: 60,
      note: 'Please call before delivery.',
      channel: Channel.messenger,
    ),
    Order(
      id: 'o2',
      number: '#1041',
      customerName: 'Tanvir Ahmed',
      phone: '01811000002',
      address: 'Sector 7, Uttara, Dhaka',
      items: const [
        OrderItem(name: 'Linen Shirt', quantity: 2, unitPrice: 1450),
      ],
      createdAt: _ago(hours: 6),
      status: OrderStatus.confirmed,
      payment: PaymentStatus.paid,
      deliveryFee: 60,
      channel: Channel.whatsapp,
    ),
    Order(
      id: 'o3',
      number: '#1040',
      customerName: 'Farhana Akter',
      phone: '01911000003',
      address: 'Agrabad, Chattogram',
      items: const [
        OrderItem(name: 'Wireless Earbuds', quantity: 1, unitPrice: 2290),
      ],
      createdAt: _ago(days: 1),
      status: OrderStatus.shipped,
      payment: PaymentStatus.cod,
      deliveryFee: 120,
      channel: Channel.messenger,
    ),
    Order(
      id: 'o4',
      number: '#1039',
      customerName: 'Rafiq Hasan',
      phone: '01611000004',
      address: 'Zindabazar, Sylhet',
      items: const [
        OrderItem(name: 'Ceramic Mug Set', quantity: 1, unitPrice: 980),
      ],
      createdAt: _ago(days: 3),
      status: OrderStatus.delivered,
      payment: PaymentStatus.paid,
      deliveryFee: 120,
      channel: Channel.whatsapp,
    ),
    Order(
      id: 'o5',
      number: '#1038',
      customerName: 'Mitu Rahman',
      phone: '01511000005',
      address: 'Mirpur 10, Dhaka',
      items: const [
        OrderItem(name: 'Herbal Face Wash', quantity: 3, unitPrice: 420),
      ],
      createdAt: _ago(days: 4),
      status: OrderStatus.cancelled,
      payment: PaymentStatus.unpaid,
      deliveryFee: 60,
      channel: Channel.messenger,
    ),
  ];

  static List<Conversation> conversations() => [
    Conversation(
      id: 'c1',
      customer: const Customer(
        id: 'u1',
        name: 'Nusrat Jahan',
        phone: '01711000001',
        totalOrders: 3,
        totalSpent: 8120,
      ),
      channel: Channel.messenger,
      unreadCount: 2,
      messages: [
        Message(
          id: 'm1',
          text: 'Panjabi er size L ache?',
          sender: SenderType.customer,
          sentAt: _ago(minutes: 18),
        ),
        Message(
          id: 'm2',
          text: 'জি, L সাইজ স্টকে আছে। দাম ১৮৫০ টাকা।',
          sender: SenderType.ai,
          sentAt: _ago(minutes: 17),
        ),
        Message(
          id: 'm3',
          text: 'Delivery koto din lagbe?',
          sender: SenderType.customer,
          sentAt: _ago(minutes: 5),
        ),
      ],
    ),
    Conversation(
      id: 'c2',
      customer: const Customer(
        id: 'u2',
        name: 'Tanvir Ahmed',
        phone: '01811000002',
        totalOrders: 1,
        totalSpent: 2960,
      ),
      channel: Channel.whatsapp,
      messages: [
        Message(
          id: 'm4',
          text: 'Hi, is the linen shirt available in blue?',
          sender: SenderType.customer,
          sentAt: _ago(hours: 3),
        ),
        Message(
          id: 'm5',
          text: 'Yes, blue is available. Would you like to place an order?',
          sender: SenderType.ai,
          sentAt: _ago(hours: 3, minutes: -1),
        ),
        Message(
          id: 'm6',
          text: 'Yes, 2 pieces please.',
          sender: SenderType.customer,
          sentAt: _ago(hours: 2, minutes: 55),
        ),
      ],
    ),
    Conversation(
      id: 'c3',
      customer: const Customer(
        id: 'u3',
        name: 'Farhana Akter',
        phone: '01911000003',
        totalOrders: 2,
        totalSpent: 4580,
      ),
      channel: Channel.messenger,
      humanHandled: true,
      unreadCount: 1,
      messages: [
        Message(
          id: 'm7',
          text: 'My earbuds have not arrived yet.',
          sender: SenderType.customer,
          sentAt: _ago(days: 1, hours: 2),
        ),
        Message(
          id: 'm8',
          text: 'I am checking this with the courier now.',
          sender: SenderType.agent,
          sentAt: _ago(days: 1, hours: 1),
        ),
      ],
    ),
  ];

  static List<FbComment> comments() => [
    FbComment(
      id: 'fc1',
      author: 'Sabbir Hossain',
      text: 'Price ki?',
      postTitle: 'Eid collection: Cotton Panjabi',
      createdAt: _ago(minutes: 40),
      status: CommentReplyStatus.awaitingApproval,
      draftReply: 'ধন্যবাদ! দাম ১৮৫০ টাকা। বিস্তারিত ইনবক্সে পাঠিয়েছি।',
    ),
    FbComment(
      id: 'fc2',
      author: 'Lamia Chowdhury',
      text: 'Available in XL?',
      postTitle: 'Eid collection: Cotton Panjabi',
      createdAt: _ago(hours: 5),
      status: CommentReplyStatus.replied,
      reply: 'Yes, XL is available. Please check your inbox.',
    ),
    FbComment(
      id: 'fc3',
      author: 'Kamal Uddin',
      text: 'Buy cheap followers at example-spam.link',
      postTitle: 'Linen shirt launch',
      createdAt: _ago(hours: 9),
      status: CommentReplyStatus.hidden,
    ),
    FbComment(
      id: 'fc4',
      author: 'Anika Tabassum',
      text: 'Cash on delivery ache?',
      postTitle: 'Linen shirt launch',
      createdAt: _ago(days: 1),
    ),
  ];

  static List<CommentRule> commentRules() => const [
    CommentRule(
      id: 'cr1',
      name: 'Price questions',
      keywords: ['price', 'dam', 'দাম'],
      action: CommentAction.both,
      replyTemplate:
          'Thanks for asking! We sent the price details to your inbox.',
    ),
    CommentRule(
      id: 'cr2',
      name: 'Availability',
      keywords: ['available', 'stock', 'ache'],
      action: CommentAction.publicReply,
      replyTemplate: 'Yes, it is available. Message us to order.',
      enabled: false,
    ),
  ];

  static List<ActivityLog> commentLogs() => [
    ActivityLog(
      id: 'l1',
      message: 'Replied publicly to Lamia Chowdhury',
      at: _ago(hours: 5),
    ),
    ActivityLog(
      id: 'l2',
      message: 'Hid a comment flagged as spam',
      at: _ago(hours: 9),
    ),
    ActivityLog(
      id: 'l3',
      message: 'Draft reply waiting for approval (Sabbir Hossain)',
      at: _ago(minutes: 40),
    ),
  ];

  static List<AutomationRule> automations() => const [
    AutomationRule(
      id: 'a1',
      name: 'Price keyword replies',
      trigger: RuleTrigger.keyword,
      action: RuleAction.aiReply,
      conditionValue: 'price, dam, দাম',
    ),
    AutomationRule(
      id: 'a2',
      name: 'Notify on new orders',
      trigger: RuleTrigger.newOrder,
      action: RuleAction.notifyTeam,
    ),
    AutomationRule(
      id: 'a3',
      name: 'Escalate silent chats',
      trigger: RuleTrigger.noReply,
      action: RuleAction.handover,
      conditionValue: '30 minutes',
      enabled: false,
    ),
  ];

  static List<IntegrationInfo> integrations() => const [
    IntegrationInfo(
      id: 'messenger',
      nameKey: 'facebook_messenger',
      state: LinkState.connected,
      accountLabel: 'Demo Fashion House (Page)',
      permissions: {'perm_messaging': true},
    ),
    IntegrationInfo(
      id: 'whatsapp',
      nameKey: 'whatsapp_business',
      state: LinkState.error,
      accountLabel: '+880 1700-000000',
      errorMessage: 'Access token expired.',
    ),
    IntegrationInfo(
      id: 'comments',
      nameKey: 'facebook_comments',
      state: LinkState.notConnected,
      permissions: {'perm_comments': false, 'perm_moderate': false},
    ),
    IntegrationInfo(id: 'website', nameKey: 'website_domain_settings'),
  ];

  static List<CourierInfo> couriers() => const [
    CourierInfo(id: 'pathao', name: 'Pathao'),
    CourierInfo(id: 'steadfast', name: 'Steadfast'),
    CourierInfo(id: 'redx', name: 'RedX'),
  ];

  static List<Plan> plans() => const [
    Plan(
      id: 'starter',
      nameKey: 'plan_free',
      priceMonthly: 0,
      conversations: 200,
      aiReplies: 500,
      teamSeats: 1,
      products: 50,
    ),
    Plan(
      id: 'growth',
      nameKey: 'plan_growth',
      priceMonthly: 1499,
      conversations: 2000,
      aiReplies: 5000,
      teamSeats: 3,
      products: 500,
    ),
    Plan(
      id: 'scale',
      nameKey: 'plan_scale',
      priceMonthly: 3999,
      conversations: 10000,
      aiReplies: 30000,
      teamSeats: 10,
      products: 5000,
    ),
  ];

  static const Subscription subscription = Subscription(
    planId: 'starter',
    usedConversations: 84,
    usedAiReplies: 212,
    usedSeats: 1,
    usedProducts: 5,
  );

  static List<AppNotification> notifications() => [
    AppNotification(
      id: 'n1',
      title: 'New order #1042',
      body: 'Nusrat Jahan placed an order through Messenger.',
      at: _ago(hours: 2),
    ),
    AppNotification(
      id: 'n2',
      title: 'Low stock: Linen Shirt',
      body: 'Only 3 units remain.',
      at: _ago(hours: 7),
    ),
    AppNotification(
      id: 'n3',
      title: 'WhatsApp needs attention',
      body: 'The access token expired. Reconnect the channel.',
      at: _ago(days: 1),
      read: true,
    ),
  ];

  static List<TeamMember> team() => const [
    TeamMember(
      id: 't1',
      name: 'You',
      email: 'owner@demo-fashion.example',
      role: TeamRole.owner,
    ),
    TeamMember(
      id: 't2',
      name: 'Sadia Islam',
      email: 'sadia@demo-fashion.example',
      role: TeamRole.support,
    ),
  ];

  static const DashboardStats stats = DashboardStats(
    totalOrders: 128,
    pendingOrders: 9,
    revenue: 184500,
    aiReplies: 212,
    aiReplyLimit: 500,
    revenueSeries: [12400, 18900, 9800, 22100, 17600, 26300, 31200],
  );
}
