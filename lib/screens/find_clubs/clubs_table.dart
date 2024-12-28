import 'package:flutter/material.dart';

import '../../state/index.dart';
import '../../theme/colors.dart';
import '../club/club_selected_screen.dart';

class ClubsTable extends StatefulWidget {
  final List<Club> clubs;

  const ClubsTable({super.key, required this.clubs});

  @override
  State<StatefulWidget> createState() => _ClubsTableState();
}

class _ClubsTableState extends State<ClubsTable> {
  final rowSelected = ValueNotifier<int>(-1);

  _ClubsTableState();

  setRowSelected(int index) {
    setState(() {
      rowSelected.value = index;
    });
  }

  onRowTapped(Club club) {
    Navigator.of(context).pushNamed(ClubSelectedScreen.route, arguments: club);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(40),
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Table(
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
              children: const [
                HeaderCell(text: 'Club Name'),
                HeaderCell(text: 'Hard Courts'),
                HeaderCell(text: 'Clay Courts'),
                HeaderCell(text: 'Grass Courts'),
                HeaderCell(text: 'Other Courts'),
                HeaderCell(text: 'Address'),
                HeaderCell(text: 'Suburb'),
                HeaderCell(text: 'Annual Fee'),
                HeaderCell(text: 'Casual Fee'),
              ],
            ),
            ...widget.clubs.map((club) {
              final index = widget.clubs.indexOf(club);

              return TableRow(
                decoration: BoxDecoration(
                  color: rowSelected.value == index ? AppColors.primaryGreen : AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                children: [
                  RowCell(text: club.name, onHover: setRowSelected, rowIndex: index, club: club, onRowTapped: onRowTapped),
                  RowCell(text: club.hardCourts.toString(), onHover: setRowSelected, rowIndex: index, club: club, onRowTapped: onRowTapped),
                  RowCell(text: club.clayCourts.toString(), onHover: setRowSelected, rowIndex: index, club: club, onRowTapped: onRowTapped),
                  RowCell(text: club.grassCourts.toString(), onHover: setRowSelected, rowIndex: index, club: club, onRowTapped: onRowTapped),
                  RowCell(text: club.otherSurfaceCourts.toString(), onHover: setRowSelected, rowIndex: index, club: club, onRowTapped: onRowTapped),
                  RowCell(
                      text: '${club.streetAddress} ${club.suburb} ${club.postcode} ${club.state}',
                      onHover: setRowSelected,
                      rowIndex: index,
                      club: club,
                      onRowTapped: onRowTapped),
                  RowCell(text: club.suburb, onHover: setRowSelected, rowIndex: index, club: club, onRowTapped: onRowTapped),
                  RowCell(text: club.annualFee.toString(), onHover: setRowSelected, rowIndex: index, club: club, onRowTapped: onRowTapped),
                  RowCell(text: club.casualFee.toString(), onHover: setRowSelected, rowIndex: index, club: club, onRowTapped: onRowTapped),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class RowCell extends StatelessWidget {
  final String text;
  final Club club;
  final Function(int index) onHover;
  final int rowIndex;
  final Function(Club club) onRowTapped;

  const RowCell({super.key, required this.text, required this.onHover, required this.rowIndex, required this.club, required this.onRowTapped});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onRowTapped(club),
      child: MouseRegion(
        onExit: (_) => onHover(-1),
        onEnter: (_) => onHover(rowIndex),
        child: Padding(padding: const EdgeInsets.all(8.0), child: Text(text, style: const TextStyle(color: Colors.black))),
      ),
    );
  }
}

class HeaderCell extends StatelessWidget {
  final String text;

  const HeaderCell({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }
}
