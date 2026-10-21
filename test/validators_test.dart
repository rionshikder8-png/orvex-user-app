import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orvex_user_app/utils/validators.dart';

import 'helpers.dart';

void main() {
  testWidgets('validators return localised messages', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      wrap(
        TestEnv(),
        Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(Validators.email(ctx, 'a@b.co'), isNull);
    expect(Validators.email(ctx, 'nope'), isNotNull);
    expect(Validators.email(ctx, ''), isNotNull);
    expect(Validators.password(ctx, '1234567'), isNotNull);
    expect(Validators.password(ctx, '12345678'), isNull);
    expect(Validators.confirm(ctx, 'abc', 'abd'), isNotNull);
    expect(Validators.confirm(ctx, 'abc', 'abc'), isNull);
    expect(Validators.phone(ctx, '01711000001'), isNull);
    expect(Validators.phone(ctx, '+8801711000001'), isNull);
    expect(Validators.phone(ctx, '123'), isNotNull);
    expect(Validators.price(ctx, '0'), isNotNull);
    expect(Validators.price(ctx, 'abc'), isNotNull);
    expect(Validators.price(ctx, '199.5'), isNull);
    expect(Validators.stock(ctx, '-1'), isNotNull);
    expect(Validators.stock(ctx, '1.5'), isNotNull);
    expect(Validators.stock(ctx, '0'), isNull);
    expect(Validators.optionalDomain(ctx, ''), isNull);
    expect(Validators.optionalDomain(ctx, 'example.com'), isNull);
    expect(Validators.optionalDomain(ctx, 'not a domain'), isNotNull);
  });
}
