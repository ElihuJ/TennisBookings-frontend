import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_widgets/containers/bordered_box.dart';
import 'package:tennisbookings/global_widgets/header/header.dart';
import 'package:tennisbookings/state/clubs/clubs_provider.dart';
import 'package:tennisbookings/state/clubs/clubs_state.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../global_widgets/index.dart';
import '../../routes/index.dart';

class ClubDetailsScreen extends HookConsumerWidget {
  const ClubDetailsScreen({super.key, required this.clubSelectedQueryParams});

  final ClubSelectedQueryParams clubSelectedQueryParams;

  static const String route = 'ClubDetails';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubs = ref.watch(clubsProvider);
    final clubsNotifier = ref.read(clubsProvider.notifier);

    final clubSelected = clubs.firstWhereOrNull((club) => club.id == clubSelectedQueryParams.clubId);

    // * This will execute when refreshing page or loading specific URL directly
    if (clubs.isEmpty) {
      clubsNotifier.loadClubs();
      return const Scaffold(
        body: Center(
          child: Text('Loading clubs...'),
        ),
      );
    }

    if (clubSelected == null) {
      return const NotFoundScreen(
        message: 'The club you are looking for does not exist.',
      );
    }

    return Scaffold(
      appBar: Header(),
      body: BorderedBox(
        padding: const EdgeInsets.all(20.0),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(clubSelected.clubLogoUrl),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 20),
            Text(
              clubSelected.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Improved contrast for better visibility
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            _AddressSection(clubSelected: clubSelected),
            const SizedBox(height: 40),
            _ClubDetailsCard(clubSelected: clubSelected),
            const SizedBox(height: 20),
            _ContactCard(clubSelected: clubSelected),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.clubSelected});

  final Club clubSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6, // Increased elevation to make it stand out
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // More rounded corners for emphasis
      ),
      child: Container(
        width: 350, // Set a fixed width for consistency with other cards
        padding: const EdgeInsets.all(20.0), // Increased padding for a more prominent look
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent], // Gradient background for emphasis
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // Slightly larger font size for emphasis
                    color: Colors.white, // White text for contrast against gradient
                  ),
            ),
            const Divider(color: Colors.white), // White divider for contrast
            PrettyText(
              'Email: ${clubSelected.contactEmail}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
            PrettyText(
              'Phone: ${clubSelected.contactPhone}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubDetailsCard extends StatelessWidget {
  const _ClubDetailsCard({required this.clubSelected});

  final Club clubSelected;

  @override
  Widget build(BuildContext context) {
    const double fontSize = 20;
    const space = SizedBox(height: 16);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 550, // Set a fixed width for the card to make it narrower
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PrettyText(
              'Club Details',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24, // Increased font size
                  ),
            ),
            const Divider(),
            PrettyText(
              'Hard Courts: ${clubSelected.hardCourts}',
              fontSize: fontSize,
            ),
            PrettyText(
              'Clay Courts: ${clubSelected.clayCourts}',
              fontSize: fontSize,
            ),
            PrettyText(
              'Grass Courts: ${clubSelected.grassCourts}',
              fontSize: fontSize,
            ),
            PrettyText(
              'Other Surface Courts: ${clubSelected.otherSurfaceCourts}',
              fontSize: fontSize,
            ),
            space,
            PrettyText('Only Members: ${clubSelected.onlyMembers ? "Yes" : "No"}', fontSize: fontSize),
            PrettyText('Public Bookings Allowed: ${clubSelected.allowPublicBookings ? "Yes" : "No"}', fontSize: fontSize),
            space,
            PrettyText('Annual Fee: \$${clubSelected.annualFee.toStringAsFixed(2)}', fontSize: fontSize),
            if (clubSelected.casualFee != null) PrettyText('Casual Fee: \$${clubSelected.casualFee!.toStringAsFixed(2)}', fontSize: fontSize),
            space,
            PrettyText('Total Members: ${clubSelected.totalMembers}', fontSize: fontSize),
          ],
        ),
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.clubSelected});

  final Club clubSelected;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          final googleMapsUrl = Uri.encodeFull(
            'https://www.google.com/maps/search/?api=1&query=${clubSelected.streetAddress}, ${clubSelected.suburb}, ${clubSelected.city}, ${clubSelected.state}, ${clubSelected.postcode}',
          );
          launchUrl(Uri.parse(googleMapsUrl));
        },
        child: PrettyText(
          '${clubSelected.streetAddress}, ${clubSelected.suburb}, ${clubSelected.city}, ${clubSelected.state}, ${clubSelected.postcode}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.blue),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
