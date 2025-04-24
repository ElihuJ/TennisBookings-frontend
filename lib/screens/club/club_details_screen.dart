import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_widgets/header/header.dart';
import 'package:tennisbookings/state/clubs/clubs_provider.dart';
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
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16,
            children: [
              // Club Logo
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(clubSelected.clubLogoUrl),
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(height: 16),

              // Club Name
              Text(
                clubSelected.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Improved contrast for better visibility
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Club Address
              GestureDetector(
                onTap: () {
                  final googleMapsUrl = Uri.encodeFull(
                    'https://www.google.com/maps/search/?api=1&query=${clubSelected.streetAddress}, ${clubSelected.suburb}, ${clubSelected.city}, ${clubSelected.state}, ${clubSelected.postcode}',
                  );
                  launchUrl(Uri.parse(googleMapsUrl));
                },
                child: Text(
                  '${clubSelected.streetAddress}, ${clubSelected.suburb}, ${clubSelected.city}, ${clubSelected.state}, ${clubSelected.postcode}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16, // Increased font size
                        color: Colors.blue, // Make it look like a link
                        decoration: TextDecoration.underline, // Underline for link style
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Club Details
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: 350, // Set a fixed width for the card to make it narrower
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Club Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18, // Increased font size
                            ),
                      ),
                      const Divider(),
                      Text('Hard Courts: ${clubSelected.hardCourts}'),
                      Text('Clay Courts: ${clubSelected.clayCourts}'),
                      Text('Grass Courts: ${clubSelected.grassCourts}'),
                      Text('Other Surface Courts: ${clubSelected.otherSurfaceCourts}'),
                      Text('Annual Fee: \$${clubSelected.annualFee.toStringAsFixed(2)}'),
                      if (clubSelected.casualFee != null) Text('Casual Fee: \$${clubSelected.casualFee!.toStringAsFixed(2)}'),
                      Text('Only Members: ${clubSelected.onlyMembers ? "Yes" : "No"}'),
                      Text('Public Bookings Allowed: ${clubSelected.allowPublicBookings ? "Yes" : "No"}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Members Count
              Card(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Membership',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20, // Slightly larger font size for emphasis
                              color: Colors.white, // White text for contrast against gradient
                            ),
                      ),
                      const Divider(color: Colors.white), // White divider for contrast
                      Text(
                        'Total Members: ${clubSelected.memberIds.length}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 18, // Larger font size for readability
                              color: Colors.white, // White text for contrast
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
