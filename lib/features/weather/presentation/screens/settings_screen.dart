import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heather/features/weather/presentation/widgets/logo_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_limits.dart';
import '../../../../core/services/fcm_service.dart';
import '../providers/location_provider.dart';
import '../providers/settings_provider.dart';

/// Cached text styles to avoid repeated GoogleFonts allocations.
const _quicksandBold22Cream = TextStyle(fontFamily: 'Quicksand',
  fontSize: 22,
  fontWeight: FontWeight.w700,
  color: AppColors.cream,
);
const _poppinsW50015Cream = TextStyle(fontFamily: 'Poppins',
  fontSize: 15,
  fontWeight: FontWeight.w500,
  color: AppColors.cream,
);
const _poppins12Cream = TextStyle(fontFamily: 'Poppins',
  fontSize: 12,
  color: AppColors.cream,
);
const _poppins13Cream = TextStyle(fontFamily: 'Poppins',
  fontSize: 13,
  color: AppColors.cream,
);
const _poppinsW60013Cream = TextStyle(fontFamily: 'Poppins',
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: AppColors.cream,
);
const _poppinsW40013Cream = TextStyle(fontFamily: 'Poppins',
  fontSize: 13,
  fontWeight: FontWeight.w400,
  color: AppColors.cream,
);
const _poppinsW60013Ls05Cream = TextStyle(fontFamily: 'Poppins',
  fontSize: 13,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.5,
  color: AppColors.cream,
);
const _poppins12Cream60 = TextStyle(fontFamily: 'Poppins',
  fontSize: 12,
  color: AppColors.cream60,
);
const _poppinsW60012Cream = TextStyle(fontFamily: 'Poppins',
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: AppColors.cream,
  decoration: TextDecoration.underline,
  decorationColor: AppColors.cream,
);

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
                              style: _quicksandBold22Cream,
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
                        _SectionHeader(
                          title:
                              'Saved locations (${savedLocations.length}/$maxSavedLocations)',
                        ),
                        const SizedBox(height: 4),
                        if (savedLocations.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Um... this is awkward.  No saved locations yet.',
                              style: _poppins13Cream,
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
                                      style: _poppinsW50015Cream,
                                    ),
                                    subtitle: loc.country.isNotEmpty
                                        ? Text(
                                            [
                                              if (loc.admin1 != null &&
                                                  loc.admin1!.isNotEmpty)
                                                loc.admin1!,
                                              loc.country,
                                            ].join(', '),
                                            style: _poppins12Cream,
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
                            color: AppColors.cream15,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            title: Text(
                              'Keep it PG',
                              style: _poppinsW50015Cream,
                            ),
                            subtitle: Text(
                              'No swearing.  Clean vibes only.',
                              style: _poppins12Cream,
                            ),
                            value: !settings.explicitLanguage,
                            activeTrackColor: AppColors.cream30,
                            activeThumbColor: AppColors.cream,
                            inactiveTrackColor: AppColors.cream10,
                            inactiveThumbColor: AppColors.cream40,
                            trackOutlineColor: const WidgetStatePropertyAll(
                              AppColors.cream10,
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
                            color: AppColors.cream15,
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
                                  style: _poppinsW50015Cream,
                                ),
                                subtitle: Text(
                                  'Tornado warnings, severe thunderstorms, and other NWS alerts.',
                                  style: _poppins12Cream,
                                ),
                                value: settings.severeAlertsEnabled,
                                activeTrackColor: AppColors.cream30,
                                activeThumbColor: AppColors.cream,
                                inactiveTrackColor: AppColors.cream10,
                                inactiveThumbColor: AppColors.cream40,
                                trackOutlineColor: const WidgetStatePropertyAll(
                                  AppColors.cream10,
                                ),
                                onChanged: (value) async {
                                  if (value) {
                                    await FcmService().requestPermission();
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
                              color: AppColors.cream15,
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
                                    style: _poppins13Cream,
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

                        const SizedBox(height: 24),

                        // ── Data Sources ──
                        const _SectionHeader(title: 'Data sources'),
                        const SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.cream15,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            children: [
                              _DataSourceTile(
                                name: 'Open-Meteo',
                                description: 'Weather data by Open-Meteo.com',
                                url: 'https://open-meteo.com/',
                              ),
                              Divider(height: 1, color: AppColors.cream15),
                              _DataSourceTile(
                                name: 'OpenFreeMap',
                                description:
                                    'Maps by OpenFreeMap & OpenStreetMap',
                                url: 'https://openfreemap.org/',
                              ),
                              Divider(height: 1, color: AppColors.cream15),
                              _DataSourceTile(
                                name: 'National Weather Service',
                                description: 'Weather alerts by NWS',
                                url: 'https://www.weather.gov/',
                              ),
                              Divider(height: 1, color: AppColors.cream15),
                              _DataSourceTile(
                                name: 'Iowa Mesonet',
                                description:
                                    'Radar data by Iowa Environmental Mesonet',
                                url: 'https://mesonet.agron.iastate.edu/',
                              ),
                              Divider(height: 1, color: AppColors.cream15),
                              _DataSourceTile(
                                name: 'US Naval Observatory',
                                description: 'Astronomical data by USNO',
                                url: 'https://aa.usno.navy.mil/',
                              ),
                              Divider(height: 1, color: AppColors.cream15),
                              _DataSourceTile(
                                name: 'Visible Planets',
                                description:
                                    'Planet visibility by VisiblePlanets.dev',
                                url: 'https://visibleplanets.dev/',
                              ),
                            ],
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
                                style: _poppins12Cream60,
                                children: [
                                  TextSpan(
                                    text: 'jackie',
                                    style: _poppinsW60012Cream,
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
      child: Text(title, style: _poppinsW60013Ls05Cream),
    );
  }
}

class _DataSourceTile extends StatelessWidget {
  final String name;
  final String description;
  final String url;

  const _DataSourceTile({
    required this.name,
    required this.description,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: '$name  ',
                  style: _poppinsW60013Cream,
                  children: [
                    TextSpan(text: description, style: _poppinsW40013Cream),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.open_in_new, size: 16, color: AppColors.cream60),
          ],
        ),
      ),
    );
  }
}
