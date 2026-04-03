import 'dart:typed_data';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/providers/profile_provider.dart';
import '../../core/services/ocr_service.dart';
import '../../data/repositories/scan_repository.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final ScanRepository _repository = ScanRepository();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _manualCtrl = TextEditingController();
  final TextEditingController _productNameCtrl = TextEditingController();

  XFile? _selectedFile;
  Uint8List? _previewBytes;
  String? _ocrText;
  String? _message;
  bool _isLoading = false;

  bool get _isMobileCameraAvailable =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void dispose() {
    _manualCtrl.dispose();
    _productNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _captureWithCamera() async {
    if (!_isMobileCameraAvailable) {
      setState(() {
        _message =
            'Camera capture is only available on Android & iOS. Use the upload option.';
      });
      return;
    }

    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
      preferredCameraDevice: CameraDevice.rear,
    );
    await _loadSelection(picked);
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );
    await _loadSelection(picked);
  }

  Future<void> _loadSelection(XFile? file) async {
    if (file == null) return;

    final bytes = await file.readAsBytes();

    // Try OCR
    String? ocrResult;
    if (OcrService.isOcrAvailable) {
      setState(() {
        _message = 'Running OCR...';
        _isLoading = true;
      });
      ocrResult = await OcrService.recognizeText(file);
    }

    setState(() {
      _selectedFile = file;
      _previewBytes = bytes;
      _ocrText = ocrResult;
      _isLoading = false;
      _message = null;

      if (ocrResult != null && ocrResult.isNotEmpty) {
        _manualCtrl.text = ocrResult;
      } else if (!OcrService.isOcrAvailable) {
        _message =
            'OCR is not available on this platform. Please enter the ingredients from the label below.';
      } else {
        _message =
            'Could not read text from image. Please type the ingredients manually.';
      }
    });
  }

  Future<void> _analyze() async {
    final text = _manualCtrl.text.trim();
    if (text.isEmpty && _selectedFile == null) {
      setState(() => _message = 'Capture/upload an image or enter ingredients.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final profile = context.read<ProfileProvider>().profile;

      final result = _repository.analyzeText(
        ingredientsText:
            text.isNotEmpty ? text : (_ocrText ?? ''),
        userProfile: profile,
        productName: _productNameCtrl.text.trim().isNotEmpty
            ? _productNameCtrl.text.trim()
            : null,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(result: result),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _message = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Ingredients'),
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
                    // ─── Step 1: Capture / Upload ──────
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'STEP 1',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF10B981),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Capture or upload the ingredient label',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                if (_isMobileCameraAvailable) ...[
                                  Expanded(
                                    child: _ActionButton(
                                      icon: Icons.camera_alt_rounded,
                                      label: 'Camera',
                                      color: const Color(0xFF10B981),
                                      onTap: _captureWithCamera,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: _ActionButton(
                                    icon: Icons.photo_library_rounded,
                                    label: 'Gallery',
                                    color: const Color(0xFF8B5CF6),
                                    onTap: _pickFromGallery,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0, duration: 400.ms),

                    // ─── Image preview ────────────────
                    if (_previewBytes != null) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.image_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedFile?.name ?? 'Selected image',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded,
                                        size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _selectedFile = null;
                                        _previewBytes = null;
                                        _ocrText = null;
                                        _message = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.memory(
                                  _previewBytes!,
                                  height: 240,
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
                    ],

                    // ─── Step 2: Manual text / OCR ─────
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'STEP 2',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF8B5CF6),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Review & enter ingredients',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _previewBytes != null && OcrService.isOcrAvailable
                                  ? 'Verify the OCR-extracted text below, or edit as needed.'
                                  : 'Type or paste the ingredient list from the product label.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withValues(alpha: 0.6),
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _productNameCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Product name (optional)',
                                prefixIcon:
                                    Icon(Icons.shopping_bag_rounded),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _manualCtrl,
                              maxLines: 6,
                              decoration: const InputDecoration(
                                hintText:
                                    'e.g. Water, Glycerin, Niacinamide, Sodium Lauryl Sulfate, Fragrance...',
                                alignLabelWithHint: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(
                            begin: 0.1,
                            end: 0,
                            duration: 400.ms,
                            delay: 200.ms),

                    // ─── Message ──────────────────────
                    if (_message != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: Color(0xFFF59E0B), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _message!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ─── Step 3: Analyze ─────────────
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _analyze,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.insights_rounded),
                        label: Text(
                            _isLoading ? 'Analyzing...' : 'Analyze Ingredients'),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 400.ms)
                        .slideY(
                            begin: 0.1,
                            end: 0,
                            duration: 400.ms,
                            delay: 400.ms),

                    const SizedBox(height: 20),

                    // ─── Info panel ──────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1F2937)
                            : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.offline_bolt_rounded,
                              color: Color(0xFF10B981),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '100% Offline Analysis',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'All analysis runs on your device. Your data never leaves your phone.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.white
                                            .withValues(alpha: 0.65),
                                        height: 1.4,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 500.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Action Button ───────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
