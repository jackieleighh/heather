import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/features/weather/presentation/widgets/logo_overlay.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/persona.dart';
import '../../../../core/services/fcm_service.dart';
import '../providers/location_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedLocations = ref.watch(savedLocationsProvider);
    final settings = ref.watch(settingsProvider);

    final accentColor = settings.persona.heroColor;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        color: accentColor,
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 54, 0),
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: AppColors.cream,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Settings',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.quicksand(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cream,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      children: [
                        // ── Saved Locations ──
                        const _SectionHeader(title: 'Saved locations'),
                        const SizedBox(height: 4),
                        if (savedLocations.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Um... No saved locations yet.  This is awkward.',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.cream,
                              ),
                            ),
                          )
                        else
                          ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            proxyDecorator: (child, index, animation) {
                              return Material(
                                color: Colors.transparent,
                                elevation: 0,
                                child: child,
                              );
                            },
                            onReorder: (oldIndex, newIndex) {
                              ref
                                  .read(savedLocationsProvider.notifier)
                                  .reorderLocations(oldIndex, newIndex);
                            },
                            itemCount: savedLocations.length,
                            itemBuilder: (context, index) {
                              final loc = savedLocations[index];
                              return Dismissible(
                                key: Key(loc.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.red[700],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (_) {
                                  ref
                                      .read(savedLocationsProvider.notifier)
                                      .removeLocation(loc.id);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.cream.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    leading: ReorderableDragStartListener(
                                      index: index,
                                      child: const Icon(
                                        Icons.drag_handle,
                                        color: AppColors.cream,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      loc.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.cream,
                                      ),
                                    ),
                                    subtitle: loc.country.isNotEmpty
                                        ? Text(
                                            [
                                              if (loc.admin1 != null &&
                                                  loc.admin1!.isNotEmpty)
                                                loc.admin1!,
                                              loc.country,
                                            ].join(', '),
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: AppColors.cream,
                                            ),
                                          )
                                        : null,
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.cream,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        ref
                                            .read(
                                              savedLocationsProvider.notifier,
                                            )
                                            .removeLocation(loc.id);
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 24),

                        // ── Persona ──
                        const _SectionHeader(title: 'Persona'),
                        const SizedBox(height: 4),
                        ...Persona.values.map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _PersonaTile(
                              persona: p,
                              selected: settings.persona == p,
                              onTap: () {
                                ref
                                    .read(settingsProvider.notifier)
                                    .setPersona(p);
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Preferences ──
                        const _SectionHeader(title: 'Preferences'),
                        const SizedBox(height: 4),
                        _ToneTile(
                          label: settings.persona.toneLabel,
                          selected: !settings.explicitLanguage,
                          onTap: () {
                            ref
                                .read(settingsProvider.notifier)
                                .setExplicitLanguage(false);
                          },
                        ),
                        const SizedBox(height: 8),
                        _ToneTile(
                          label: settings.persona.altToneLabel,
                          selected: settings.explicitLanguage,
                          onTap: () {
                            ref
                                .read(settingsProvider.notifier)
                                .setExplicitLanguage(true);
                          },
                        ),

                        const SizedBox(height: 24),

                        // ── Notifications ──
                        const _SectionHeader(title: 'Notifications'),
                        const SizedBox(height: 4),
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
                                value: settings.severeAlertsEnabled,
                                activeTrackColor: AppColors.cream.withValues(
                                  alpha: 0.3,
                                ),
                                activeThumbColor: AppColors.cream,
                                inactiveTrackColor: AppColors.cream.withValues(
                                  alpha: 0.1,
                                ),
                                inactiveThumbColor: AppColors.cream.withValues(
                                  alpha: 0.4,
                                ),
                                trackOutlineColor: WidgetStatePropertyAll(
                                  AppColors.cream.withValues(alpha: 0.1),
                                ),
                                onChanged: (value) async {
                                  if (value) {
                                    final granted =
                                        await FcmService().requestPermission();
                                    if (!granted) return;
                                  }
                                  ref
                                      .read(settingsProvider.notifier)
                                      .setSevereAlertsEnabled(value);
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const LogoOverlay(),
          ],
        ),
      ),
    );
  }
}

class _PersonaTile extends StatelessWidget {
  final Persona persona;
  final bool selected;
  final VoidCallback onTap;

  const _PersonaTile({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.cream.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  persona.initial,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cream,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                persona.displayName,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cream,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: AppColors.cream,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class _ToneTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToneTile({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cream,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: AppColors.cream,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.cream,
        ),
      ),
    );
  }
}
