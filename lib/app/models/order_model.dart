class Order {
  final String id;
  final String userId;
  final String username;
  final String phone;
  final String district;
  final String tehsil;
  final String city;
  final String address;
  final String acres;
  final String price;
  final int status;
  final String? cancellationReason;
  final DateTime? scheduleDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.username,
    required this.phone,
    required this.district,
    required this.tehsil,
    required this.city,
    required this.address,
    required this.acres,
    required this.price,
    required this.status,
    this.cancellationReason,
    this.scheduleDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['Username'] ?? '',
      phone: json['phone'] ?? '',
      district: json['district'] ?? '',
      tehsil: json['tehsil'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      acres: json['acres'] ?? '',
      price: json['price'] ?? '',
      status: json['status'] ?? 1,
      cancellationReason: json['cancellationReason'],
      scheduleDate: json['scheduleDate'] != null ? DateTime.parse(json['scheduleDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get statusText {
    switch (status) {
      case 1: return 'Pending';
      case 2: return 'Completed';
      case 3: return 'Cancelled';
      case 4: return 'In Progress';
      default: return 'Unknown';
    }
  }

  Color get statusColor {
    switch (status) {
      case 1: return Colors.orange;
      case 2: return Colors.green;
      case 3: return Colors.red;
      case 4: return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 1: return Icons.pending;
      case 2: return Icons.check_circle;
      case 3: return Icons.cancel;
      case 4: return Icons.schedule;
      default: return Icons.help;
    }
  }
}