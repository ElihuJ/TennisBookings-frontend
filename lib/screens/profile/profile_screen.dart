import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_widgets/header/index.dart';
import 'package:tennisbookings/global_widgets/index.dart';
import 'package:tennisbookings/screens/home_screen.dart';

import '../../state/index.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  static const route = 'Profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isLoggedIn = user.uid.isNotEmpty;
    final fbNotifier = ref.read(firebaseAuthProvider.notifier);
    final clubNotifier = ref.read(clubsProvider.notifier);

    if (!isLoggedIn) {
      return const NotFoundScreen();
    }

    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          appBar: Header(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://example.com/profile.jpg'),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'johndoe@example.com',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    await fbNotifier.logout();
                    clubNotifier.clearPrivateBookings();
                    if (context.mounted) Navigator.of(context).pushNamed(HomeScreen.route);
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
