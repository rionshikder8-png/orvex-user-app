import 'package:flutter_test/flutter_test.dart';
import 'package:orvex_user_app/models/models.dart';

void main() {
  test('product stock levels', () {
    const base = Product(id: '1', name: 'x', stock: 10);
    expect(base.stockLevel, StockLevel.inStock);
    expect(base.copyWith(stock: 5).stockLevel, StockLevel.low);
    expect(base.copyWith(stock: 1).stockLevel, StockLevel.low);
    expect(base.copyWith(stock: 0).stockLevel, StockLevel.out);
  });

  test('order totals', () {
    final o = Order(
      id: '1',
      number: '#1',
      customerName: 'a',
      phone: '1',
      address: 'x',
      createdAt: DateTime(2026),
      deliveryFee: 60,
      items: const [
        OrderItem(name: 'a', quantity: 2, unitPrice: 100),
        OrderItem(name: 'b', quantity: 1, unitPrice: 50),
      ],
    );
    expect(o.subtotal, 250);
    expect(o.total, 310);
  });

  test('fromJson tolerates missing and malformed fields', () {
    final o = Order.fromJson({'id': 7, 'items': 'broken', 'status': 'weird'});
    expect(o.id, '7');
    expect(o.items, isEmpty);
    expect(o.status, OrderStatus.pending);

    final p = Product.fromJson({'name': 'n', 'price': '12.5', 'stock': '3'});
    expect(p.price, 12.5);
    expect(p.stock, 3);
  });

  test('session parsing requires a user map', () {
    final s = AuthSession.fromJson({
      'token': 't',
      'user': {'id': 'u', 'name': 'A', 'email': 'a@b.co', 'has_business': true},
    });
    expect(s.token, 't');
    expect(s.user.hasBusiness, isTrue);
  });
}
