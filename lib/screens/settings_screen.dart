import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../fade_route.dart';
import '../widgets/app_button.dart';
import 'tutorial_screen.dart';

class SettingsScreen extends StatelessWidget {
  final AppTheme theme;

  const SettingsScreen({super.key, required this.theme});

  static const _colorPresets = <Color>[
    Color(0xFF3853A4),
    Color(0xFF8B1A1A),
    Color(0xFF1A5C2A),
    Color(0xFFD35400),
    Color(0xFFFFC107),
  ];

  // Background gets the original light blue as an extra first option
  static const _bgPresets = <Color>[Color(0xFFDCF0FB), ..._colorPresets];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'SETTINGS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListenableBuilder(
        listenable: theme,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const _SectionLabel('COLORS'),
            const SizedBox(height: 20),
            _ColorSection(
              label: 'Background',
              selected: theme.backgroundColor,
              presets: _bgPresets,
              onSelect: theme.setBackgroundColor,
            ),
            const SizedBox(height: 28),
            _ColorSection(
              label: 'Card Back',
              selected: theme.cardBackColor,
              presets: _colorPresets,
              onSelect: theme.setCardBackColor,
            ),
            const SizedBox(height: 44),
            AppButton(
              label: 'HOW TO PLAY',
              onTap: () => Navigator.push(
                context,
                fadeRoute((_) => const TutorialScreen(reviewOnly: true)),
              ),
              verticalPadding: 14,
              borderRadius: 12,
              fontSize: 13,
              letterSpacing: 1.5,
            ),
            const SizedBox(height: 14),
            AppButton(
              label: 'RESET TO DEFAULTS',
              onTap: theme.reset,
              backgroundColor: Colors.white,
              textColor: Colors.black54,
              borderColor: Colors.black26,
              borderWidth: 1.5,
              verticalPadding: 14,
              borderRadius: 12,
              fontSize: 13,
              letterSpacing: 1.5,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
        color: Colors.black38,
      ),
    );
  }
}

class _ColorSection extends StatelessWidget {
  final String label;
  final Color selected;
  final List<Color> presets;
  final void Function(Color) onSelect;

  const _ColorSection({
    required this.label,
    required this.selected,
    required this.presets,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: presets.map((color) {
            final isSelected = selected == color;
            return GestureDetector(
              onTap: () => onSelect(color),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.black12,
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 22)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
