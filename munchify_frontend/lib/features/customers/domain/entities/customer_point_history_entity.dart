class CustomerPointHistoryEntity {
  final int orderId;
  final String orderCode;
  final int pointsEarned;
  final int pointsRedeemed;
  final double totalAmount;
  final DateTime createdAt;

  CustomerPointHistoryEntity({
    required this.orderId,
    required this.orderCode,
    required this.pointsEarned,
    required this.pointsRedeemed,
    required this.totalAmount,
    required this.createdAt,
  });
}