// lib/widgets/carbon_class_selection_widget.dart
// Carbon Class Selection Widget - For registration and profile setup

import 'package:flutter/material.dart';

class CarbonClassSelectionWidget extends StatefulWidget {
  final int? initialClassLevel;
  final String? initialClassSection;
  final ValueChanged<({int? classLevel, String? classSection})> onClassSelected;
  final bool isRequired;
  final String? helperText;

  const CarbonClassSelectionWidget({
    Key? key,
    this.initialClassLevel,
    this.initialClassSection,
    required this.onClassSelected,
    this.isRequired = true,
    this.helperText,
  }) : super(key: key);

  @override
  State<CarbonClassSelectionWidget> createState() =>
      _CarbonClassSelectionWidgetState();
}

class _CarbonClassSelectionWidgetState
    extends State<CarbonClassSelectionWidget> {
  late int? _selectedClassLevel;
  late String? _selectedClassSection;

  static const List<int> _classLevels = [9, 10, 11, 12];
  static const Map<int, List<String>> _sections = {
    9: ['A', 'B', 'C', 'D'],
    10: ['A', 'B', 'C', 'D', 'E', 'F'],
    11: ['A', 'B', 'C', 'D', 'E', 'F'],
    12: ['A', 'B', 'C', 'D', 'E', 'F'],
  };

  @override
  void initState() {
    super.initState();
    _selectedClassLevel = widget.initialClassLevel;
    _selectedClassSection = widget.initialClassSection;
  }

  @override
  Widget build(BuildContext context) {
    final availableSections = _selectedClassLevel != null
        ? _sections[_selectedClassLevel] ?? []
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Class Level Dropdown
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<int>(
            value: _selectedClassLevel,
            decoration: InputDecoration(
              labelText: 'Sınıf Seviyesi',
              hintText: 'Sınıf seçin',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.school),
              helperText: widget.helperText,
            ),
            items: _classLevels.map((level) {
              final levelName = {
                9: '9. Sınıf',
                10: '10. Sınıf',
                11: '11. Sınıf',
                12: '12. Sınıf',
              }[level];

              return DropdownMenuItem<int>(
                value: level,
                child: Text(levelName ?? level.toString()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedClassLevel = value;
                // Reset section when class level changes
                _selectedClassSection = null;
              });

              _notifyParent();
            },
            validator: widget.isRequired
                ? (value) => value == null ? 'Sınıf seviyesi seçiniz' : null
                : null,
          ),
        ),

        // Class Section Dropdown
        if (_selectedClassLevel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DropdownButtonFormField<String>(
              value: _selectedClassSection,
              decoration: InputDecoration(
                labelText: 'Şube',
                hintText: 'Şube seçin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.class_),
              ),
              items: availableSections.map((section) {
                return DropdownMenuItem<String>(
                  value: section,
                  child: Text(section),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClassSection = value;
                });

                _notifyParent();
              },
              validator: widget.isRequired && _selectedClassLevel != null
                  ? (value) => value == null ? 'Şube seçiniz' : null
                  : null,
            ),
          ),

        // Info Card
        if (_selectedClassLevel != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _buildInfoCard(),
          ),
      ],
    );
  }

  Widget _buildInfoCard() {
    final hasPlants = _selectedClassLevel != null && _selectedClassLevel! <= 10;

    return Card(
      elevation: 2,
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedClassLevel}. Sınıf Hakkında:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasPlants
                        ? 'Sınıfınıza bitkiler eklenebilir'
                        : '${_selectedClassLevel}. sınıflarda bitkiler yer almaz',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[600], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sınıf bilgisi karbon raporlarınızda kullanılacaktır',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _notifyParent() {
    widget.onClassSelected(
      (
        classLevel: _selectedClassLevel,
        classSection: _selectedClassSection,
      ),
    );
  }

  /// Get selected class identifier (e.g., "9A")
  String? getSelectedClassIdentifier() {
    if (_selectedClassLevel == null || _selectedClassSection == null) {
      return null;
    }
    return '${_selectedClassLevel}${_selectedClassSection}';
  }

  /// Check if selection is valid
  bool isSelectionValid() {
    return _selectedClassLevel != null && _selectedClassSection != null;
  }
}
