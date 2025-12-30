// lib/widgets/default_avatar_selector.dart
// Widget for selecting default avatar images

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/app_localizations.dart';

class DefaultAvatarSelector extends StatefulWidget {
  final String? selectedAvatarPath;
  final Function(String) onAvatarSelected;
  final double avatarSize;

  const DefaultAvatarSelector({
    super.key,
    this.selectedAvatarPath,
    required this.onAvatarSelected,
    this.avatarSize = 80.0,
  });

  @override
  State<DefaultAvatarSelector> createState() => _DefaultAvatarSelectorState();
}

class _DefaultAvatarSelectorState extends State<DefaultAvatarSelector> {
  final List<String> _defaultAvatars = [
    'assets/avatars/default_avatar_1.svg',
    'assets/avatars/default_avatar_2.svg',
    'assets/avatars/default_avatar_3.svg',
    'assets/avatars/default_avatar_4.svg',
    'assets/avatars/default_avatar_5.svg',
    'assets/avatars/emoji_avatar_1.svg',
    'assets/avatars/emoji_avatar_2.svg',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.selectDefaultAvatar,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _defaultAvatars.length,
            itemBuilder: (context, index) {
              final avatarPath = _defaultAvatars[index];
              final isSelected = avatarPath == widget.selectedAvatarPath;

              return GestureDetector(
                onTap: () => widget.onAvatarSelected(avatarPath),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha:0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: ClipOval(
                    child: SvgPicture.asset(
                      avatarPath,
                      width: widget.avatarSize,
                      height: widget.avatarSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
