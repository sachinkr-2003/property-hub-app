import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  static const String defaultFallback =
      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=900&q=80';

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Icon(
          Icons.home_work_outlined,
          size: (width != null && width! < 60) ? 20 : 32,
          color: const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanPath = path.trim();

    if (cleanPath.isEmpty) {
      return _wrapBorder(_buildPlaceholder());
    }

    Widget imageWidget;

    // 1. Check if it's an existing local file on the device (e.g. from camera/gallery)
    if (!cleanPath.startsWith('http://') &&
        !cleanPath.startsWith('https://') &&
        !cleanPath.startsWith('assets/')) {
      try {
        final localFile = File(cleanPath);
        if (localFile.existsSync()) {
          return _wrapBorder(
            Image.file(
              localFile,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            ),
          );
        }
      } catch (_) {}
    }

    // 2. Relative backend URL (e.g. /uploads/properties/abc.jpg)
    String effectiveUrl = cleanPath;
    if (cleanPath.startsWith('/uploads/') || cleanPath.startsWith('uploads/')) {
      final normalized = cleanPath.startsWith('/') ? cleanPath : '/$cleanPath';
      effectiveUrl = '${ApiService.serverRootUrl}$normalized';
    } else if (cleanPath.startsWith('/') &&
        !cleanPath.startsWith('/data') &&
        !cleanPath.startsWith('/storage') &&
        !cleanPath.startsWith('/var') &&
        !cleanPath.startsWith('/private')) {
      effectiveUrl = '${ApiService.serverRootUrl}$cleanPath';
    }

    // 3. Network URL (HTTP / HTTPS)
    if (effectiveUrl.startsWith('http://') || effectiveUrl.startsWith('https://')) {
      imageWidget = Image.network(
        effectiveUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFF8FAFC),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    // 3. Asset Image
    else if (effectiveUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        effectiveUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    // 4. Local File
    else {
      try {
        final file = File(effectiveUrl);
        if (file.existsSync()) {
          imageWidget = Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          );
        } else {
          imageWidget = _buildPlaceholder();
        }
      } catch (_) {
        imageWidget = _buildPlaceholder();
      }
    }

    return _wrapBorder(imageWidget);
  }

  Widget _wrapBorder(Widget child) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }
    return child;
  }
}
