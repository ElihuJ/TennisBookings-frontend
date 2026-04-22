import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_helpers/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../strings/index.dart';
import '../../../theme/index.dart';
import '../../club_details/club_details_screen.dart';

class ScheduleHeader extends HookConsumerWidget {
  const ScheduleHeader({
    super.key,
    required this.clubSelected,
    required this.courts,
    required this.courtSelected,
    required this.setState,
  });

  final Club clubSelected;
  final Court courtSelected;
  final List<Court> courts;
  final void Function(String? newValue) setState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortedCourts = courts..sort((a, b) => a.name.compareTo(b.name));
    final user = ref.watch(userProvider);
    final isMember = user.memberships.any((m) => m.clubId == clubSelected.id);
    final mobileScreen = isMobile(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // ─── Club pill ────────────────────────────────────────────────
          GestureDetector(
            onTap: () => Navigator.of(context)
                .pushNamed('${ClubDetailsScreen.route}?clubId=${clubSelected.id}'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.darkGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkGreen.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Club logo
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          clubSelected.clubLogoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.sports_tennis, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      clubSelected.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isMember && !mobileScreen) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          context.localeString(ClubsStrings.isMember),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 11),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ─── Court selector card ──────────────────────────────────────
          _CourtSelectorCard(
            courtSelected: courtSelected,
            sortedCourts: sortedCourts,
            onChanged: setState,
          ),
        ],
      ),
    );
  }
}

// ─── Court selector ───────────────────────────────────────────────────────────

class _CourtSelectorCard extends StatelessWidget {
  const _CourtSelectorCard({
    required this.courtSelected,
    required this.sortedCourts,
    required this.onChanged,
  });

  final Court courtSelected;
  final List<Court> sortedCourts;
  final void Function(String? newValue) onChanged;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = getSurfaceColor(courtSelected.surface);
    final accentColor = surfaceColor == AppColors.white ? AppColors.primaryGreen : surfaceColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            // Override canvasColor so the DropdownButton background is white, not almostWhite
            Theme(
              data: Theme.of(context).copyWith(canvasColor: Colors.white),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: courtSelected.id,
                  isDense: true,
                  icon: Icon(Icons.keyboard_arrow_down, size: 20, color: accentColor),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  dropdownColor: Colors.white,
                  onChanged: (newValue) {
                    if (newValue != courtSelected.id) onChanged(newValue);
                  },
                  selectedItemBuilder: (context) => sortedCourts
                      .map((c) => Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              textToTitleCase('${c.name} — ${c.surface}'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ))
                      .toList(),
                  items: sortedCourts.map((court) {
                    final tileColor = getSurfaceColor(court.surface);
                    final label = textToTitleCase('${court.name} — ${court.surface}');
                    return DropdownMenuItem<String>(
                      value: court.id,
                      child: _CourtTile(color: tileColor, label: label),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourtTile extends StatelessWidget {
  const _CourtTile({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final accentColor = color == AppColors.white ? AppColors.primaryGreen : color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ],
    );
  }
}

Color getSurfaceColor(String surface) {
  switch (surface.toLowerCase()) {
    case 'grass':
      return SurfaceColors.grass;
    case 'clay':
      return SurfaceColors.clay;
    case 'hard':
      return SurfaceColors.hard;
    default:
      return AppColors.white;
  }
}
