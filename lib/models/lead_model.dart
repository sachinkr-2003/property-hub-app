class PropertyLead {
  final String id;
  final String userName;
  final String userPhone;
  final String propertyTitle;
  final String propertyId;
  final String inquiryType; // Visit Request, Price Query, General Enquiry
  final String message;
  final DateTime dateTime;
  String status; // New, Accepted, Rejected, Contacted

  PropertyLead({
    required this.id,
    required this.userName,
    required this.userPhone,
    required this.propertyTitle,
    required this.propertyId,
    required this.inquiryType,
    required this.message,
    required this.dateTime,
    this.status = 'New',
  });
}
