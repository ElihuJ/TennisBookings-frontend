import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../global_widgets/index.dart';
import '../../state/index.dart';
import '../../theme/colors.dart';
import '../club/club_details_screen.dart';
import '../club/schedule_screen.dart';

const googleUrl = 'https://www.google.com/maps/search/?api=1&query=';

class ClubsTable extends StatefulWidget {
  final List<Club> clubs;

  const ClubsTable({super.key, required this.clubs});

  @override
  State<StatefulWidget> createState() => _ClubsTableState();
}

class _ClubsTableState extends State<ClubsTable> {
  final rowSelected = ValueNotifier<int>(-1);

  final columnTitles = [
    'Club Name',
    'Hard Courts',
    'Clay Courts',
    'Grass Courts',
    'Other Courts',
    'Address',
    'Suburb',
    'Annual Fee',
    'Casual Fee',
    'Book a court',
    'Club details',
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredClubs = widget.clubs.where((club) => club.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final fontSize = isMobile
        ? 12.0
        : isTablet
            ? 14.0
            : 16.0;

    return SizedBox(
      height: double.infinity,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
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
                      children: columnTitles
                          .asMap()
                          .map((index, title) {
                            return MapEntry(index, _HeaderCell(text: title, first: index == 0, last: index == columnTitles.length - 1));
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
                          _RowCellText(text: club.name),
                          _RowCellText(text: club.hardCourts.toString()),
                          _RowCellText(text: club.clayCourts.toString()),
                          _RowCellText(text: club.grassCourts.toString()),
                          _RowCellText(text: club.otherSurfaceCourts.toString()),
                          _RowCellText(
                            text: '${club.streetAddress} ${club.suburb} ${club.postcode} ${club.state}',
                            isAddress: true,
                            onPressed: () {
                              final url =
                                  '$googleUrl${Uri.encodeComponent('${club.streetAddress}, ${club.suburb}, ${club.state}, ${club.postcode}')}';
                              launchUrl(Uri.parse(url));
                            },
                          ),
                          _RowCellText(text: club.suburb),
                          _RowCellText(text: '\$ ${club.annualFee.toString()}'),
                          _RowCellText(text: '\$ ${club.casualFee.toString()}'),
                          _RowCellText(
                            text: 'Book a court',
                            isButton: true,
                            onPressed: () => Navigator.of(context).pushNamed('${ScheduleScreen.route}?clubId=${club.id}', arguments: club),
                          ),
                          _RowCellText(
                            text: 'Club details',
                            isButton: true,
                            onPressed: () => Navigator.of(context).pushNamed('${ClubDetailsScreen.route}?clubId=${club.id}', arguments: club),
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
  const _RowCellText({required this.text, this.isAddress = false, this.isButton = false, this.onPressed});

  final String text;
  final bool isAddress;
  final bool isButton;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final smallScreen = screenWidth < 600;
    final fontSize = smallScreen ? 12.0 : 16.0;
    return MouseRegion(
      cursor: isAddress ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Padding(
          padding: smallScreen ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0) : const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isAddress)
                const Icon(
                  Icons.location_on,
                  color: AppColors.secondaryGreen,
                ),
              if (isButton)
                TbTextButton(
                  onPressed: () => onPressed?.call(),
                  text: text,
                ),
              if (!isButton)
                GestureDetector(
                  onTap: onPressed,
                  child: PrettyText(
                    text,
                    textAlign: TextAlign.center,
                    fontSize: fontSize,
                  ),
                ),
            ],
          )),
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
    final fontSize = smallScreen ? 12.0 : 16.0;
    return Container(
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
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
