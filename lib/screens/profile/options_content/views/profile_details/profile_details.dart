import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../cloud_functions/dto/update_profile.dart';
import '../../../../../cloud_functions/index.dart';
import '../../../../../cloud_functions/types.dart';
import '../../../../../global_helpers/index.dart';
import '../../../../../global_types/index.dart';
import '../../../../../state/index.dart';
import '../../../../../strings/index.dart';
import '../../../../../theme/index.dart';
import 'helper.dart';
import 'widgets/index.dart';

enum ProfileDetailsMode { view, edit }

class ProfileDetails extends StatefulHookConsumerWidget {
  const ProfileDetails({super.key});

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
        setState(() => submitFunction = _saveAndSubmit);
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
    setState(() => _selectedGender = value);
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

      eventNotifier.showLoading(message: context.localeString(ProfileStrings.updating));

      String? newUrl = await uploadImage(userNotifier: userNotifier, imageBytes: imageBytes);
      if (newUrl == null && user.photoUrl.isNotEmpty) newUrl = user.photoUrl;

      final updatedUser = user.copyWith(name: _nameController.text, dob: _selectedDob, gender: gender, photoUrl: newUrl);
      final payload = UpdateProfilePayload(
        name: updatedUser.name,
        dob: updatedUser.dob,
        gender: updatedUser.gender.name,
        photoUrl: newUrl ?? '',
        utrRating: double.tryParse(_utrController.text),
      );

      final result = await cloudFunctions.updateProfile(payload);
      eventNotifier.hideLoading();
      if (result.responseStatus == CFResponseStatus.ok) {
        eventNotifier.showMessage(message: context.localeString(ProfileStrings.updated), messageType: MessageType.success);
        userNotifier.updateUser(user: updatedUser);
      } else {
        eventNotifier.showMessage(message: context.localeString(ProfileStrings.updateError), messageType: MessageType.error);
      }

      setState(() => _mode = ProfileDetailsMode.view);
    } else {
      setState(() => _mode = ProfileDetailsMode.edit);
    }
  }

  void _toggleMode() => setState(() => _mode = ProfileDetailsMode.edit);

  void _discardChanges() {
    final user = ref.read(userProvider);
    setState(() {
      _mode = ProfileDetailsMode.view;
      _formKey.currentState!.reset();
      _nameController.text = _initialName;
      _dobController.text = _initialDob;
      _selectedGender = _initialSelectedGender;
      _utrController.text = user.utrRating?.toString() ?? '';
      imageBytes = Uint8List(0);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 10, requestFullMetadata: false);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => imageBytes = bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isEditing = _mode == ProfileDetailsMode.edit;

    return Form(
      key: _formKey,
      onChanged: () {
        _formKey.currentState!.save();
        setState(() {
          submitFunction = _formKey.currentState!.validate() ? _saveAndSubmit : null;
        });
      },
      autovalidateMode: AutovalidateMode.always,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroCard(
                  user: user,
                  isEditing: isEditing,
                  imageBytes: imageBytes,
                  onPhotoTap: _pickImage,
                ),
                const SizedBox(height: 16),
                if (!isEditing)
                  _InfoCard(user: user, onEdit: _toggleMode)
                else
                  _FormCard(
                    nameController: _nameController,
                    dobController: _dobController,
                    utrController: _utrController,
                    selectedGender: _selectedGender,
                    onGenderChange: _onGenderChange,
                    onDateTap: () => _selectDate(context),
                  ),
                if (isEditing) ...[
                  const SizedBox(height: 20),
                  ActionButtons(onCancel: _discardChanges, onSave: submitFunction),
                ],
                if (!isEditing) ...[
                  const SizedBox(height: 16),
                  const _LanguageCard(),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hero card ────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.user,
    required this.isEditing,
    required this.imageBytes,
    required this.onPhotoTap,
  });

  final User user;
  final bool isEditing;
  final Uint8List imageBytes;
  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageBytes.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: isEditing ? onPhotoTap : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 3),
                  ),
                  child: ClipOval(
                    child: hasImage
                        ? Image.memory(imageBytes, fit: BoxFit.cover)
                        : (user.photoUrl.isNotEmpty
                            ? Image.network(user.photoUrl, fit: BoxFit.cover)
                            : Container(
                                color: AppColors.secondaryGreen.withValues(alpha: 0.3),
                                child: Icon(Icons.person, size: 60, color: Colors.white.withValues(alpha: 0.7)),
                              )),
                  ),
                ),
                if (isEditing)
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                    child: const Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 28),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (user.utrRating != null && user.utrRating! > 0)
                _HeroChip(
                  icon: Icons.sports_tennis,
                  label: 'UTR ${user.utrRating}',
                ),
              if (user.utrRating != null && user.utrRating! > 0 && user.gender != Gender.unknown)
                const SizedBox(width: 8),
              if (user.gender != Gender.unknown)
                _HeroChip(
                  icon: Icons.person_outline,
                  label: capitalizeFirstLetter(user.gender.name),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Info card (view mode) ────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.user, required this.onEdit});

  final User user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.email_outlined,
              label: context.localeString(ProfileStrings.emailLabel),
              value: user.email,
            ),
            const _Divider(),
            _InfoRow(
              icon: Icons.cake_outlined,
              label: context.localeString(ProfileStrings.dobLabel),
              value: prettyDateUtcFromEpoch(user.dob),
            ),
            const _Divider(),
            _InfoRow(
              icon: Icons.person_outline,
              label: context.localeString(ProfileStrings.genderLabel),
              value: capitalizeFirstLetter(user.gender.name),
            ),
            const _Divider(),
            _InfoRow(
              icon: Icons.sports_tennis_outlined,
              label: context.localeString(ProfileStrings.utrLabel),
              value: user.utrRating != null && user.utrRating! > 0 ? user.utrRating.toString() : '—',
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: Text(context.localeString(ProfileStrings.editProfile)),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primaryGreen),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(height: 1, indent: 52, endIndent: 16);
}

