import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/providers/profile_provider.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/ocr_service.dart';
import '../../data/models/gemini_analysis_result.dart';
import '../../data/models/scan_analysis_result.dart';
import '../../data/repositories/scan_repository.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  final XFile imageFile;

  const ScanScreen({super.key, required this.imageFile});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final ScanRepository _repository = ScanRepository();

  Uint8List? _previewBytes;
  bool _isProcessing = true;
  String _statusMessage = 'Reading image...';
  String? _errorMessage;
  double _progress = 0.0;
  final bool _isAiMode = GeminiService.isAvailable;

  // Product category for Gemini prompt
  String _productCategory = 'OTHER';

  static const _categories = [
    ('OTHER', 'Auto-detect'),
    ('face_moisturiser', 'Face Moisturiser'),
    ('sunscreen', 'Sunscreen'),
    ('serum', 'Serum'),
    ('cleanser', 'Cleanser'),
    ('toner', 'Toner'),
    ('shampoo', 'Shampoo'),
    ('conditioner', 'Conditioner'),
    ('body_lotion', 'Body Lotion'),
    ('lip_product', 'Lip Product'),
    ('eye_product', 'Eye Product'),
    ('deodorant', 'Deodorant'),
    ('makeup_foundation', 'Foundation'),
    ('nail_product', 'Nail Product'),
    ('baby_product', 'Baby Product'),
    ('hair_dye', 'Hair Dye'),
  ];

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      // Step 1: Load preview
      setState(() {
        _statusMessage = 'Loading image...';
        _progress = 0.1;
      });

      final bytes = await widget.imageFile.readAsBytes();
      if (!mounted) return;

      setState(() {
        _previewBytes = bytes;
        _statusMessage = 'Extracting text with OCR...';
        _progress = 0.25;
      });

      // Step 2: Try OCR first
      String? ocrText;
      if (OcrService.isOcrAvailable) {
        ocrText = await OcrService.recognizeText(widget.imageFile);
      }

      if (!mounted) return;

      // Step 3: If OCR unavailable/failed but Gemini is available — use vision
      if ((ocrText == null || ocrText.trim().isEmpty) && _isAiMode) {
        setState(() {
          _statusMessage = 'Using AI vision to read label...';
          _progress = 0.4;
        });

        // Determine MIME type from file extension
        final ext = widget.imageFile.name.split('.').last.toLowerCase();
        final mimeType = switch (ext) {
          'png' => 'image/png',
          'webp' => 'image/webp',
          'gif' => 'image/gif',
          _ => 'image/jpeg',
        };

        setState(() {
          _statusMessage = 'AI analyzing product label image...';
          _progress = 0.55;
        });

        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;

        setState(() {
          _statusMessage = 'Running multi-jurisdiction regulatory check...';
          _progress = 0.75;
        });

        final profile = context.read<ProfileProvider>().profile;
        GeminiAnalysisResult? geminiResult;
        String? visionError;

        try {
          geminiResult = await GeminiService.analyzeImage(
            imageBytes: bytes,
            mimeType: mimeType,
            userProfile: profile,
            productCategory:
                _productCategory != 'OTHER' ? _productCategory : null,
          );
        } catch (e) {
          visionError = e.toString();
        }

        if (!mounted) return;

        if (geminiResult != null) {
          setState(() {
            _statusMessage = 'Generating safety report...';
            _progress = 0.95;
          });

          await Future.delayed(const Duration(milliseconds: 200));
          if (!mounted) return;

          final result = ScanAnalysisResult.fromGemini(
            gemini: geminiResult,
            ingredientsText: '[Extracted from image via AI vision]',
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => ResultScreen(result: result),
            ),
          );
          return;
        }

        // Gemini vision failed — show user-friendly error
        setState(() {
          _isProcessing = false;
          if (visionError != null) {
            // FormatException from our _extractJson already has
            // a user-friendly message — use it directly.
            final isFormatError = visionError.contains('FormatException');
            _errorMessage = isFormatError
                ? visionError.replaceFirst(RegExp(r'^FormatException:\s*'), '')
                : 'AI analysis error:\n\n$visionError';
          } else {
            _errorMessage =
                'AI could not read the ingredient label from this image.\n\n'
                'Please try a clearer, well-lit photo of the ingredient list.';
          }
        });
        return;
      }

      // Step 3b: If OCR failed and no Gemini — show error
      if (ocrText == null || ocrText.trim().isEmpty) {
        setState(() {
          _isProcessing = false;
          _errorMessage = OcrService.isOcrAvailable
              ? 'Could not extract text from this image.\n\nPlease try again with a clearer photo of the ingredient list.'
              : 'OCR is not available on this platform and no AI key is configured.\n\nPlease use an Android or iOS device, or configure a Gemini API key.';
        });
        return;
      }

      setState(() {
        _statusMessage = _isAiMode
            ? 'AI analyzing ${_countIngredients(ocrText!)} ingredients...'
            : 'Analyzing ${_countIngredients(ocrText!)} ingredients...';
        _progress = 0.5;
      });

      // Brief pause for visual feedback
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      // Step 4: Analyze text
      setState(() {
        _statusMessage = _isAiMode
            ? 'Running multi-jurisdiction regulatory check...'
            : 'Checking against IS 4707 database...';
        _progress = 0.7;
      });

      final profile = context.read<ProfileProvider>().profile;
      final result = await _repository.analyzeText(
        ingredientsText: ocrText,
        userProfile: profile,
        productCategory:
            _productCategory != 'OTHER' ? _productCategory : null,
      );

      if (!mounted) return;

      setState(() {
        _statusMessage = 'Generating safety report...';
        _progress = 0.95;
      });

      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;

      // Step 5: Navigate to results
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(result: result),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = 'An error occurred: $error';
      });
    }
  }

  int _countIngredients(String text) {
    return text
        .split(RegExp(r'[,;/]+'))
        .where((t) => t.trim().length >= 2)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyzing Product'),
        actions: [
          // AI mode indicator
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _isAiMode
                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.12)
                  : const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isAiMode
                      ? Icons.auto_awesome_rounded
                      : Icons.offline_bolt_rounded,
                  size: 14,
                  color: _isAiMode
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFF10B981),
                ),
                const SizedBox(width: 4),
                Text(
                  _isAiMode ? 'AI Mode' : 'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _isAiMode
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF162D22)]
                : [const Color(0xFFF7F4EE), const Color(0xFFF4F8F6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── Image preview ────────────────
                    if (_previewBytes != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.image_rounded,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.imageFile.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                              fontWeight:
                                                  FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.memory(
                                  _previewBytes!,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1, 1),
                            duration: 400.ms,
                          ),

                    const SizedBox(height: 16),

                    // ─── Product Category Picker ──────
                    if (_isAiMode && _isProcessing)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.category_rounded,
                                    size: 16,
                                    color: Color(0xFF8B5CF6),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Product Category',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color:
                                              const Color(0xFF8B5CF6),
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: _categories.map((cat) {
                                  final isSelected =
                                      _productCategory == cat.$1;
                                  return GestureDetector(
                                    onTap: () => setState(
                                        () => _productCategory = cat.$1),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF8B5CF6)
                                                .withValues(
                                                    alpha: 0.15)
                                            : Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color
                                                    ?.withValues(
                                                        alpha: 0.06) ??
                                                Colors.grey
                                                    .withValues(
                                                        alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: isSelected
                                            ? Border.all(
                                                color: const Color(
                                                        0xFF8B5CF6)
                                                    .withValues(
                                                        alpha: 0.4))
                                            : null,
                                      ),
                                      child: Text(
                                        cat.$2,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? const Color(0xFF8B5CF6)
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color
                                                  ?.withValues(
                                                      alpha: 0.7),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

                    const SizedBox(height: 16),

                    // ─── Processing State ─────────────
                    if (_isProcessing)
                      _buildProcessingCard(context, isDark),

                    // ─── Error State ──────────────────
                    if (_errorMessage != null)
                      _buildErrorCard(context, isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingCard(BuildContext context, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // Animated scanner icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isAiMode
                      ? [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)]
                      : [const Color(0xFF10B981), const Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (_isAiMode
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFF10B981))
                        .withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                _isAiMode
                    ? Icons.auto_awesome_rounded
                    : Icons.document_scanner_rounded,
                color: Colors.white,
                size: 36,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.05, 1.05),
                  duration: 800.ms,
                ),

            const SizedBox(height: 24),

            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 6,
                backgroundColor: (_isAiMode
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFF10B981))
                    .withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isAiMode
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFF10B981),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              '${(_progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _isAiMode
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFF10B981),
                  ),
            ),

            if (_isAiMode) ...[
              const SizedBox(height: 16),
              Text(
                'Checking India 🇮🇳 · EU 🇪🇺 · US 🇺🇸 regulations',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.5),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.15, end: 0, duration: 400.ms, delay: 200.ms);
  }

  Widget _buildErrorCard(BuildContext context, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    const Color(0xFFEF4444).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFEF4444),
                size: 36,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Extraction Failed',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFEF4444),
                  ),
            ),

            const SizedBox(height: 12),

            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFF59E0B)
                      .withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded,
                          color: Color(0xFFF59E0B), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Tips for better results',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFF59E0B),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...[
                    'Ensure the ingredient list is clearly visible',
                    'Use good lighting — avoid shadows',
                    'Hold the camera steady and close to the label',
                    'Make sure text is in focus and not blurry',
                  ].map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withValues(alpha: 0.6))),
                          Expanded(
                            child: Text(
                              tip,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    height: 1.4,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withValues(alpha: 0.7),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go Back & Try Again'),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.15, end: 0, duration: 400.ms, delay: 200.ms);
  }
}
