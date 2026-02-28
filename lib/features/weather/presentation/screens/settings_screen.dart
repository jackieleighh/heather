import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/features/weather/presentation/widgets/logo_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/fcm_service.dart';
import '../providers/location_provider.dart';
import '../providers/settings_provider.dart';

const _kSuggestionPhone = '8564123991';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedLocations = ref.watch(savedLocationsProvider);
    final settings = ref.watch(settingsProvider);

    const accentColor = AppColors.magenta;

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
                              'Um... this is awkward.  No saved locations yet.',
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

                        // ── Preferences ──
                        const _SectionHeader(title: 'Preferences'),
                        const SizedBox(height: 4),
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
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.cream,
                              ),
                            ),
                            subtitle: Text(
                              'No swearing.  Clean vibes only.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.cream,
                              ),
                            ),
                            value: !settings.explicitLanguage,
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
                            onChanged: (value) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .setExplicitLanguage(!value);
                            },
                          ),
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
                                    final granted = await FcmService()
                                        .requestPermission();
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

                        const SizedBox(height: 24),

                        // ── Suggestions Box ──
                        const _SectionHeader(title: 'Suggestions box'),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            final uri = Uri(
                              scheme: 'sms',
                              path: _kSuggestionPhone,
                            );
                            launchUrl(uri);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.cream.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Got a quip? Text Heather. She's bad with her phone but maybe she'll see it.",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppColors.cream,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.sms,
                                  size: 24,
                                  color: AppColors.cream,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        Center(
                          child: GestureDetector(
                            onTap: () => launchUrl(
                              Uri.parse('https://jackie-the-dev.web.app/'),
                              mode: LaunchMode.externalApplication,
                            ),
                            child: Text.rich(
                              TextSpan(
                                text: 'made with love by ',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.cream.withValues(alpha: 0.6),
                                ),
                                children: [
                                  TextSpan(
                                    text: 'jackie',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.cream,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.cream,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
