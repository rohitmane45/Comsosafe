import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// On-device OCR service using Google ML Kit.
///
/// Runs entirely offline on Android & iOS.
class OcrService {
  OcrService._();

  /// Whether ML Kit OCR is available on this platform.
  static bool get isOcrAvailable =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Recognize text from an image file.
  ///
  /// Returns the recognized text string, or `null` if OCR is unavailable
  /// or fails.
  static Future<String?> recognizeText(XFile imageFile) async {
    if (!isOcrAvailable) return null;

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final recognizedText = await textRecognizer.processImage(inputImage);
      final text = recognizedText.text.trim();
      return text.isNotEmpty ? text : null;
    } catch (e) {
      debugPrint('OCR Error: $e');
      return null;
    } finally {
      textRecognizer.close();
    }
  }
}
