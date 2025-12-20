import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../global_helpers/index.dart';
import '../../global_widgets/index.dart';
import '../../state/index.dart';
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
          // * Search
          Container(
            width: mobileView ? double.infinity : 700,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                labelText: 'Search clubs or suburbs',
                prefixIcon: Icon(Icons.search),
                floatingLabelStyle: TextStyle(color: AppColors.primaryGreen),
                fillColor: AppColors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primaryGreen, width: 2)),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),

          // * Cards
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: LayoutBuilder(builder: (context, constraints) {
                final crossAxis = mobileView ? 1 : (constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1));
                if (filteredClubs.isEmpty) {
                  return Center(child: PrettyText('No clubs found', style: TextStyle(color: AppColors.almostWhite)));
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxis,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 4.0,
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

class _ClubCard extends StatelessWidget {
  final Club club;
  const _ClubCard({required this.club});

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.white.withValues(alpha: 0.5),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed('${ClubDetailsScreen.route}?clubId=${club.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: mobile ? 30 : 40,
                  backgroundImage: NetworkImage(club.clubLogoUrl),
                  backgroundColor: Colors.grey[200],
                ),
                SizedBox(width: mobile ? 12 : 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PrettyText(club.name,
                          style: TextStyle(fontSize: mobile ? 14 : 16, fontWeight: FontWeight.w700, color: AppColors.black)),
                      SizedBox(height: 4),
                      PrettyText(club.suburb, style: TextStyle(color: AppColors.grey)),
                      SizedBox(height: 6),
                      PrettyText(
                          '${club.hardCourts} Hard • ${club.clayCourts} Clay • ${club.grassCourts} Grass • ${club.otherSurfaceCourts} Others',
                          style: TextStyle(color: AppColors.grey)),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: 'Open in Maps',
                      child: IconButton(
                        icon: Icon(Icons.location_on, color: AppColors.primaryGreen),
                        onPressed: () {
                          final url =
                              '$_googleUrl${Uri.encodeComponent('${club.streetAddress}, ${club.suburb}, ${club.state}, ${club.postcode}')}';
                          launchUrl(Uri.parse(url));
                        },
                      ),
                    ),
                    Tooltip(
                      message: 'Book a court',
                      child: IconButton(
                        icon: Icon(Icons.calendar_month, color: AppColors.primaryGreen),
                        onPressed: () => Navigator.of(context).pushNamed('${CalendarScreen.route}?clubId=${club.id}'),
                      ),
                    ),
                    Tooltip(
                      message: 'More info',
                      child: IconButton(
                        icon: Icon(Icons.info_outline, color: AppColors.primaryGreen),
                        onPressed: () => Navigator.of(context).pushNamed('${ClubDetailsScreen.route}?clubId=${club.id}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
