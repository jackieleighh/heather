import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/location_provider.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedLocations = ref.watch(savedLocationsProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Settings',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.deepPurple,
            ),
          ),
          const SizedBox(height: 20),

          // Saved Locations section
          Text(
            'Saved Locations',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.deepPurple,
            ),
          ),
          const SizedBox(height: 4),
          if (savedLocations.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'No saved locations yet. Tap the + button to add cities.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            )
          else
            ...savedLocations.map((loc) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.teal,
                    size: 20,
                  ),
                  title: Text(
                    loc.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.deepPurple,
                    ),
                  ),
                  subtitle: loc.country.isNotEmpty
                      ? Text(
                          loc.country,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        )
                      : null,
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red[300],
                      size: 20,
                    ),
                    onPressed: () {
                      ref
                          .read(savedLocationsProvider.notifier)
                          .removeLocation(loc.id);
                    },
                  ),
                )),
        ],
      ),
    );
  }
}
