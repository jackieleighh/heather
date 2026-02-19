import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/fcm_service.dart';
import '../providers/settings_provider.dart';
import '../widgets/logo_overlay.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0; // 0 = tone, 1 = notifications
  bool _keepItPG = true;
  bool _severeAlertsEnabled = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  Future<void> _finish() async {
    final notifier = ref.read(settingsProvider.notifier);

    await notifier.setExplicitLanguage(!_keepItPG);

    await notifier.setSevereAlertsEnabled(_severeAlertsEnabled);

    await notifier.completeOnboarding();

    if (mounted) {
      context.go('/');
    }
  }

  Color get _accentColor => AppColors.magenta;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        color: _accentColor,
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 0
                      ? _buildToneStep()
                      : _buildNotificationsStep(),
                ),
              ),
            ),
            const LogoOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildToneStep() {
    return Column(
      key: const ValueKey('tone'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 2),
        Text(
          "What's the vibe?",
          style: GoogleFonts.quicksand(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.cream,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cream.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            title: Text(
              'Keep it PG',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.cream,
              ),
            ),
            value: _keepItPG,
            activeTrackColor: AppColors.cream.withValues(alpha: 0.3),
            activeThumbColor: AppColors.cream,
            inactiveTrackColor: AppColors.cream.withValues(alpha: 0.1),
            inactiveThumbColor: AppColors.cream.withValues(alpha: 0.4),
            trackOutlineColor: WidgetStatePropertyAll(
              AppColors.cream.withValues(alpha: 0.1),
            ),
            onChanged: (value) => setState(() => _keepItPG = value),
          ),
        ),
        const Spacer(flex: 3),
        _BottomButton(
          label: 'Next',
          accentColor: _accentColor,
          onTap: () => setState(() => _step = 1),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildNotificationsStep() {
    return Column(
      key: const ValueKey('notifications'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 2),
        Text(
          'Want severe\nweather alerts?',
          style: GoogleFonts.quicksand(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.cream,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cream.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            title: Text(
              'Severe weather alerts',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.cream,
              ),
            ),
            subtitle: Text(
              'Tornado warnings, severe thunderstorms, and other NWS alerts.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.cream,
              ),
            ),
            value: _severeAlertsEnabled,
            activeTrackColor: AppColors.cream.withValues(alpha: 0.3),
            activeThumbColor: AppColors.cream,
            inactiveTrackColor: AppColors.cream.withValues(alpha: 0.1),
            inactiveThumbColor: AppColors.cream.withValues(alpha: 0.4),
            trackOutlineColor: WidgetStatePropertyAll(
              AppColors.cream.withValues(alpha: 0.1),
            ),
            onChanged: (value) async {
              if (value) {
                final granted = await FcmService().requestPermission();
                if (!granted) return;
              }
              setState(() => _severeAlertsEnabled = value);
            },
          ),
        ),
        const Spacer(flex: 3),
        _BottomButton(
          label: "Let's go",
          accentColor: _accentColor,
          onTap: _finish,
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color accentColor;

  const _BottomButton({
    required this.label,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cream,
          foregroundColor: accentColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
