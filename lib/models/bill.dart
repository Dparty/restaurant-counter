import 'order.dart';

class Bill {
  final String id;
  final String status;
  final int pickUpCode;
  final List<Order> orders;
  final String? tableLabel;
  final int total;
  final int createdAt;
  const Bill(
      {required this.id,
      required this.status,
      required this.orders,
      required this.pickUpCode,
      required this.total,
      required this.createdAt,
      this.tableLabel});
  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
        id: json['id'],
        status: json['status'],
        pickUpCode: json['pickUpCode'],
        tableLabel: json['tableLabel'],
        total: json['total'],
        createdAt: json['createdAt'],
        orders: (json['orders'] as Iterable)
            .map((e) => Order.fromJson(e))
            .toList());
  }
}
