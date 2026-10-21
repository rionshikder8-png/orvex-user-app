import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:orvex_user_app/core/load_state.dart';
import 'package:orvex_user_app/models/models.dart';

import 'helpers.dart';

void main() {
  test('demo session loads clearly-labelled demo data', () async {
    final env = TestEnv();
    await env.data.load(demoSession: true);
    expect(env.data.isDemo, isTrue);
    expect(env.data.status, LoadStatus.ready);
    expect(env.data.orders, isNotEmpty);
    expect(env.data.lowStockProducts, isNotEmpty);
  });

  test(
    'real session without a backend shows empty data, not demo data',
    () async {
      final env = TestEnv();
      await env.data.load(demoSession: false);
      expect(env.data.isDemo, isFalse);
      expect(env.data.orders, isEmpty);
      expect(env.data.products, isEmpty);
      expect(env.data.connectedChannels, 0);
      expect(
        env.data.couriers.every((c) => c.state == LinkState.notConnected),
        isTrue,
      );
    },
  );

  test('loads from the API and tolerates failing optional endpoints', () async {
    final env = TestEnv(
      baseUrl: 'https://api.test',
      client: MockClient((req) async {
        switch (req.url.path) {
          case '/dashboard':
            return http.Response(
              jsonEncode({'total_orders': 4, 'revenue': 900}),
              200,
            );
          case '/orders':
            return http.Response(
              jsonEncode({
                'items': [
                  {
                    'id': 'o1',
                    'number': '#1',
                    'customer_name': 'A',
                    'status': 'pending',
                  },
                ],
              }),
              200,
            );
          case '/products':
            return http.Response(
              jsonEncode([
                {'id': 'p1', 'name': 'Shirt', 'price': 10, 'stock': 2},
              ]),
              200,
            );
          default:
            return http.Response('{"message":"nope"}', 404);
        }
      }),
    );
    await env.data.load(demoSession: false);
    expect(env.data.status, LoadStatus.ready);
    expect(env.data.source, DataSource.api);
    expect(env.data.stats.totalOrders, 4);
    expect(env.data.orders.single.number, '#1');
    expect(env.data.products.single.stockLevel, StockLevel.low);
    expect(env.data.conversations, isEmpty);
  });

  test('offline during load yields the offline state, not demo data', () async {
    final env = TestEnv(
      baseUrl: 'https://api.test',
      client: MockClient((_) async => throw http.ClientException('down')),
    );
    await env.data.load(demoSession: false);
    expect(env.data.status, LoadStatus.offline);
    expect(env.data.orders, isEmpty);
  });

  test(
    'order status change is not reported as confirmed without a backend',
    () async {
      final env = TestEnv();
      await env.data.load(demoSession: true);
      final id = env.data.orders.first.id;
      final res = await env.data.confirmOrderStatus(id, OrderStatus.confirmed);
      expect(res, 'status_change_local'); // honest "not confirmed" notice
    },
  );

  test(
    'manual reply is not added to the thread when delivery is unconfirmed',
    () async {
      final env = TestEnv();
      await env.data.load(demoSession: true);
      final c = env.data.conversations.first;
      final before = c.messages.length;
      final err = await env.data.sendReply(c.id, 'hello');
      expect(err, 'send_needs_backend');
      expect(env.data.conversations.first.messages.length, before);
    },
  );

  test('connecting a channel without a backend changes nothing', () async {
    final env = TestEnv();
    await env.data.load(demoSession: true);
    final res = await env.data.startConnect('comments');
    expect(res.errorKey, 'oauth_not_available');
    expect(
      env.data.integrations.firstWhere((i) => i.id == 'comments').state,
      LinkState.notConnected,
    );
  });
}
