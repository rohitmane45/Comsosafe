import 'package:image_picker/image_picker.dart';

import '../../core/services/analysis_engine.dart';
import '../../core/services/ocr_service.dart';
import '../models/scan_analysis_result.dart';
import '../models/user_profile.dart';

/// Repository that orchestrates:
/// 1. OCR text extraction (or manual text)
/// 2. On-device ingredient analysis
class ScanRepository {
  ScanRepository();

  /// Analyze from an image file (attempts OCR first).
  Future<ScanAnalysisResult> analyzeImage({
    required XFile imageFile,
    required UserProfile userProfile,
    String? manualText,
    String? productName,
    String? brand,
    String? productCategory,
  }) async {
    String ingredientsText;

    if (manualText != null && manualText.trim().isNotEmpty) {
      ingredientsText = manualText;
    } else {
      // Try OCR
      final ocrResult = await OcrService.recognizeText(imageFile);
      if (ocrResult != null && ocrResult.trim().isNotEmpty) {
        ingredientsText = ocrResult;
      } else {
        throw StateError(
          'OCR could not extract text from this image. '
          'Please enter the ingredients manually.',
        );
      }
    }

    return AnalysisEngine.analyze(
      ingredientsText: ingredientsText,
      userProfile: userProfile,
      productName: productName,
      brand: brand,
      productCategory: productCategory,
    );
  }

  /// Analyze from manually entered text.
  ScanAnalysisResult analyzeText({
    required String ingredientsText,
    required UserProfile userProfile,
    String? productName,
    String? brand,
    String? productCategory,
  }) {
    return AnalysisEngine.analyze(
      ingredientsText: ingredientsText,
      userProfile: userProfile,
      productName: productName,
      brand: brand,
      productCategory: productCategory,
    );
  }
}
