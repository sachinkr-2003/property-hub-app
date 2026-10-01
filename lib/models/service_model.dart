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
  static IconData getIconForCategory(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('tiffin') || cat.contains('mess')) {
      return Icons.restaurant;
    } else if (cat.contains('laundry') || cat.contains('iron')) {
      return Icons.local_laundry_service;
    } else if (cat.contains('maid') || cat.contains('cook') || cat.contains('clean')) {
      return Icons.cleaning_services;
    } else if (cat.contains('electric')) {
      return Icons.electric_bolt;
    } else if (cat.contains('plumb')) {
      return Icons.plumbing;
    } else if (cat.contains('carpent')) {
      return Icons.handyman;
    } else if (cat.contains('wifi') || cat.contains('broadband')) {
      return Icons.wifi;
    } else if (cat.contains('pack') || cat.contains('mover') || cat.contains('shift')) {
      return Icons.local_shipping;
    }
    return Icons.build_circle_rounded;
  }

  static Color getColorForCategory(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('tiffin')) {
      return const Color(0xFFF97316);
    } else if (cat.contains('laundry')) {
      return const Color(0xFF0EA5E9);
    } else if (cat.contains('maid') || cat.contains('cook')) {
      return const Color(0xFF8B5CF6);
    } else if (cat.contains('clean')) {
      return const Color(0xFF10B981);
    } else if (cat.contains('electric')) {
      return const Color(0xFFF59E0B);
    } else if (cat.contains('plumb')) {
      return const Color(0xFF3B82F6);
    } else if (cat.contains('carpent')) {
      return const Color(0xFFD97706);
    } else if (cat.contains('wifi')) {
      return const Color(0xFF6366F1);
    } else if (cat.contains('pack') || cat.contains('mover')) {
      return const Color(0xFFEC4899);
    }
    return const Color(0xFF3B82F6);
  }

  factory BachelorService.fromJson(Map<String, dynamic> json) {
    final cat = json['category']?.toString() ?? 'General';
    final name = json['name']?.toString() ?? json['title']?.toString() ?? 'Service';
    return BachelorService(
      id: json['customId']?.toString() ?? json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: name,
      category: cat,
      priceStarting: json['priceStarts']?.toString() ?? json['priceStarting']?.toString() ?? '₹ 199',
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 4.5,
      reviewsCount: (json['orders'] is num)
          ? (json['orders'] as num).toInt()
          : (json['reviewsCount'] is num ? (json['reviewsCount'] as num).toInt() : 50),
      icon: getIconForCategory(cat),
      color: getColorForCategory(cat),
      description: json['description']?.toString() ??
          'Professional $name services at your doorstep with verified staff.',
      features: json['features'] != null && json['features'] is List
          ? List<String>.from((json['features'] as List).map((e) => e.toString()))
          : ['Doorstep Service', 'Verified Staff', 'Standard Pricing'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customId': id,
      'name': title,
      'category': category,
      'priceStarts': priceStarting,
      'rating': rating,
      'orders': reviewsCount,
      'description': description,
      'features': features,
    };
  }
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

  factory ServiceBooking.fromJson(Map<String, dynamic> json) {
    return ServiceBooking(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      serviceTitle: json['serviceTitle']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      timeSlot: json['timeSlot']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Scheduled',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceTitle': serviceTitle,
      'date': date,
      'timeSlot': timeSlot,
      'address': address,
      'status': status,
      'price': price,
    };
  }
}
