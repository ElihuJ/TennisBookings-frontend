import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../global_helpers/index.dart';
import '../../state/index.dart';
import '../../strings/index.dart';
import '../../theme/colors.dart';
import '../calendar/calendar_screen.dart';
import '../club_details/club_details_screen.dart';

const _googleUrl = 'https://www.google.com/maps/search/?api=1&query=';

class ClubsTable extends StatefulWidget {
  final List<Club> clubs;

  const ClubsTable({super.key, required this.clubs});

  @override
  State<StatefulWidget> createState() => _ClubsTableState();
}

class _ClubsTableState extends State<ClubsTable> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);

    final filteredClubs = widget.clubs.where((club) {
      final q = searchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      return club.name.toLowerCase().contains(q) || club.suburb.toLowerCase().contains(q);
    }).toList();

    return SizedBox(
      height: double.infinity,
      child: Column(
        children: [
          // ─── Hero + Search ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              children: [
                _FindClubsHero(clubCount: widget.clubs.length),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    labelText: context.localeString(ClubsStrings.searchPlaceholder),
                    prefixIcon: const Icon(Icons.search),
                    floatingLabelStyle: const TextStyle(color: AppColors.primaryGreen),
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                    ),
                  ),
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
              ],
            ),
          ),

          // ─── Club grid ────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: LayoutBuilder(builder: (context, constraints) {
                final crossAxis = mobileView ? 1 : (constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1));

                if (filteredClubs.isEmpty) {
                  return Center(
                    child: Text(
                      context.localeString(ClubsStrings.noClubsFound),
                      style: const TextStyle(color: AppColors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxis,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3.2,
                  ),
                  itemCount: filteredClubs.length,
                  itemBuilder: (context, i) => _ClubCard(club: filteredClubs[i]),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────

class _FindClubsHero extends StatelessWidget {
  const _FindClubsHero({required this.clubCount});

  final int clubCount;

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: mobileView ? 18 : 22,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.location_city_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.localeString(ClubsStrings.bookACourt),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: mobileView ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      context.localeString(ClubsStrings.findSubtitle),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '$clubCount clubs',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Club card ────────────────────────────────────────────────────────────────

class _ClubCard extends StatelessWidget {
  final Club club;
  const _ClubCard({required this.club});

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed('${CalendarScreen.route}?clubId=${club.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Row(
            children: [
              // Logo
              Container(
                width: mobile ? 52 : 62,
                height: mobile ? 52 : 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    club.clubLogoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      child: const Icon(Icons.sports_tennis, color: AppColors.primaryGreen),
                    ),
                  ),
                ),
              ),
              SizedBox(width: mobile ? 12 : 16),
              // Club info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      club.name,
                      style: TextStyle(
                        fontSize: mobile ? 14 : 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.grey),
                        const SizedBox(width: 3),
                        Text(
                          club.suburb,
                          style: const TextStyle(fontSize: 12, color: AppColors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _SurfaceChips(club: club),
                  ],
                ),
              ),
              // Actions
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionIcon(
                    icon: Icons.location_on_outlined,
                    tooltip: context.localeString(ClubsStrings.openInMaps),
                    onTap: () {
                      final url =
                          '$_googleUrl${Uri.encodeComponent('${club.streetAddress}, ${club.suburb}, ${club.state}, ${club.postcode}')}';
                      launchUrl(Uri.parse(url));
                    },
                  ),
                  _ActionIcon(
                    icon: Icons.calendar_month_outlined,
                    tooltip: context.localeString(ClubsStrings.bookACourt),
                    onTap: () => Navigator.of(context)
                        .pushNamed('${CalendarScreen.route}?clubId=${club.id}'),
                  ),
                  _ActionIcon(
                    icon: Icons.credit_card_outlined,
                    tooltip: context.localeString(ClubsStrings.membershipDetails),
                    onTap: () => Navigator.of(context)
                        .pushNamed('${ClubDetailsScreen.route}?clubId=${club.id}'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurfaceChips extends StatelessWidget {
  const _SurfaceChips({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final surfaces = <(String, Color)>[];
    if (club.hardCourts > 0) surfaces.add(('${club.hardCourts} Hard', SurfaceColors.hard));
    if (club.clayCourts > 0) surfaces.add(('${club.clayCourts} Clay', SurfaceColors.clay));
    if (club.grassCourts > 0) surfaces.add(('${club.grassCourts} Grass', SurfaceColors.grass));
    if (club.otherSurfaceCourts > 0) surfaces.add(('${club.otherSurfaceCourts} Other', AppColors.grey));

    if (surfaces.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: surfaces
          .map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: s.$2.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: s.$2.withValues(alpha: 0.4)),
                ),
                child: Text(
                  s.$1,
                  style: TextStyle(fontSize: 10, color: s.$2, fontWeight: FontWeight.w600),
                ),
              ))
          .toList(),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: AppColors.primaryGreen),
        ),
      ),
    );
  }
}
