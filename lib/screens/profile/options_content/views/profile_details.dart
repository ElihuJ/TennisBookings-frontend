import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/cloud_functions/dto/update_profile.dart';
import 'package:tennisbookings/cloud_functions/index.dart';
import 'package:tennisbookings/cloud_functions/types.dart';
import 'package:tennisbookings/global_types/index.dart';
import 'package:tennisbookings/global_widgets/containers/bordered_box.dart';
import 'package:tennisbookings/theme/index.dart';

import '../../../../global_helpers/index.dart';
import '../../../../global_widgets/index.dart';
import '../../../../models/index.dart';
import '../../../../state/index.dart';

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
  late String _selectedGender;
  late String _initialName;
  late String _initialDob;
  late String _initialSelectedGender;
  int _selectedDob = 0;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _nameController = TextEditingController(text: user.name);
    _selectedGender = user.gender.name.toLowerCase();
    _dobController = TextEditingController(text: prettyDateUtcFromEpoch(user.dob));
    _selectedDob = user.dob;
    _initialName = user.name;
    _initialDob = prettyDateUtcFromEpoch(user.dob);
    _initialSelectedGender = _selectedGender;
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
      initialDate: DateTime.fromMillisecondsSinceEpoch(dob, isUtc: true),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        final utcDate = DateTime.utc(picked.year, picked.month, picked.day);
        _dobController.text = prettyDateUtcFromEpoch(utcDate.millisecondsSinceEpoch);
        _selectedDob = utcDate.millisecondsSinceEpoch;
      });
    }
  }

  void _onGenderChange(String? value) {
    if (value == null) return;
    setState(() {
      _selectedGender = value;
    });
  }

  _saveAndSubmit() async {
    if (_mode == _Mode.edit && _formKey.currentState!.validate()) {
      final eventNotifier = ref.read(eventsProvider.notifier);
      final cloudFunctions = ref.read(cloudFunctionsProvider.notifier);
      final user = ref.read(userProvider);
      final userNotifier = ref.read(userProvider.notifier);
      final gender = Gender.values.firstWhere(
        (g) => g.name == _selectedGender,
        orElse: () => Gender.unknown,
      );

      eventNotifier.showLoading(message: 'Updating profile...');

      final updatedUser = user.copyWith(name: _nameController.text, dob: _selectedDob, gender: gender, photoUrl: user.photoUrl);
      final UpdateProfilePayload payload = UpdateProfilePayload(
        name: updatedUser.name,
        dob: updatedUser.dob,
        gender: updatedUser.gender.name,
        photoUrl: updatedUser.photoUrl,
      );

      final result = await cloudFunctions.updateProfile(payload);
      eventNotifier.hideLoading();
      if (result.responseStatus == CFResponseStatus.ok) {
        eventNotifier.showMessage(message: 'Your profile has been updated', messageType: MessageType.success);
        userNotifier.updateUser(user: updatedUser);
      } else {
        eventNotifier.showMessage(message: 'Error updating profile', messageType: MessageType.error);
      }

      setState(() {
        _mode = _Mode.view;
      });
    } else {
      setState(() {
        _mode = _Mode.edit;
      });
    }
  }

  _toggleMode() => setState(() {
        _mode = _Mode.edit;
      });

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final playerData = ConfirmedPlayerData.emptyWithPhoto(user.photoUrl);
    final spacer = const SizedBox(height: 50.0);

    final onGenderChangeClick = _mode == _Mode.edit ? _onGenderChange : null;

    return Form(
      key: _formKey,
      child: Expanded(
        child: BorderedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              spacer,
              PlayerIcon(
                player: playerData,
                size: 100,
              ),
              spacer,
              _FieldWithPencil(
                mode: _mode,
                onTap: _toggleMode,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    enabled: _mode == _Mode.edit,
                    decoration: InputDecoration(labelText: 'Name', floatingLabelAlignment: FloatingLabelAlignment.center),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              spacer,
              _FieldWithPencil(
                mode: _mode,
                onTap: _toggleMode,
                child: Container(
                  width: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  child: DropdownButtonFormField<String>(
                      borderRadius: BorderRadius.circular(5.0),
                      alignment: Alignment.center,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                        constraints: BoxConstraints.tightFor(width: 200, height: 50),
                      ),
                      value: _selectedGender,
                      padding: const EdgeInsets.all(16),
                      validator: (value) {
                        if (value == null || value == 'unknown') {
                          return 'Please select';
                        }
                        return null;
                      },
                      items: ['male', 'female', 'unknown']
                          .map((gender) => DropdownMenuItem(
                                alignment: Alignment.center,
                                value: gender,
                                child: PrettyText(
                                  gender,
                                  textAlign: TextAlign.center,
                                ),
                              ))
                          .toList(),
                      onChanged: onGenderChangeClick),
                ),
              ),
              spacer,
              _FieldWithPencil(
                mode: _mode,
                onTap: () => _toggleMode(),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  width: 200,
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      hoverColor: Colors.white,
                    ),
                    controller: _dobController,
                    enabled: _mode == _Mode.edit,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your date of birth';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              spacer,
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              spacer,
              if (_mode == _Mode.edit)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 160,
                      height: 80,
                      margin: const EdgeInsets.only(right: 20),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(AppColors.grey),
                        ),
                        onPressed: () => setState(() {
                          _mode = _Mode.view;
                          _formKey.currentState!.reset();
                          _nameController.text = _initialName;
                          _dobController.text = _initialDob;
                          _selectedGender = _initialSelectedGender;
                        }),
                        child: PrettyText('Discard'),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      height: 80,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(AppColors.primaryGreen),
                        ),
                        onPressed: _saveAndSubmit,
                        child: PrettyText(
                          'Save\nchanges',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
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

class _FieldWithPencil extends StatelessWidget {
  final Function() onTap;
  final Widget child;
  final _Mode mode;

  const _FieldWithPencil({
    required this.child,
    required this.onTap,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          mode != _Mode.edit
              ? IconButton(
                  color: AppColors.grey,
                  icon: const Icon(Icons.edit),
                  onPressed: onTap,
                )
              : const SizedBox(width: 40),
          child
        ],
      ),
    );
  }
}
