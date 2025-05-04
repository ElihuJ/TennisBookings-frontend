import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../global_widgets/index.dart';
import '../../state/index.dart';
import '../../theme/colors.dart';
import '../club_details/club_details_screen.dart';
import '../calendar/calendar_screen.dart';

const _googleUrl = 'https://www.google.com/maps/search/?api=1&query=';

class ClubsTable extends StatefulWidget {
  final List<Club> clubs;

  const ClubsTable({super.key, required this.clubs});

  @override
  State<StatefulWidget> createState() => _ClubsTableState();
}

class _ClubsTableState extends State<ClubsTable> {
  final rowSelected = ValueNotifier<int>(-1);

  final wideColumnTitles = [
    'Club Name',
    'Hard\nCourts',
    'Clay\nCourts',
    'Grass\nCourts',
    'Other\nCourts',
    'Address',
    'Suburb',
    'Annua\nFee',
    'Casual\nFee',
    'Club Schedule',
    'More Info',
  ];

  final narrowColumnTitles = [
    'Club\nDetails',
    'Club\nSchedule',
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredClubs = widget.clubs.where((club) => club.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    final screenWidth = MediaQuery.of(context).size.width;

    final wideScreen = screenWidth > 1800;
    final mediumScreen = screenWidth > 1200 && screenWidth <= 1800;
    final isMobile = screenWidth < 600;
    final fontSize = isMobile
        ? 12.0
        : wideScreen
            ? 16.0
            : mediumScreen
                ? 14.0
                : 12.0;

    final titlesToDisplay = isMobile ? narrowColumnTitles : wideColumnTitles;

    return SizedBox(
      height: double.infinity,
      child: Column(
        children: [
          Container(
            width: isMobile ? 300 : 500,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                labelText: 'Search Clubs',
                prefixIcon: Icon(Icons.search),
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.grey,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.primaryGreen,
                    width: 2,
                  ),
                ),
                labelStyle: TextStyle(
                  color: AppColors.grey, // * Default color
                ),
                floatingLabelStyle: TextStyle(
                  color: AppColors.primaryGreen, // * Change color when focused
                  fontSize: fontSize,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  border: TableBorder.all(
                    color: AppColors.black,
                    width: 2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      children: titlesToDisplay
                          .asMap()
                          .map((index, title) {
                            return MapEntry(index, _HeaderCell(text: title, first: index == 0, last: index == titlesToDisplay.length - 1));
                          })
                          .values
                          .toList(growable: false),
                    ),
                    ...filteredClubs.map((club) {
                      return TableRow(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        children: [
                          if (!isMobile) _RowCellText(text: club.name),
                          if (isMobile)
                            _RowCellText(
                                text: club.name,
                                isButton: true,
                                onPressed: () => Navigator.of(context).pushNamed('${ClubDetailsScreen.route}?clubId=${club.id}')),
                          if (!isMobile) _RowCellText(text: club.hardCourts.toString()),
                          if (!isMobile) _RowCellText(text: club.clayCourts.toString()),
                          if (!isMobile) _RowCellText(text: club.grassCourts.toString()),
                          if (!isMobile) _RowCellText(text: club.otherSurfaceCourts.toString()),
                          if (!isMobile)
                            _RowCellText(
                              text: 'See in Maps',
                              isButton: true,
                              onPressed: () {
                                final url =
                                    '$_googleUrl${Uri.encodeComponent('${club.streetAddress}, ${club.suburb}, ${club.state}, ${club.postcode}')}';
                                launchUrl(Uri.parse(url));
                              },
                            ),
                          if (!isMobile) _RowCellText(text: club.suburb),
                          if (!isMobile) _RowCellText(text: '\$ ${club.annualFee.toString()}'),
                          if (!isMobile) _RowCellText(text: '\$ ${club.casualFee.toString()}'),
                          _RowCellText(
                            text: 'Book a court',
                            isButton: true,
                            onPressed: () => Navigator.of(context).pushNamed('${ScheduleScreen.route}?clubId=${club.id}'),
                          ),
                          if (!isMobile)
                            _RowCellText(
                              text: 'Club details',
                              isButton: true,
                              onPressed: () => Navigator.of(context).pushNamed('${ClubDetailsScreen.route}?clubId=${club.id}'),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowCellText extends StatelessWidget {
  const _RowCellText({required this.text, this.isButton = false, this.onPressed});

  final String text;
  final bool isButton;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final smallScreen = screenWidth < 600;
    final fontSize = smallScreen ? 12.0 : 16.0;
    return MouseRegion(
      cursor: isButton ? SystemMouseCursors.click : MouseCursor.defer,
      child: Padding(
        padding: smallScreen ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0) : const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isButton
                ? TbTextButton(
                    onPressed: () => onPressed?.call(),
                    text: text,
                  )
                : GestureDetector(
                    onTap: onPressed,
                    child: PrettyText(
                      text,
                      textAlign: TextAlign.center,
                      fontSize: fontSize,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final bool first;
  final bool last;

  const _HeaderCell({required this.text, this.first = false, this.last = false});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final smallScreen = screenWidth < 600;
    final fontSize = smallScreen ? 14.0 : 18.0;
    return Container(
      alignment: Alignment.center,
      height: smallScreen ? 70 : 80,
      padding: smallScreen ? const EdgeInsets.all(12.0) : const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.secondaryGreen,
        borderRadius: BorderRadius.only(
          topLeft: first ? Radius.circular(10) : Radius.zero,
          topRight: last ? Radius.circular(10) : Radius.zero,
        ),
      ),
      child: PrettyText(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