// ─── Form card (edit mode) ────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.nameController,
    required this.dobController,
    required this.utrController,
    required this.selectedGender,
    required this.onGenderChange,
    required this.onDateTap,
  });

  final TextEditingController nameController;
  final TextEditingController dobController;
  final TextEditingController utrController;
  final String selectedGender;
  final void Function(String?) onGenderChange;
  final VoidCallback onDateTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: context.localeString(ProfileStrings.nameLabel),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.isEmpty) ? context.localeString(ProfileStrings.nameRequired) : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedGender,
              decoration: InputDecoration(
                labelText: context.localeString(ProfileStrings.genderLabel),
                prefixIcon: const Icon(Icons.people_outline),
              ),
              items: ['male', 'female', 'unknown']
                  .map((g) => DropdownMenuItem(value: g, child: Text(capitalizeFirstLetter(g))))
                  .toList(),
              onChanged: onGenderChange,
              validator: (v) => (v == null || v == 'unknown') ? context.localeString(ProfileStrings.genderRequired) : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: utrController,
              decoration: InputDecoration(
                labelText: context.localeString(ProfileStrings.utrLabel),
                prefixIcon: const Icon(Icons.sports_tennis_outlined),
              ),
              validator: (v) => utrValueValidator(v, context),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: dobController,
              readOnly: true,
              onTap: onDateTap,
              decoration: InputDecoration(
                labelText: context.localeString(ProfileStrings.dobLabel),
                prefixIcon: const Icon(Icons.cake_outlined),
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              ),
              validator: (v) => (v == null || v.isEmpty) ? context.localeString(ProfileStrings.dobRequired) : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Language card ────────────────────────────────────────────────────────────

class _LanguageCard extends StatelessWidget {
  const _LanguageCard();

  static const _languages = [
    (SupportedLocales.en, '🇬🇧'),
    (SupportedLocales.es, '🇪🇸'),
    (SupportedLocales.pt, '🇧🇷'),
    (SupportedLocales.fr, '🇫🇷'),
    (SupportedLocales.de, '🇩🇪'),
    (SupportedLocales.it, '🇮🇹'),
  ];

  String _labelKey(String code) {
    switch (code) {
      case SupportedLocales.en: return SettingsLanguageDialogStrings.english;
      case SupportedLocales.es: return SettingsLanguageDialogStrings.spanish;
      case SupportedLocales.pt: return SettingsLanguageDialogStrings.portuguese;
      case SupportedLocales.fr: return SettingsLanguageDialogStrings.french;
      case SupportedLocales.de: return SettingsLanguageDialogStrings.german;
      case SupportedLocales.it: return SettingsLanguageDialogStrings.italian;
      default: return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCode = Localizations.localeOf(context).languageCode;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.language, size: 18, color: AppColors.primaryGreen),
                  const SizedBox(width: 10),
                  Text(
                    context.localeString(ProfileStrings.language),
                    style: const TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _languages.map(((String, String) entry) {
                  final (code, flag) = entry;
                  final isSelected = code == currentCode;
                  return GestureDetector(
                    onTap: () => Locales.change(context, code),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryGreen : AppColors.primaryGreen.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryGreen : AppColors.primaryGreen.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(flag, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            context.localeString(_labelKey(code)),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? Colors.white : AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
