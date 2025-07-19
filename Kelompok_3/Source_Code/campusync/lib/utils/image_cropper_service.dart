import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

/// Utility Service to handle cropping image for both Web and Mobile.
class ImageCropperService {
  /// Crop from path (only works for Android/iOS)
  static Future<Uint8List?> cropImage({
    required String path,
    required BuildContext context,
  }) async {
    try {
      if (kIsWeb) {
        // Not applicable for Web
        debugPrint(
            "❌ cropImage() not supported on Web. Use cropImageFromBytes instead.");
        return null;
      }

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Gambar',
            toolbarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            initAspectRatio: CropAspectRatioPreset.square,
          ),
          IOSUiSettings(
            title: 'Potong Gambar',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        return await io.File(croppedFile.path).readAsBytes();
      }
    } catch (e) {
      debugPrint('❌ Crop error (native): $e');
    }

    return null;
  }

  /// Crop from Uint8List (recommended for Web)
  static Future<Uint8List?> cropImageFromBytes({
    required Uint8List imageBytes,
    required BuildContext context,
  }) async {
    try {
      if (kIsWeb) {
        // Web: Manual crop square center & resize
        final img.Image? original = img.decodeImage(imageBytes);
        if (original == null) return null;

        final int size = math.min(original.width, original.height);
        final int x = (original.width - size) ~/ 2;
        final int y = (original.height - size) ~/ 2;

        final img.Image cropped = img.copyCrop(
          original,
          x: x,
          y: y,
          width: size,
          height: size,
        );

        final img.Image resized = img.copyResize(
          cropped,
          width: 800,
          height: 800,
        );

        return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
      } else {
        // Android/iOS: convert bytes to file & reuse cropImage
        final tempDir = await io.Directory.systemTemp.createTemp();
        final tempFile =
            await io.File('${tempDir.path}/temp.jpg').writeAsBytes(imageBytes);

        return await cropImage(path: tempFile.path, context: context);
      }
    } catch (e) {
      debugPrint('❌ cropImageFromBytes error: $e');
      return null;
    }
  }
}
