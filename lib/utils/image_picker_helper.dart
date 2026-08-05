import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class PickedImageData {
  final Uint8List bytes;
  final String fileName;
  final String extension;
  final String base64DataUrl;

  PickedImageData({
    required this.bytes,
    required this.fileName,
    required this.extension,
    required this.base64DataUrl,
  });
}

Future<PickedImageData?> pickImageData() async {
  if (kIsWeb) {
    try {
      final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
      uploadInput.click();

      await uploadInput.onChange.first;
      if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
        final file = uploadInput.files!.first;
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoadEnd.first;

        final bytes = reader.result as Uint8List?;
        if (bytes != null) {
          final ext =
              file.name.contains('.')
                  ? file.name.split('.').last.toLowerCase()
                  : 'png';
          final base64Image = 'data:image/$ext;base64,${base64Encode(bytes)}';
          return PickedImageData(
            bytes: bytes,
            fileName: file.name,
            extension: ext,
            base64DataUrl: base64Image,
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('Web HTML file pick error: $e');
    }
  }

  // Desktop / Mobile fallback via file_picker
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes != null) {
        final ext = file.extension ?? 'png';
        final base64Image = 'data:image/$ext;base64,${base64Encode(bytes)}';
        return PickedImageData(
          bytes: bytes,
          fileName: file.name,
          extension: ext,
          base64DataUrl: base64Image,
        );
      }
    }
  } catch (e) {
    debugPrint('FilePicker error: $e');
  }

  return null;
}
