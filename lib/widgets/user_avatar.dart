import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/theme/app_colors.dart';

class UserAvatar extends StatefulWidget {
  final String? photoUrl;
  final Uint8List? photoBytes;
  final String name;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double borderWidth;

  const UserAvatar({
    super.key,
    this.photoUrl,
    this.photoBytes,
    required this.name,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth = 0,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  Uint8List? _decodedBytes;

  @override
  void initState() {
    super.initState();
    _decodeImageIfNeeded();
  }

  @override
  void didUpdateWidget(covariant UserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoUrl != widget.photoUrl ||
        oldWidget.photoBytes != widget.photoBytes ||
        oldWidget.name != widget.name) {
      _decodeImageIfNeeded();
      setState(() {});
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
        ? widget.name
            .trim()
            .split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase()
        : 'U';

    Widget? imageContent;

    if (_decodedBytes != null && _decodedBytes!.isNotEmpty) {
      imageContent = Image.memory(
        _decodedBytes!,
        width: widget.radius * 2,
        height: widget.radius * 2,
        fit: BoxFit.cover,
        cacheWidth: (widget.radius * 2 * 2).toInt(),
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

    final bg = widget.backgroundColor ?? AppColors.gold.withValues(alpha: 0.2);

    Widget avatarWidget = ClipRRect(
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

    if (widget.borderWidth > 0 && widget.borderColor != null) {
      avatarWidget = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.borderColor!,
            width: widget.borderWidth,
          ),
        ),
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }

  Widget _buildInitials(bool isDark, String initials) {
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          fontSize: widget.radius * 0.75,
          fontWeight: FontWeight.bold,
          color: widget.textColor ?? (isDark ? AppColors.gold : AppColors.navyBlue),
        ),
      ),
    );
  }
}
