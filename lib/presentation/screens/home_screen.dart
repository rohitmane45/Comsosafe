import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/providers/profile_provider.dart';
import '../../core/services/gemini_service.dart';
import '../../data/models/user_profile.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static bool get _isMobileCameraAvailable =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _captureWithCamera(BuildContext context) async {
    if (!_isMobileCameraAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera is only available on Android & iOS.'),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (picked != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ScanScreen(imageFile: picked),
        ),
      );
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );
    if (picked != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ScanScreen(imageFile: picked),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<ProfileProvider>().profile;
    final isAiMode = GeminiService.isAvailable;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF162D22),
                    const Color(0xFF0F172A),
                  ]
                : [
                    const Color(0xFFF7F4EE),
                    const Color(0xFFE8F4ED),
                    const Color(0xFFF9EFD9),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 1160 : 720),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // ─── Header ──────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CosmoSafe',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1.5,
                                    ),
                              )
                                  .animate()
                                  .fadeIn(duration: 500.ms)
                                  .slideY(
                                      begin: -0.2,
                                      end: 0,
                                      duration: 500.ms),
                              const SizedBox(height: 4),
                              Text(
                                profile.name.isNotEmpty
                                    ? 'Hey ${profile.name} 👋'
                                    : 'Your cosmetic safety companion',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withValues(alpha: 0.6),
                                    ),
                              )
                                  .animate()
                                  .fadeIn(
                                      duration: 400.ms, delay: 200.ms),
                            ],
                          ),
                        ),
                        // Profile avatar
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                                builder: (_) => const ProfileScreen()),
                          ),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                profile.skinType.emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .scale(
                              begin: const Offset(0.5, 0.5),
                              end: const Offset(1, 1),
                              duration: 600.ms,
                              curve: Curves.elasticOut,
                            )
                            .fadeIn(duration: 400.ms),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ─── Skin type badge ─────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1F2937)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              profile.skinType.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${profile.skinType.label} Skin',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                          fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  _buildProfileSubtitle(profile),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: 0.55),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const ProfileScreen()),
                            ),
                            child: const Text('Edit'),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 300.ms)
                        .slideY(
                            begin: 0.1,
                            end: 0,
                            duration: 400.ms,
                            delay: 300.ms),

                    const SizedBox(height: 36),

                    // ─── Scan & Upload Buttons ────────────
                    Text(
                      'Scan a Product',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 400.ms),
                    const SizedBox(height: 8),
                    Text(
                      isAiMode
                          ? 'Capture or upload the ingredient label for\nAI-powered regulatory analysis across 🇮🇳 🇪🇺 🇺🇸'
                          : 'Capture or upload the ingredient label to get\ninstant safety ratings based on Indian standards.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withValues(alpha: 0.6),
                            height: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 450.ms),

                    const SizedBox(height: 28),

                    // Action buttons
                    if (isWide)
                      Row(
                        children: [
                          if (_isMobileCameraAvailable) ...[
                            Expanded(
                              child: _BigActionButton(
                                icon: Icons.camera_alt_rounded,
                                label: 'Scan',
                                subtitle:
                                    'Use camera to capture label',
                                gradient: const [
                                  Color(0xFF10B981),
                                  Color(0xFF059669),
                                ],
                                onTap: () =>
                                    _captureWithCamera(context),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Expanded(
                            child: _BigActionButton(
                              icon: Icons.photo_library_rounded,
                              label: 'Upload',
                              subtitle: 'Choose photo from gallery',
                              gradient: const [
                                Color(0xFF8B5CF6),
                                Color(0xFF7C3AED),
                              ],
                              onTap: () =>
                                  _pickFromGallery(context),
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 500.ms)
                          .slideY(
                              begin: 0.15,
                              end: 0,
                              duration: 500.ms,
                              delay: 500.ms)
                    else
                      Column(
                        children: [
                          if (_isMobileCameraAvailable) ...[
                            _BigActionButton(
                              icon: Icons.camera_alt_rounded,
                              label: 'Scan',
                              subtitle:
                                  'Use camera to capture label',
                              gradient: const [
                                Color(0xFF10B981),
                                Color(0xFF059669),
                              ],
                              onTap: () =>
                                  _captureWithCamera(context),
                            ),
                            const SizedBox(height: 16),
                          ],
                          _BigActionButton(
                            icon: Icons.photo_library_rounded,
                            label: 'Upload',
                            subtitle: 'Choose photo from gallery',
                            gradient: const [
                              Color(0xFF8B5CF6),
                              Color(0xFF7C3AED),
                            ],
                            onTap: () =>
                                _pickFromGallery(context),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 500.ms)
                          .slideY(
                              begin: 0.15,
                              end: 0,
                              duration: 500.ms,
                              delay: 500.ms),

                    const SizedBox(height: 28),

                    // ─── Mode badge ────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1F2937)
                            : isAiMode
                                ? const Color(0xFF1E1042)
                                : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (isAiMode
                                      ? const Color(0xFF8B5CF6)
                                      : const Color(0xFF10B981))
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isAiMode
                                  ? Icons.auto_awesome_rounded
                                  : Icons.offline_bolt_rounded,
                              color: isAiMode
                                  ? const Color(0xFF8B5CF6)
                                  : const Color(0xFF10B981),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAiMode
                                      ? 'AI-Powered Regulatory Analysis'
                                      : '100% Offline Analysis',
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
                                  isAiMode
                                      ? 'Deep analysis across India (CDSCO), EU, and US FDA regulations using Gemini AI.'
                                      : 'All scanning & analysis runs on your device. No data ever leaves your phone.',
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
                        .fadeIn(duration: 400.ms, delay: 600.ms),

                    const SizedBox(height: 20),

                    // ─── Rating legend ────────────────────
                    _RatingLegend(isDark: isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildProfileSubtitle(UserProfile profile) {
    final parts = <String>[];
    if (profile.allergies.isEmpty) {
      parts.add('No allergens set');
    } else {
      parts.add(
          '${profile.allergies.length} allergen${profile.allergies.length == 1 ? '' : 's'}');
    }
    if (profile.condition != DeclaredCondition.none) {
      parts.add(profile.condition.label);
    }
    return parts.join(' · ');
  }
}

// ─── Big Action Button ───────────────────────────────────────
class _BigActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _BigActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradient[0].withValues(alpha: 0.15),
                gradient[1].withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: gradient[0].withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 34),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: gradient[0],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.6),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Rating Legend ───────────────────────────────────────────
class _RatingLegend extends StatelessWidget {
  final bool isDark;
  const _RatingLegend({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final ratings = [
      ('A', 'Excellent', const Color(0xFF10B981)),
      ('B', 'Good', const Color(0xFF34D399)),
      ('C', 'Caution', const Color(0xFFF59E0B)),
      ('D', 'Poor', const Color(0xFFF97316)),
      ('E', 'Avoid', const Color(0xFFEF4444)),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Safety Rating Scale',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: ratings.map((r) {
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: r.$3.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            r.$1,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: r.$3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.$2,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 700.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 700.ms);
  }
}
