import 'enums.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    this.description = '',
    this.sku = '',
    this.price = 0,
    this.stock = 0,
    this.category = 'type_other',
    this.status = ProductStatus.published,
    this.imagePath,
    this.imageUrl,
    this.lowStockThreshold = 5,
  });

  final String id;
  final String name;
  final String description;
  final String sku;
  final double price;
  final int stock;
  final String category;
  final ProductStatus status;

  /// Local file picked on this device (preview only until uploaded by backend).
  final String? imagePath;
  final String? imageUrl;
  final int lowStockThreshold;

  StockLevel get stockLevel => stock <= 0
      ? StockLevel.out
      : (stock <= lowStockThreshold ? StockLevel.low : StockLevel.inStock);

  Product copyWith({
    String? name,
    String? description,
    String? sku,
    double? price,
    int? stock,
    String? category,
    ProductStatus? status,
    String? imagePath,
    bool clearImage = false,
  }) => Product(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    sku: sku ?? this.sku,
    price: price ?? this.price,
    stock: stock ?? this.stock,
    category: category ?? this.category,
    status: status ?? this.status,
    imagePath: clearImage ? null : (imagePath ?? this.imagePath),
    imageUrl: clearImage ? null : imageUrl,
    lowStockThreshold: lowStockThreshold,
  );

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: J.s(j['id']),
    name: J.s(j['name']),
    description: J.s(j['description']),
    sku: J.s(j['sku']),
    price: J.d(j['price']),
    stock: J.i(j['stock']),
    category: J.s(j['category'], 'type_other'),
    status: enumByName(
      ProductStatus.values,
      j['status'],
      ProductStatus.published,
    ),
    imageUrl: j['image_url'] as String?,
    lowStockThreshold: J.i(j['low_stock_threshold'], 5),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'sku': sku,
    'price': price,
    'stock': stock,
    'category': category,
    'status': status.name,
  };
}

class OrderItem {
  const OrderItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });
  final String name;
  final int quantity;
  final double unitPrice;
  double get lineTotal => quantity * unitPrice;

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    name: J.s(j['name']),
    quantity: J.i(j['quantity'], 1),
    unitPrice: J.d(j['unit_price']),
  );
}

class Order {
  const Order({
    required this.id,
    required this.number,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.items,
    required this.createdAt,
    this.status = OrderStatus.pending,
    this.payment = PaymentStatus.unpaid,
    this.deliveryFee = 0,
    this.note = '',
    this.channel,
  });

  final String id;
  final String number;
  final String customerName;
  final String phone;
  final String address;
  final List<OrderItem> items;
  final DateTime createdAt;
  final OrderStatus status;
  final PaymentStatus payment;
  final double deliveryFee;
  final String note;
  final Channel? channel;

  double get subtotal => items.fold(0, (s, i) => s + i.lineTotal);
  double get total => subtotal + deliveryFee;

  Order copyWith({OrderStatus? status, String? note}) => Order(
    id: id,
    number: number,
    customerName: customerName,
    phone: phone,
    address: address,
    items: items,
    createdAt: createdAt,
    status: status ?? this.status,
    payment: payment,
    deliveryFee: deliveryFee,
    note: note ?? this.note,
    channel: channel,
  );

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id: J.s(j['id']),
    number: J.s(j['number'], J.s(j['id'])),
    customerName: J.s(j['customer_name']),
    phone: J.s(j['phone']),
    address: J.s(j['address']),
    items: J.list(j['items']).map(OrderItem.fromJson).toList(),
    createdAt: J.dt(j['created_at']),
    status: enumByName(OrderStatus.values, j['status'], OrderStatus.pending),
    payment: enumByName(
      PaymentStatus.values,
      j['payment_status'],
      PaymentStatus.unpaid,
    ),
    deliveryFee: J.d(j['delivery_fee']),
    note: J.s(j['note']),
    channel: j['channel'] == null
        ? null
        : enumByName(Channel.values, j['channel'], Channel.messenger),
  );
}
