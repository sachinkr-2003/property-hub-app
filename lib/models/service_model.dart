import 'package:flutter/material.dart';

class BachelorService {
  final String id;
  final String title;
  final String category;
  final String priceStarting;
  final double rating;
  final int reviewsCount;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> features;

  BachelorService({
    required this.id,
    required this.title,
    required this.category,
    required this.priceStarting,
    required this.rating,
    required this.reviewsCount,
    required this.icon,
    required this.color,
    required this.description,
    required this.features,
  });
}

class ServiceBooking {
  final String id;
  final String serviceTitle;
  final String date;
  final String timeSlot;
  final String address;
  final String status; // Scheduled, Completed, Cancelled
  final double price;

  ServiceBooking({
    required this.id,
    required this.serviceTitle,
    required this.date,
    required this.timeSlot,
    required this.address,
    this.status = 'Scheduled',
    required this.price,
  });
}
