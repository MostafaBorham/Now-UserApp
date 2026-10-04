import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_request_model.dart';

void main() {
  test(
    'a complaint links its order by id and keeps the number as title',
    () async {
      final ComplaintRequestModel complaint =
          await ComplaintRequestModel.fromComplaintInputs(
            orderId: 42,
            orderNumber: 'ORD-1001',
            description: 'Late',
            images: const [],
          );

      expect(complaint.toJson()['order_id'], 42);
      expect(complaint.toJson()['title'], 'ORD-1001');
    },
  );

  test('no order id, no order_id key', () {
    expect(
      const ComplaintRequestModel().toJson().containsKey('order_id'),
      isFalse,
    );
  });
}
