import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymongoService {
  Future<Map<String, dynamic>> createPayment({
    required String description,
    required String billingName,
    required String billingEmail,
    required String billingPhone,
    required double lineItemAmount,
    required String lineItemName,
    required int lineItemQuantity,
    required String currency,
    required String paymentMethod, // card, gcash, paymaya
  }) async {
    final url = Uri.parse("https://payments.medlexer.com/v1/pay");

    final Map<String, dynamic> reqBody = {
      'description': description,
      'billing_name': billingName,
      'billing_email': billingEmail,
      'billing_phone': billingPhone,
      'line_item_amount': lineItemAmount,
      'line_item_name': lineItemName,
      'line_item_quantity': lineItemQuantity,
      'currency': currency,
      'payment_method': paymentMethod,
    };

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(reqBody));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {'success': false, 'message': 'An error occured'};
      }
    } catch (err) {
      return {'success': false, 'message': 'An error occured'};
    }
  }
}
