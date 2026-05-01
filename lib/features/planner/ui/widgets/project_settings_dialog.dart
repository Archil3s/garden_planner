import 'package:flutter/material.dart';

import '../../../../core/models/garden_project.dart';
import '../../../../core/theme/garden_theme.dart';

class ProjectSettingsResult {
  const ProjectSettingsResult({
    required this.name,
    required this.widthMeters,
    required this.heightMeters,
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final double widthMeters;
  final double heightMeters;
  final String locationName;
  final double latitude;
  final double longitude;
}

class ProjectSettingsDialog extends StatefulWidget {
  const ProjectSettingsDialog({super.key, required this.project});

  final GardenProject project;

  @override
  State<ProjectSettingsDialog> createState() => _ProjectSettingsDialogState();
}

class _ProjectSettingsDialogState extends State<ProjectSettingsDialog> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController widthController;
  late final TextEditingController heightController;
  late final TextEditingController locationNameController;
  late final TextEditingController latitudeController;
  late final TextEditingController longitudeController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.project.name);
    widthController = TextEditingController(
      text: widget.project.widthMeters.toStringAsFixed(0),
    );
    heightController = TextEditingController(
      text: widget.project.heightMeters.toStringAsFixed(0),
    );
    locationNameController = TextEditingController(
      text: widget.project.locationName,
    );
    latitudeController = TextEditingController(
      text: widget.project.latitude.toStringAsFixed(4),
    );
    longitudeController = TextEditingController(
      text: widget.project.longitude.toStringAsFixed(4),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    widthController.dispose();
    heightController.dispose();
    locationNameController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: GardenTheme.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: GardenTheme.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project Settings',
                  style: TextStyle(
                    color: GardenTheme.ink,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Update the project name, canvas size, and weather location.',
                  style: TextStyle(
                    color: GardenTheme.muted,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                const _SectionTitle(label: 'Project'),
                const SizedBox(height: 8),
                _DialogTextField(
                  label: 'Project name',
                  controller: nameController,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DialogTextField(
                        label: 'Width',
                        controller: widthController,
                        suffix: 'm',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _dimensionValidator,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogTextField(
                        label: 'Height',
                        controller: heightController,
                        suffix: 'm',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _dimensionValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const _SectionTitle(label: 'Weather location'),
                const SizedBox(height: 8),
                _DialogTextField(
                  label: 'Location name',
                  controller: locationNameController,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DialogTextField(
                        label: 'Latitude',
                        controller: latitudeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: _latitudeValidator,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogTextField(
                        label: 'Longitude',
                        controller: longitudeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: _longitudeValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: GardenTheme.paper,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GardenTheme.border),
                  ),
                  child: const Text(
                    'Weather panels use latitude and longitude for frost and spray forecasts. Beds outside a resized canvas will be clamped inside the project bounds.',
                    style: TextStyle(
                      color: GardenTheme.muted,
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _DialogButton(
                      label: 'Cancel',
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 10),
                    _DialogButton(
                      label: 'Save Settings',
                      primary: true,
                      onTap: _submit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  String? _dimensionValidator(String? value) {
    final parsed = double.tryParse(value ?? '');

    if (parsed == null) {
      return 'Enter a number';
    }

    if (parsed < 5) {
      return 'Minimum 5m';
    }

    if (parsed > 100) {
      return 'Maximum 100m';
    }

    return null;
  }

  String? _latitudeValidator(String? value) {
    final parsed = double.tryParse(value ?? '');

    if (parsed == null) {
      return 'Enter a number';
    }

    if (parsed < -90 || parsed > 90) {
      return 'Use -90 to 90';
    }

    return null;
  }

  String? _longitudeValidator(String? value) {
    final parsed = double.tryParse(value ?? '');

    if (parsed == null) {
      return 'Enter a number';
    }

    if (parsed < -180 || parsed > 180) {
      return 'Use -180 to 180';
    }

    return null;
  }

  void _submit() {
    if (!formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      ProjectSettingsResult(
        name: nameController.text.trim(),
        widthMeters: double.parse(widthController.text.trim()),
        heightMeters: double.parse(heightController.text.trim()),
        locationName: locationNameController.text.trim(),
        latitude: double.parse(latitudeController.text.trim()),
        longitude: double.parse(longitudeController.text.trim()),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: GardenTheme.muted,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.9,
      ),
    );
  }
}

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({
    required this.label,
    required this.controller,
    this.validator,
    this.suffix,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? suffix;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: GardenTheme.ink,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label.toUpperCase(),
        suffixText: suffix,
        labelStyle: const TextStyle(
          color: GardenTheme.muted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
        suffixStyle: const TextStyle(
          color: GardenTheme.muted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: GardenTheme.paper,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GardenTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GardenTheme.ink, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GardenTheme.bad),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GardenTheme.bad, width: 1.4),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? GardenTheme.ink : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: primary ? GardenTheme.ink : GardenTheme.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: primary ? GardenTheme.cream : GardenTheme.ink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
