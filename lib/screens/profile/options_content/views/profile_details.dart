import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../global_helpers/index.dart';
import '../../../../global_widgets/index.dart';
import '../../../../models/index.dart';
import '../../../../state/index.dart';
import '../../../home_screen.dart';

enum _Mode { view, edit }

class ProfileDetails extends StatefulHookConsumerWidget {
  const ProfileDetails({
    super.key,
  });

  @override
  ConsumerState<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends ConsumerState<ProfileDetails> {
  final _formKey = GlobalKey<FormState>();
  _Mode _mode = _Mode.view;
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  int _selectedDob = 0;
  String _selectedGender = 'male';

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _nameController = TextEditingController(text: user.name);
    _selectedGender = user.gender.name;
    _dobController = TextEditingController(text: prettyDateUtcFromEpoch(user.dob));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final dob = ref.read(userProvider).dob;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.fromMillisecondsSinceEpoch(dob),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = prettyDateUtcFromEpoch(picked.millisecondsSinceEpoch);
        _selectedDob = picked.millisecondsSinceEpoch;
      });
    }
  }

  // 1733538977102
  // 615427200000

  // 1735599600

  _saveAndSubmit() {
    if (_mode == _Mode.edit && _formKey.currentState!.validate()) {
      // Save changes to the user profile here
      setState(() {
        _mode = _Mode.view;
      });
    } else {
      setState(() {
        _mode = _Mode.edit;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final fbNotifier = ref.read(firebaseAuthProvider.notifier);
    final clubNotifier = ref.read(clubsProvider.notifier);
    final playerData = ConfirmedPlayerData.emptyWithPhoto(user.photoUrl);
    final spacer = const SizedBox(height: 26.0);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PlayerIcon(
                  player: playerData,
                  size: 100,
                ),
                spacer,
                _mode == _Mode.view
                    ? PrettyText(
                        user.name,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                spacer,
                _mode == _Mode.view
                    ? PrettyText(
                        user.gender.name,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        value: _selectedGender,
                        items: ['male', 'female']
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                        decoration: InputDecoration(labelText: 'Gender'),
                      ),
                spacer,
                _mode == _Mode.view
                    ? PrettyText(
                        prettyDateUtcFromEpoch(user.dob),
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : TextFormField(
                        controller: _dobController,
                        decoration: InputDecoration(labelText: 'Date of Birth'),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your date of birth';
                          }
                          return null;
                        },
                      ),
                spacer,
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
                spacer,
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    await fbNotifier.logout();
                    clubNotifier.clearPrivateBookings();
                    if (context.mounted) Navigator.of(context).pushNamed(HomeScreen.route);
                  },
                  child: const Text('Logout'),
                ),
                spacer,
                ElevatedButton(
                  onPressed: _saveAndSubmit,
                  child: Text(_mode == _Mode.view ? 'Edit' : 'Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
