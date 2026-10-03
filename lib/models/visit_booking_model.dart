class VisitBooking {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String propertyAddress;
  final String propertyImage;
  final String ownerName;
  final String ownerPhone;
  final String visitorName;
  final String visitorPhone;
  final String visitDate;
  final String timeSlot;
  final String passCode;
  final DateTime createdAt;
  final String status; // 'Confirmed', 'Completed', 'Cancelled'

  VisitBooking({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyAddress,
    required this.propertyImage,
    required this.ownerName,
    required this.ownerPhone,
    this.visitorName = '',
    this.visitorPhone = '',
    required this.visitDate,
    required this.timeSlot,
    required this.passCode,
    required this.createdAt,
    this.status = 'Confirmed',
  });

  factory VisitBooking.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.now();
    if (json['createdAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    return VisitBooking(
      id: json['customId']?.toString() ?? json['_id']?.toString() ?? json['id']?.toString() ?? '',
      propertyId: json['propertyId']?.toString() ?? '',
      propertyTitle: json['propertyTitle']?.toString() ?? 'Verified Property',
      propertyAddress: json['locality']?.toString() ?? json['propertyAddress']?.toString() ?? 'Lucknow',
      propertyImage: json['propertyImage']?.toString() ??
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1000&q=80',
      ownerName: json['ownerName']?.toString() ?? 'Direct Owner',
      ownerPhone: json['ownerPhone']?.toString() ?? '+91 98765 00000',
      visitorName: json['visitorName']?.toString() ?? '',
      visitorPhone: json['visitorPhone']?.toString() ?? '',
      visitDate: json['slotDate']?.toString() ?? json['visitDate']?.toString() ?? 'Tomorrow',
      timeSlot: json['slotTime']?.toString() ?? json['timeSlot']?.toString() ?? 'Morning (10:00 AM - 1:00 PM)',
      passCode: json['passCode']?.toString() ?? 'PH-VIS-${DateTime.now().millisecond}',
      createdAt: parsedDate,
      status: json['status']?.toString() ?? 'Confirmed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customId': id,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'locality': propertyAddress,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'visitorName': visitorName.isNotEmpty ? visitorName : 'Property Seeker',
      'visitorPhone': visitorPhone.isNotEmpty ? visitorPhone : (ownerPhone.isNotEmpty ? ownerPhone : '+91 91353 21898'),
      'slotDate': visitDate,
      'slotTime': timeSlot,
      'passCode': passCode,
      'status': status,
    };
  }
}
