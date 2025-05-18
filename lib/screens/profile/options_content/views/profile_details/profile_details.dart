import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../cloud_functions/dto/update_profile.dart';
import '../../../../../cloud_functions/index.dart';
import '../../../../../cloud_functions/types.dart';
import '../../../../../global_helpers/index.dart';
import '../../../../../global_types/index.dart';
import '../../../../../global_widgets/index.dart';
import '../../../../../models/index.dart';
import '../../../../../state/index.dart';
import '../../../../../theme/index.dart';
import 'helper.dart';
import 'widgets/index.dart';

enum ProfileDetailsMode { view, edit }

class ProfileDetails extends StatefulHookConsumerWidget {
  const ProfileDetails({
    super.key,
  });

  @override
  ConsumerState<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends ConsumerState<ProfileDetails> {
  final _formKey = GlobalKey<FormState>();
  ProfileDetailsMode _mode = ProfileDetailsMode.view;
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _utrController;
  late String _selectedGender;
  late String _initialName;
  late String _initialDob;
  late String _initialSelectedGender;
  int _selectedDob = 0;

  void Function()? submitFunction;
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
    _utrController = TextEditingController(text: user.utrRating?.toString() ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() {
          submitFunction = _saveAndSubmit;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _utrController.dispose();
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
    if (_mode == ProfileDetailsMode.edit && _formKey.currentState!.validate()) {
      final eventNotifier = ref.read(eventProvider.notifier);
      final cloudFunctions = ref.read(cloudFunctionsProvider.notifier);
      final user = ref.read(userProvider);
      final userNotifier = ref.read(userProvider.notifier);
      final gender = Gender.values.firstWhere(
        (g) => g.name == _selectedGender,
        orElse: () => Gender.unknown,
      );

      eventNotifier.showLoading(message: 'Updating profile...');

      String? newUrl = await uploadImage(userNotifier: userNotifier, imageBytes: imageBytes);
      if (newUrl == null && user.photoUrl.isNotEmpty) {
        newUrl = user.photoUrl;
      }

      final updatedUser = user.copyWith(name: _nameController.text, dob: _selectedDob, gender: gender, photoUrl: newUrl);
      final UpdateProfilePayload payload = UpdateProfilePayload(
        name: updatedUser.name,
        dob: updatedUser.dob,
        gender: updatedUser.gender.name,
        photoUrl: newUrl ?? '', // * photoUrl prop should not be null
        utrRating: double.tryParse(_utrController.text),
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
        _mode = ProfileDetailsMode.view;
      });
    } else {
      setState(() {
        _mode = ProfileDetailsMode.edit;
      });
    }
  }

  void _toggleMode() => setState(() {
        _mode = ProfileDetailsMode.edit;
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

    final onGenderChangeClick = _mode == ProfileDetailsMode.edit ? _onGenderChange : null;

    final mobileView = isMobile(context);
    final fontSize = getFontSize(mobileView);

    return Form(
      key: _formKey,
      onChanged: () {
        _formKey.currentState!.save();
        if (_formKey.currentState!.validate()) {
          submitFunction = _saveAndSubmit;
        } else {
          submitFunction = null;
        }
        setState(() {});
      },
      autovalidateMode: AutovalidateMode.always,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 35,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  TbImageField(photoUrl: playerData.photoUrl, imageBytes: imageBytes, selectImage: () async {}),
                  if (_mode == ProfileDetailsMode.edit)
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
              FieldWithPencil(
                mode: _mode,
                onTap: _toggleMode,
                child: TextFormField(
                  style: TextStyle(fontSize: fontSize),
                  textAlign: TextAlign.center,
                  controller: _nameController,
                  enabled: _mode == ProfileDetailsMode.edit,
                  decoration: InputDecoration(labelText: 'Name', floatingLabelAlignment: FloatingLabelAlignment.center),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ),
              FieldWithPencil(
                mode: _mode,
                onTap: _toggleMode,
                child: DropdownButtonFormField<String>(
                  borderRadius: BorderRadius.circular(5.0),
                  alignment: Alignment.center,
                  decoration: InputDecoration(labelText: 'Gender', floatingLabelAlignment: FloatingLabelAlignment.center),
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
                            enabled: _mode == ProfileDetailsMode.edit,
                            value: gender,
                            child: PrettyText(
                              gender,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _mode == ProfileDetailsMode.edit ? AppColors.black : AppColors.disabled,
                                fontSize: fontSize,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: onGenderChangeClick,
                ),
              ),
              FieldWithPencil(
                mode: _mode,
                onTap: _toggleMode,
                child: TextFormField(
                    style: TextStyle(fontSize: fontSize),
                    textAlign: TextAlign.center,
                    controller: _utrController,
                    enabled: _mode == ProfileDetailsMode.edit,
                    decoration: InputDecoration(
                      labelText: 'UTR Rating',
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      alignLabelWithHint: true,
                    ),
                    validator: (value) => utrValueValidator(value, context)),
              ),
              FieldWithPencil(
                mode: _mode,
                onTap: () => _toggleMode(),
                child: TextFormField(
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: fontSize),
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    floatingLabelAlignment: FloatingLabelAlignment.center,
                    hoverColor: Colors.white,
                  ),
                  controller: _dobController,
                  enabled: _mode == ProfileDetailsMode.edit,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.email, color: AppColors.black),
                  const SizedBox(width: 10),
                  PrettyText(user.email),
                ],
              ),
              if (_mode == ProfileDetailsMode.edit)
                ActionButtons(
                  onCancel: () {
                    setState(() {
                      _mode = ProfileDetailsMode.view;
                      _formKey.currentState!.reset();
                      _nameController.text = _initialName;
                      _dobController.text = _initialDob;
                      _selectedGender = _initialSelectedGender;
                      _utrController.text = user.utrRating?.toString() ?? '';
                      imageBytes = Uint8List(0);
                    });
                  },
                  onSave: submitFunction,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
