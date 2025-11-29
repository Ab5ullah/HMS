import 'package:flutter/material.dart';
import '../../utils/constants.dart';

enum ModernButtonSize { small, medium, large }
enum ModernButtonVariant { filled, outlined, text, elevated }

class ModernButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ModernButtonSize size;
  final ModernButtonVariant variant;
  final Color? color;
  final bool fullWidth;
  final bool loading;

  const ModernButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.size = ModernButtonSize.medium,
    this.variant = ModernButtonVariant.filled,
    this.color,
    this.fullWidth = false,
    this.loading = false,
  });

  double get _height {
    switch (size) {
      case ModernButtonSize.small:
        return AppSizes.buttonHeightSmall;
      case ModernButtonSize.medium:
        return AppSizes.buttonHeightMedium;
      case ModernButtonSize.large:
        return AppSizes.buttonHeightLarge;
    }
  }

  double get _fontSize {
    switch (size) {
      case ModernButtonSize.small:
        return 13;
      case ModernButtonSize.medium:
        return 14;
      case ModernButtonSize.large:
        return 16;
    }
  }

  EdgeInsetsGeometry get _padding {
    switch (size) {
      case ModernButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium);
      case ModernButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge);
      case ModernButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: AppSizes.paddingXLarge);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;
    final isDisabled = onPressed == null || loading;

    Widget buttonChild = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == ModernButtonVariant.filled ? Colors.white : buttonColor,
              ),
            ),
          )
        else if (icon != null)
          Icon(icon, size: _fontSize + 4),
        if ((loading || icon != null) && label.isNotEmpty)
          const SizedBox(width: AppSizes.paddingSmall),
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
      ],
    );

    switch (variant) {
      case ModernButtonVariant.filled:
        return SizedBox(
          height: _height,
          width: fullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.border,
              disabledForegroundColor: AppColors.textDisabled,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              padding: _padding,
            ),
            child: buttonChild,
          ),
        );

      case ModernButtonVariant.outlined:
        return SizedBox(
          height: _height,
          width: fullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: buttonColor,
              disabledForegroundColor: AppColors.textDisabled,
              side: BorderSide(
                color: isDisabled ? AppColors.border : buttonColor,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              padding: _padding,
            ),
            child: buttonChild,
          ),
        );

      case ModernButtonVariant.text:
        return SizedBox(
          height: _height,
          width: fullWidth ? double.infinity : null,
          child: TextButton(
            onPressed: isDisabled ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: buttonColor,
              disabledForegroundColor: AppColors.textDisabled,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              padding: _padding,
            ),
            child: buttonChild,
          ),
        );

      case ModernButtonVariant.elevated:
        return SizedBox(
          height: _height,
          width: fullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.border,
              disabledForegroundColor: AppColors.textDisabled,
              elevation: 4,
              shadowColor: buttonColor.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              padding: _padding,
            ),
            child: buttonChild,
          ),
        );
    }
  }
}

class ModernIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final String? tooltip;
  final bool outlined;

  const ModernIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size,
    this.tooltip,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;
    final iconSize = size ?? AppSizes.iconMedium;

    Widget button = outlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: buttonColor,
              side: BorderSide(color: buttonColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              padding: const EdgeInsets.all(AppSizes.paddingSmall),
              minimumSize: Size(iconSize + 16, iconSize + 16),
            ),
            child: Icon(icon, size: iconSize),
          )
        : IconButton(
            onPressed: onPressed,
            icon: Icon(icon),
            color: buttonColor,
            iconSize: iconSize,
            style: IconButton.styleFrom(
              backgroundColor: buttonColor.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
            ),
          );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

class ModernFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final bool extended;
  final String? label;

  const ModernFloatingActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.extended = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;

    if (extended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: bgColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Icon(icon),
    );
  }
}
