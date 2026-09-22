import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class KeypadWidget extends StatelessWidget {
  final ValueChanged<String> onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback? onClear;

  const KeypadWidget({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3']),
          const SizedBox(height: 12),
          _buildRow(['4', '5', '6']),
          const SizedBox(height: 12),
          _buildRow(['7', '8', '9']),
          const SizedBox(height: 12),
          _buildBottomRow(),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildKey(key)).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildKey('.'),
        _buildKey('0'),
        _buildBackspaceKey(),
      ],
    );
  }

  Widget _buildKey(String value) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onKeyPressed(value);
        },
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 72,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onBackspace();
        },
        onLongPress: onClear != null
            ? () {
                HapticFeedback.mediumImpact();
                onClear!();
              }
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 72,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: const Icon(
            Icons.backspace_outlined,
            color: AppColors.textPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
