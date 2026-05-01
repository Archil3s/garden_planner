import 'package:flutter/material.dart';

import '../../../../core/models/bed.dart';
import '../../../../core/theme/garden_theme.dart';

class AddBedDialogResult {
  const AddBedDialogResult({
    required this.name,
    required this.zone,
    required this.width,
    required this.height,
    required this.crops,
    required this.status,
  });

  final String name;
  final String zone;
  final double width;
  final double height;
  final List<String> crops;
  final BedStatus status;
}

class AddBedDialog extends StatefulWidget {
  const AddBedDialog({super.key, required this.nextNumber});

  final int nextNumber;

  @override
  State<AddBedDialog> createState() => _AddBedDialogState();
}

class _AddBedDialogState extends State<AddBedDialog> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController zoneController;
  late final TextEditingController widthController;
  late final TextEditingController heightController;
  late final TextEditingController cropsController;

  BedStatus status = BedStatus.ok;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: 'New Bed ${widget.nextNumber}',
    );
    zoneController = TextEditingController(text: 'Main Garden');
    widthController = TextEditingController(text: '4');
    heightController = TextEditingController(text: '2');
    cropsController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    zoneController.dispose();
    widthController.dispose();
    heightController.dispose();
    cropsController.dispose();

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
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Garden Bed',
                    style: TextStyle(
                      color: GardenTheme.ink,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Create a new bed on the meter-based planning canvas.',
                    style: TextStyle(
                      color: GardenTheme.muted,
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _DialogTextField(
                    label: 'Bed name',
                    controller: nameController,
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 12),
                  _DialogTextField(
                    label: 'Zone',
                    controller: zoneController,
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
                          validator: _positiveNumberValidator,
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
                          validator: _positiveNumberValidator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DialogTextField(
                    label: 'Crops',
                    controller: cropsController,
                    hint: 'Example: Tomatoes, Basil',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'STATUS',
                    style: TextStyle(
                      color: GardenTheme.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StatusPicker(
                    value: status,
                    onChanged: (value) {
                      setState(() {
                        status = value;
                      });
                    },
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
                        label: 'Create Bed',
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
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  String? _positiveNumberValidator(String? value) {
    final parsed = double.tryParse(value ?? '');

    if (parsed == null) {
      return 'Enter a number';
    }

    if (parsed <= 0) {
      return 'Must be greater than 0';
    }

    return null;
  }

  void _submit() {
    if (!formKey.currentState!.validate()) return;

    final crops = cropsController.text
        .split(',')
        .map((crop) => crop.trim())
        .where((crop) => crop.isNotEmpty)
        .toList();

    Navigator.of(context).pop(
      AddBedDialogResult(
        name: nameController.text.trim(),
        zone: zoneController.text.trim(),
        width: double.parse(widthController.text.trim()),
        height: double.parse(heightController.text.trim()),
        crops: crops,
        status: status,
      ),
    );
  }
}

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({
    required this.label,
    required this.controller,
    this.validator,
    this.hint,
    this.suffix,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? hint;
  final String? suffix;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: GardenTheme.ink,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label.toUpperCase(),
        hintText: hint,
        suffixText: suffix,
        labelStyle: const TextStyle(
          color: GardenTheme.muted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
        hintStyle: const TextStyle(color: GardenTheme.muted, fontSize: 13),
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

class _StatusPicker extends StatelessWidget {
  const _StatusPicker({required this.value, required this.onChanged});

  final BedStatus value;
  final ValueChanged<BedStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        _StatusOption(
          label: 'Healthy',
          status: BedStatus.ok,
          selected: value == BedStatus.ok,
          color: GardenTheme.good,
          background: const Color(0xFFEEF8F0),
          onChanged: onChanged,
        ),
        _StatusOption(
          label: 'Attention',
          status: BedStatus.warning,
          selected: value == BedStatus.warning,
          color: GardenTheme.warn,
          background: const Color(0xFFFFF4E7),
          onChanged: onChanged,
        ),
        _StatusOption(
          label: 'Issue',
          status: BedStatus.bad,
          selected: value == BedStatus.bad,
          color: GardenTheme.bad,
          background: const Color(0xFFFFF0EE),
          onChanged: onChanged,
        ),
        _StatusOption(
          label: 'Hold',
          status: BedStatus.hold,
          selected: value == BedStatus.hold,
          color: GardenTheme.hold,
          background: const Color(0xFFF0EDFF),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.label,
    required this.status,
    required this.selected,
    required this.color,
    required this.background,
    required this.onChanged,
  });

  final String label;
  final BedStatus status;
  final bool selected;
  final Color color;
  final Color background;
  final ValueChanged<BedStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? background : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () => onChanged(status),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.5)
                  : GardenTheme.border,
            ),
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: selected ? color : GardenTheme.muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
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
