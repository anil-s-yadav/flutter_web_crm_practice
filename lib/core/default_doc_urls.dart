class DefaultDocUrls {
  static const String candidatePhoto =
      'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400';
  static const String aadhaar =
      'https://dummyimage.com/600x400/003366/fff.png&text=Aadhaar+Card+Document';
  static const String pan =
      'https://dummyimage.com/600x400/004d40/fff.png&text=PAN+Card+Document';
  static const String passport =
      'https://dummyimage.com/600x400/4a148c/fff.png&text=Passport+Document';
  static const String police =
      'https://dummyimage.com/600x400/b71c1c/fff.png&text=Police+Verification+Document';
  static const String medical =
      'https://dummyimage.com/600x400/1b5e20/fff.png&text=Medical+Clearance+Document';

  /// Sanitizes photo URL: if empty or data URL, returns default placeholder
  static String sanitizePhotoUrl(String? url) {
    if (url == null || url.trim().isEmpty || url.startsWith('data:')) {
      return candidatePhoto;
    }
    return url;
  }

  /// Sanitizes doc URL: if bool is checked/true or url present, returns valid doc URL or default placeholder
  static String? sanitizeDocUrl(
    String? url, [
    dynamic isCheckedOrPlaceholder,
    String? defaultPlaceholder,
  ]) {
    bool isChecked = true;
    String placeholder = aadhaar;

    if (isCheckedOrPlaceholder is bool) {
      isChecked = isCheckedOrPlaceholder;
      if (defaultPlaceholder != null) {
        placeholder = defaultPlaceholder;
      }
    } else if (isCheckedOrPlaceholder is String) {
      placeholder = _getPlaceholder(isCheckedOrPlaceholder);
    }

    if (isChecked || (url != null && url.isNotEmpty)) {
      if (url == null || url.trim().isEmpty || url.startsWith('data:')) {
        return placeholder;
      }
      return url;
    }
    return null;
  }

  static String _getPlaceholder(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('pan')) return pan;
    if (lower.contains('pass')) return passport;
    if (lower.contains('police')) return police;
    if (lower.contains('med')) return medical;
    return aadhaar;
  }
}
