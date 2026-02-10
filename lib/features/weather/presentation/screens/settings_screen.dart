import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/features/weather/presentation/widgets/logo_overlay.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/location_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedLocations = ref.watch(savedLocationsProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: AppColors.magenta,
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
                        const _SectionHeader(title: 'Saved Locations'),
                        const SizedBox(height: 4),
                        if (savedLocations.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'No saved locations yet. Swipe left on the main screen to add cities.',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.cream.withValues(alpha: 0.6),
                              ),
                            ),
                          )
                        else
                          ...savedLocations.map(
                            (loc) => Dismissible(
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
                                  leading: Icon(
                                    Icons.location_on_outlined,
                                    color: AppColors.cream.withValues(
                                      alpha: 0.7,
                                    ),
                                    size: 22,
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
                                            color: AppColors.cream.withValues(
                                              alpha: 0.6,
                                            ),
                                          ),
                                        )
                                      : null,
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: AppColors.cream.withValues(
                                        alpha: 0.5,
                                      ),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(savedLocationsProvider.notifier)
                                          .removeLocation(loc.id);
                                    },
                                  ),
                                ),
                              ),
                            ),
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
                              'Explicit Language',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.cream,
                              ),
                            ),
                            subtitle: Text(
                              "Heather won't hold back on the language.",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.cream.withValues(alpha: 0.6),
                              ),
                            ),
                            value: settings.explicitLanguage,
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
                            onChanged: (value) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .setExplicitLanguage(value);
                            },
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
          color: AppColors.cream.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
