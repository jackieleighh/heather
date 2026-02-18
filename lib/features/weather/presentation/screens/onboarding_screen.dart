import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/persona.dart';
import '../../../../core/services/fcm_service.dart';
import '../providers/settings_provider.dart';
import '../widgets/logo_overlay.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0; // 0 = persona, 1 = tone, 2 = notifications
  Persona _persona = Persona.heather;
  bool? _explicitLanguage;
  bool _severeAlertsEnabled = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  Future<void> _finish() async {
    final notifier = ref.read(settingsProvider.notifier);

    await notifier.setPersona(_persona);

    if (_explicitLanguage != null) {
      await notifier.setExplicitLanguage(_explicitLanguage!);
    }

    await notifier.setSevereAlertsEnabled(_severeAlertsEnabled);

    await notifier.completeOnboarding();

    if (mounted) {
      context.go('/');
    }
  }

  Color get _accentColor => _persona.heroColor;

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
                      ? _buildPersonaStep()
                      : _step == 1
                      ? _buildToneStep()
                      : _buildNotificationsStep(),
                ),
              ),
            ),
            LogoOverlay(personaOverride: _persona),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaStep() {
    return Column(
      key: const ValueKey('persona'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 2),
        Text(
          'Pick your\nweather girl.',
          style: GoogleFonts.quicksand(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.cream,
          ),
        ),
        const SizedBox(height: 32),
        ...Persona.values.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PersonaCard(
              persona: p,
              selected: _persona == p,
              onTap: () => setState(() => _persona = p),
            ),
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
        _ToneOption(
          label: _persona.toneLabel,
          selected: _explicitLanguage == false,
          onTap: () => setState(() => _explicitLanguage = false),
        ),
        const SizedBox(height: 12),
        _ToneOption(
          label: _persona.altToneLabel,
          selected: _explicitLanguage == true,
          onTap: () => setState(() => _explicitLanguage = true),
        ),
        const Spacer(flex: 3),
        if (_explicitLanguage != null)
          _BottomButton(
            label: 'Next',
            accentColor: _accentColor,
            onTap: () => setState(() => _step = 2),
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

class _PersonaCard extends StatelessWidget {
  final Persona persona;
  final bool selected;
  final VoidCallback onTap;

  const _PersonaCard({
    required this.persona,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cream.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.cream.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cream.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  persona.initial,
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cream,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    persona.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: AppColors.cream,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

class _ToneOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToneOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cream.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.cream.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: AppColors.cream,
                size: 24,
              ),
          ],
        ),
      ),
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
