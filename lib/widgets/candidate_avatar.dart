import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/theme/app_colors.dart';

class CandidateAvatar extends StatefulWidget {
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
  State<CandidateAvatar> createState() => _CandidateAvatarState();
}

class _CandidateAvatarState extends State<CandidateAvatar> {
  Uint8List? _decodedBytes;

  @override
  void initState() {
    super.initState();
    _decodeImageIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CandidateAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoUrl != widget.photoUrl ||
        oldWidget.photoBytes != widget.photoBytes) {
      _decodeImageIfNeeded();
    }
  }

  void _decodeImageIfNeeded() {
    _decodedBytes = null;
    if (widget.photoBytes != null && widget.photoBytes!.isNotEmpty) {
      _decodedBytes = widget.photoBytes;
    } else if (widget.photoUrl != null && widget.photoUrl!.trim().isNotEmpty) {
      final url = widget.photoUrl!.trim();
      if (url.startsWith('data:image/')) {
        try {
          final base64Str = url.split(',').last;
          _decodedBytes = base64Decode(base64Str);
        } catch (_) {
          _decodedBytes = null;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = widget.name.trim().isNotEmpty
        ? widget.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'C';

    Widget? imageContent;

    if (_decodedBytes != null && _decodedBytes!.isNotEmpty) {
      imageContent = Image.memory(
        _decodedBytes!,
        width: widget.radius * 2,
        height: widget.radius * 2,
        fit: BoxFit.cover,
        cacheWidth: (widget.radius * 2 * 2).toInt(), // 2x for retina
        cacheHeight: (widget.radius * 2 * 2).toInt(),
        errorBuilder: (ctx, err, stack) => _buildInitials(isDark, initials),
      );
    } else if (widget.photoUrl != null && widget.photoUrl!.trim().isNotEmpty) {
      final url = widget.photoUrl!.trim();
      if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('/uploads/')) {
        final fullUrl = url.startsWith('/uploads/')
            ? 'http://localhost:5000$url'
            : url;
        imageContent = Image.network(
          fullUrl,
          width: widget.radius * 2,
          height: widget.radius * 2,
          fit: BoxFit.cover,
          cacheWidth: (widget.radius * 2 * 2).toInt(),
          cacheHeight: (widget.radius * 2 * 2).toInt(),
          errorBuilder: (ctx, err, stack) => _buildInitials(isDark, initials),
        );
      } else if (url.startsWith('assets/') || url.startsWith('lib/assets/')) {
        imageContent = Image.asset(
          url,
          width: widget.radius * 2,
          height: widget.radius * 2,
          fit: BoxFit.cover,
          cacheWidth: (widget.radius * 2 * 2).toInt(),
          cacheHeight: (widget.radius * 2 * 2).toInt(),
          errorBuilder: (ctx, err, stack) => _buildInitials(isDark, initials),
        );
      }
    }

    final bg = widget.backgroundColor ?? AppColors.gold.withValues(alpha: 0.15);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
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
          fontSize: widget.radius * 0.7,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.gold : AppColors.navyBlue,
        ),
      ),
    );
  }
}
