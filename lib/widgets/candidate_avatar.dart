import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/theme/app_colors.dart';

class CandidateAvatar extends StatelessWidget {
  final String? photoUrl;
  final Uint8List? photoBytes;
  final String name;
  final double radius;
  final Color? backgroundColor;

  const CandidateAvatar({
    super.key,
    this.photoUrl,
    this.photoBytes,
    required this.name,
    this.radius = 28,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'C';

    Widget? imageContent;

    if (photoBytes != null && photoBytes!.isNotEmpty) {
      imageContent = Image.memory(
        photoBytes!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => _buildInitials(isDark, initials),
      );
    } else if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      final url = photoUrl!.trim();
      if (url.startsWith('data:image/')) {
        try {
          final base64Str = url.split(',').last;
          final bytes = base64Decode(base64Str);
          imageContent = Image.memory(
            bytes,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => _buildInitials(isDark, initials),
          );
        } catch (_) {
          imageContent = _buildInitials(isDark, initials);
        }
      } else if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('/uploads/')) {
        final fullUrl = url.startsWith('/uploads/')
            ? 'http://localhost:5000$url'
            : url;
        imageContent = Image.network(
          fullUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _buildInitials(isDark, initials),
        );
      } else if (url.startsWith('assets/') || url.startsWith('lib/assets/')) {
        imageContent = Image.asset(
          url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _buildInitials(isDark, initials),
        );
      }
    }

    final bg = backgroundColor ?? AppColors.gold.withValues(alpha: 0.15);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: imageContent ?? _buildInitials(isDark, initials),
      ),
    );
  }

  Widget _buildInitials(bool isDark, String initials) {
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.gold : AppColors.navyBlue,
        ),
      ),
    );
  }
}
