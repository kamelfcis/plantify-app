import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      return image;
    } catch (e) {
      return null;
    }
  }

  static Future<List<XFile>> pickMultipleImages({
    int imageQuality = 80,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: imageQuality,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      return images;
    } catch (e) {
      return [];
    }
  }

  static String getImageExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  static bool isValidImageFormat(String filePath) {
    final extension = getImageExtension(filePath);
    return ['.jpg', '.jpeg', '.png', '.webp'].contains(extension);
  }

  static Future<File?> compressImage(String imagePath) async {
    // In a real app, you might use flutter_image_compress package
    // For now, return the original file
    return File(imagePath);
  }

  static String generateImageFileName(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp.jpg';
  }
}

