class VisitBooking {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String propertyAddress;
  final String propertyImage;
  final String ownerName;
  final String ownerPhone;
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
    required this.visitDate,
    required this.timeSlot,
    required this.passCode,
    required this.createdAt,
    this.status = 'Confirmed',
  });
}
