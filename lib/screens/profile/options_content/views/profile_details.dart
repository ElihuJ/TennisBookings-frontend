import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../cloud_functions/dto/update_profile.dart';
import '../../../../cloud_functions/index.dart';
import '../../../../cloud_functions/types.dart';
import '../../../../global_helpers/index.dart';
import '../../../../global_types/index.dart';
import '../../../../global_widgets/containers/bordered_box.dart';
import '../../../../global_widgets/index.dart';
import '../../../../models/index.dart';
import '../../../../state/index.dart';
import '../../../../theme/index.dart';

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
  Uint8List imageBytes = Uint8List(0);

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

  void _saveAndSubmit() async {
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

      final newUrl = await uploadImage(userNotifier: userNotifier, imageBytes: imageBytes);
      if (newUrl == null) {
        eventNotifier.hideLoading();
        eventNotifier.showMessage(message: 'Error uploading image', messageType: MessageType.error);
        return;
      }

      final updatedUser = user.copyWith(name: _nameController.text, dob: _selectedDob, gender: gender, photoUrl: newUrl);
      final UpdateProfilePayload payload = UpdateProfilePayload(
        name: updatedUser.name,
        dob: updatedUser.dob,
        gender: updatedUser.gender.name,
        photoUrl: newUrl,
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

  void _toggleMode() => setState(() {
        _mode = _Mode.edit;
      });

  void setImageBytes({required Uint8List? newImageBytes}) {
    if (newImageBytes == null) return;
    setState(() {
      imageBytes = newImageBytes;
    });
  }

  Future selectImage({required Uint8List imageBytes}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 10, requestFullMetadata: false);
    if (pickedFile != null) {
      imageBytes = await pickedFile.readAsBytes();
      return imageBytes;
    }
  }

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
              Stack(
                alignment: Alignment.center,
                children: [
                  TbImageField(photoUrl: playerData.photoUrl, imageBytes: imageBytes, selectImage: () async {}),
                  if (_mode == _Mode.edit)
                    GestureDetector(
                      onTap: () async {
                        Uint8List? newImageBytes = await selectImage(imageBytes: imageBytes);
                        setImageBytes(newImageBytes: newImageBytes);
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.only(top: 20),
                        child: Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 30),
                      ),
                    ),
                ],
              ),
              spacer,
              _FieldWithPencil(
                mode: _mode,
                onTap: _toggleMode,
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
              spacer,
              _FieldWithPencil(
                mode: _mode,
                onTap: _toggleMode,
                child: DropdownButtonFormField<String>(
                    borderRadius: BorderRadius.circular(5.0),
                    alignment: Alignment.center,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                    ),
                    value: _selectedGender,
                    validator: (value) {
                      if (value == null || value == 'unknown') {
                        return 'Please select';
                      }
                      return null;
                    },
                    items: ['male', 'female', 'unknown']
                        .map((gender) => DropdownMenuItem(
                              alignment: Alignment.bottomCenter,
                              value: gender,
                              child: PrettyText(
                                gender,
                                textAlign: TextAlign.center,
                              ),
                            ))
                        .toList(),
                    onChanged: onGenderChangeClick),
              ),
              spacer,
              _FieldWithPencil(
                mode: _mode,
                onTap: () => _toggleMode(),
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
              spacer,
              Text(user.email, style: TextStyle(fontSize: 16.0)),
              spacer,
              if (_mode == _Mode.edit)
                _ActionButtons(
                  onCancel: () {
                    setState(() {
                      _mode = _Mode.view;
                      _formKey.currentState!.reset();
                      _nameController.text = _initialName;
                      _dobController.text = _initialDob;
                      _selectedGender = _initialSelectedGender;
                      imageBytes = Uint8List(0);
                    });
                  },
                  onSave: _saveAndSubmit,
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
          Container(
            width: 200,
            height: 80,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Function() onCancel;
  final Function() onSave;

  const _ActionButtons({
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
            onPressed: onCancel,
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
            onPressed: onSave,
            child: PrettyText(
              'Save\nchanges',
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

Future<String?> uploadImage({required UserNotifier userNotifier, required Uint8List? imageBytes}) async {
  if (imageBytes != null && imageBytes.isNotEmpty) {
    final (newUrl, uploadErrorInfo) = await userNotifier.uploadProfilePhoto(imageBytes: imageBytes);
    if (uploadErrorInfo != null) {
      final messageType = uploadErrorInfo.$1;
      final message = uploadErrorInfo.$2;
      messageType.tbLogger('Message Type');
      message.tbLogger('Message');
      return newUrl;
    }
    return newUrl;
  }
  return null;
}
