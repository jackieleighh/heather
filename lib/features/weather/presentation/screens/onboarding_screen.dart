import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/settings_provider.dart';
import '../widgets/logo_overlay.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0; // 0 = tone, 1 = notifications
  bool? _explicitLanguage;
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  Future<void> _finish() async {
    final notifier = ref.read(settingsProvider.notifier);

    if (_explicitLanguage != null) {
      await notifier.setExplicitLanguage(_explicitLanguage!);
    }

    if (_notificationsEnabled) {
      final granted = await notifier.setNotificationsEnabled(true);
      if (granted) {
        await notifier.setNotificationTime(_notificationTime);
      }
    }

    await notifier.completeOnboarding();

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.magenta,
      body: Stack(
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
    );
  }

  Widget _buildToneStep() {
    return Column(
      key: const ValueKey('tone'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 2),
        Text(
          "I'm Heather.",
          style: GoogleFonts.quicksand(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.cream,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What\'s the vibe?',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: AppColors.cream.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 32),
        _ToneOption(
          label: 'Explicit and kinda mean',
          subtitle: "I won't hold back.",
          selected: _explicitLanguage == true,
          onTap: () => setState(() => _explicitLanguage = true),
        ),
        const SizedBox(height: 12),
        _ToneOption(
          label: 'Keep it nice',
          subtitle: 'Clean language, same sass.',
          selected: _explicitLanguage == false,
          onTap: () => setState(() => _explicitLanguage = false),
        ),
        const Spacer(flex: 3),
        if (_explicitLanguage != null)
          _BottomButton(label: 'Next', onTap: () => setState(() => _step = 1)),
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
          'Want me to wake\nyou up with\nthe weather?',
          style: GoogleFonts.quicksand(
            fontSize: 28,
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
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: Text(
                  'Daily weather alert',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.cream,
                  ),
                ),
                subtitle: Text(
                  'A daily nudge from yours truly.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.cream.withValues(alpha: 0.6),
                  ),
                ),
                value: _notificationsEnabled,
                activeTrackColor: AppColors.cream.withValues(alpha: 0.3),
                activeThumbColor: AppColors.cream,
                inactiveTrackColor: AppColors.cream.withValues(alpha: 0.1),
                inactiveThumbColor: AppColors.cream.withValues(alpha: 0.4),
                trackOutlineColor: WidgetStatePropertyAll(
                  AppColors.cream.withValues(alpha: 0.1),
                ),
                onChanged: (value) =>
                    setState(() => _notificationsEnabled = value),
              ),
              if (_notificationsEnabled)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    'Notification time',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.cream,
                    ),
                  ),
                  trailing: Text(
                    _notificationTime.format(context),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: AppColors.cream.withValues(alpha: 0.8),
                    ),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _notificationTime,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            timePickerTheme: TimePickerThemeData(
                              backgroundColor: AppColors.midnightPurple,
                              hourMinuteTextColor: AppColors.cream,
                              hourMinuteColor: AppColors.vibrantPurple
                                  .withValues(alpha: 0.3),
                              dayPeriodTextColor: AppColors.cream,
                              dayPeriodColor: AppColors.vibrantPurple
                                  .withValues(alpha: 0.3),
                              dialHandColor: AppColors.vibrantPurple,
                              dialBackgroundColor: AppColors.vibrantPurple
                                  .withValues(alpha: 0.15),
                              dialTextColor: AppColors.cream,
                              entryModeIconColor: AppColors.cream.withValues(
                                alpha: 0.6,
                              ),
                              helpTextStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.cream,
                              ),
                              hourMinuteTextStyle: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w500,
                              ),
                              dayPeriodTextStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              dayPeriodShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              dayPeriodBorderSide: BorderSide(
                                color: AppColors.cream.withValues(alpha: 0.2),
                              ),
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.cream,
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaler: const TextScaler.linear(0.9),
                            ),
                            child: child!,
                          ),
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() => _notificationTime = picked);
                    }
                  },
                ),
            ],
          ),
        ),
        const Spacer(flex: 3),
        _BottomButton(label: "Let's go", onTap: _finish),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _ToneOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ToneOption({
    required this.label,
    required this.subtitle,
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
          color: selected
              ? AppColors.cream.withValues(alpha: 0.25)
              : AppColors.cream.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.cream.withValues(alpha: 0.6)
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.cream.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                color: AppColors.cream.withValues(alpha: 0.8),
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

  const _BottomButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cream,
          foregroundColor: AppColors.magenta,
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
