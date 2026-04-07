import 'package:image_picker/image_picker.dart';

import '../../core/services/analysis_engine.dart';
import '../../core/services/ocr_service.dart';
import '../models/scan_analysis_result.dart';
import '../models/user_profile.dart';

/// Repository that orchestrates:
/// 1. OCR text extraction
/// 2. AI-powered or on-device ingredient analysis
class ScanRepository {
  ScanRepository();

  /// Analyze from an image file (OCR → Gemini/local analysis).
  Future<ScanAnalysisResult> analyzeImage({
    required XFile imageFile,
    required UserProfile userProfile,
    String? productName,
    String? brand,
    String? productCategory,
    String? applicationType,
  }) async {
    // Try OCR
    final ocrResult = await OcrService.recognizeText(imageFile);
    if (ocrResult == null || ocrResult.trim().isEmpty) {
      throw StateError(
        OcrService.isOcrAvailable
            ? 'OCR could not extract text from this image. '
                'Please try again with a clearer photo of the ingredient list.'
            : 'OCR is not available on this platform. '
                'Please use an Android or iOS device.',
      );
    }

    return analyzeText(
      ingredientsText: ocrResult,
      userProfile: userProfile,
      productName: productName,
      brand: brand,
      productCategory: productCategory,
      applicationType: applicationType,
    );
  }

  /// Analyze from text (Gemini AI with local fallback).
  Future<ScanAnalysisResult> analyzeText({
    required String ingredientsText,
    required UserProfile userProfile,
    String? productName,
    String? brand,
    String? productCategory,
    String? applicationType,
  }) async {
    return AnalysisEngine.analyzeWithFallback(
      ingredientsText: ingredientsText,
      userProfile: userProfile,
      productName: productName,
      brand: brand,
      productCategory: productCategory,
      applicationType: applicationType,
    );
  }
}
