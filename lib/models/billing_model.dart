class BillingModel {
  final bool success;
  final List<BillingData> data;

  BillingModel({
    required this.success,
    required this.data,
  });

  factory BillingModel.fromJson(Map<String, dynamic> json) {
    return BillingModel(
      success: json['success'] ?? false,
      data: (json['data'] as List?)?.map((i) => BillingData.fromJson(i)).toList() ?? [],
    );
  }
}

class BillingData {
  final int id;
  final String orderIdFormatted;
  final String orderFor;
  final String session;
  final String method;
  final String amount;
  final String paymentDate;
  final String formattedPaymentDate;
  final String transactionId;

  BillingData({
    required this.id,
    required this.orderIdFormatted,
    required this.orderFor,
    required this.session,
    required this.method,
    required this.amount,
    required this.paymentDate,
    required this.formattedPaymentDate,
    required this.transactionId,
  });

  factory BillingData.fromJson(Map<String, dynamic> json) {
    return BillingData(
      id: json['id'] ?? 0,
      orderIdFormatted: json['order_id_formatted'] ?? '',
      orderFor: json['order_for'] ?? '',
      session: json['session'] ?? '',
      method: json['method'] ?? '',
      amount: json['amount'] ?? '0.00',
      paymentDate: json['payment_date'] ?? '',
      formattedPaymentDate: json['formatted_payment_date'] ?? '',
      transactionId: json['transaction_id'] ?? 'N/A',
    );
  }
}
