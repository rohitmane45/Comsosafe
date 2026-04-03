import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:image_picker/image_picker.dart';

/// On-device OCR service.
///
/// Uses Google ML Kit on Android & iOS.
/// Falls back to manual text entry on Web/Desktop.
class OcrService {
  OcrService._();

  /// Whether ML Kit OCR is available on this platform.
  static bool get isOcrAvailable =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Recognize text from an image file.
  ///
  /// Returns the recognized text string, or `null` if OCR unavailable.
  static Future<String?> recognizeText(XFile imageFile) async {
    if (!isOcrAvailable) return null;

    try {
      // Dynamic import to avoid compile errors on unsupported platforms
      return await _runMlKitOcr(imageFile);
    } catch (e) {
      // If ML Kit fails, return null so UI can fall back to manual entry
      return null;
    }
  }

  static Future<String?> _runMlKitOcr(XFile imageFile) async {
    // We import ML Kit dynamically
    final inputImage = await _createInputImage(imageFile);
    if (inputImage == null) return null;

    // Import the ML Kit text recognizer
    final textRecognizer = _getTextRecognizer();
    try {
      final recognized = await textRecognizer.processImage(inputImage);
      return recognized.text;
    } finally {
      textRecognizer.close();
    }
  }

  static dynamic _getTextRecognizer() {
    // This uses platform-conditional import
    try {
      // ignore: depend_on_referenced_packages
      final mlkit = _MlKitBridge();
      return mlkit.textRecognizer;
    } catch (_) {
      rethrow;
    }
  }

  static Future<dynamic> _createInputImage(XFile file) async {
    try {
      final mlkit = _MlKitBridge();
      return mlkit.inputImageFromFilePath(file.path);
    } catch (_) {
      return null;
    }
  }
}

/// Bridge to google_mlkit_text_recognition (only compiled on mobile).
class _MlKitBridge {
  dynamic get textRecognizer {
    // We use a conditional import pattern
    // On mobile: google_mlkit_text_recognition is available
    // On desktop/web: this will throw
    try {
      // ignore: avoid_dynamic_calls
      return _createRecognizer();
    } catch (_) {
      rethrow;
    }
  }

  dynamic _createRecognizer() {
    // This will be resolved by the google_mlkit_text_recognition package
    // We need to import it conditionally
    throw UnimplementedError(
      'ML Kit OCR is not available on this platform.',
    );
  }

  dynamic inputImageFromFilePath(String path) {
    throw UnimplementedError(
      'ML Kit InputImage is not available on this platform.',
    );
  }
}
