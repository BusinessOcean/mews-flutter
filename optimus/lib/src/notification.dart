import 'dart:math';
import 'package:flutter/material.dart';
import 'package:optimus/optimus.dart';
import 'package:optimus/src/border_radius.dart';
import 'package:optimus/src/elevation.dart';
import 'package:optimus/src/typography/presets.dart';

/// Describes a certain type of notification with its semantical meaning.
/// Use-cases:
///  - [OptimusNotificationVariant.info] -  Used for notifying about
/// informational, supportive, educative matter.
///  - [OptimusNotificationVariant.success] - Used for notifying about
/// successful, confirming, positive matter.
///  - [OptimusNotificationVariant.warning] -  Used for notifying about
/// warnings, problems, or matters that require the user's attention.
///  - [OptimusNotificationVariant.danger] - Used for notifying about the
/// dangerous matter. Could be error, destructive action or negative feedback.
enum OptimusNotificationVariant {
  info,
  success,
  warning,
  danger,
}

///Notification is used for showing a brief and concise message that
///communicates immediate feedback with optional action included. Notifications
///are noticeable but not intrusive to the use and can be temporary.
class OptimusNotification extends StatelessWidget {
  const OptimusNotification({
    Key? key,
    required this.title,
    this.body,
    this.icon,
    this.link,
    this.onLinkPressed,
    this.isDismissible = false,
    this.onDismissed,
    this.variant = OptimusNotificationVariant.info,
  }) : super(key: key);

  final String title;
  final String? body;
  final IconData? icon;
  final String? link;
  final VoidCallback? onLinkPressed;
  final bool isDismissible;
  final VoidCallback? onDismissed;
  final OptimusNotificationVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = OptimusTheme.of(context);
    final screenBreakpoint = MediaQuery.of(context).screenBreakpoint;
    final padding = screenBreakpoint.getPadding();
    final double notificationWidth = min(
      MediaQuery.of(context).size.width - padding * 2,
      _maxWidth,
    );

    return Positioned(
      top: padding,
      right: padding,
      child: Container(
        constraints: BoxConstraints(maxWidth: notificationWidth),
        decoration: BoxDecoration(
          color: variant.getBannerColor(theme),
          borderRadius: const BorderRadius.all(borderRadius50),
          boxShadow: elevation50,
        ),
        child: Stack(
          children: [
            _NotificationContent(
              icon: icon,
              variant: variant,
              title: title,
              body: body,
              link: link,
              onLinkPressed: onLinkPressed,
            ),
            if (isDismissible)
              _NotificationCloseButton(onDismissed: onDismissed)
          ],
        ),
      ),
    );
  }
}

class _NotificationContent extends StatelessWidget {
  const _NotificationContent({
    Key? key,
    required this.icon,
    required this.variant,
    required this.title,
    required this.body,
    required this.link,
    required this.onLinkPressed,
  }) : super(key: key);

  final IconData? icon;
  final OptimusNotificationVariant variant;
  final String title;
  final String? body;
  final String? link;
  final VoidCallback? onLinkPressed;

  @override
  Widget build(BuildContext context) {
    final theme = OptimusTheme.of(context);
    final body = this.body;
    final link = this.link;

    return Row(
      children: [
        _LeadingIcon(icon: icon, variant: variant),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(spacing200),
            decoration: BoxDecoration(
              color: theme.colors.neutral0,
              borderRadius: const BorderRadius.horizontal(
                right: borderRadius50,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _NotificationTitle(title: title),
                if (body != null)
                  _NotificationBody(
                    body: body,
                  ),
                if (link != null)
                  _NotificationLink(
                    onLinkPressed: onLinkPressed,
                    link: link,
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({
    Key? key,
    required this.icon,
    required this.variant,
  }) : super(key: key);

  final IconData? icon;
  final OptimusNotificationVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = OptimusTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _iconHorizontalPadding,
      ),
      child: Icon(
        icon ?? variant.getBannerIcon(),
        color: variant.getBannerIconColor(theme),
        size: _iconSize,
      ),
    );
  }
}

class _NotificationTitle extends StatelessWidget {
  const _NotificationTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = OptimusTheme.of(context);

    return Text(
      title,
      maxLines: _maxLinesTitle,
      overflow: TextOverflow.ellipsis,
      style: preset300b.copyWith(
        color: theme.colors.neutral1000,
      ),
    );
  }
}

class _NotificationBody extends StatelessWidget {
  const _NotificationBody({
    Key? key,
    required this.body,
  }) : super(key: key);

  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = OptimusTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        top: spacing50,
      ),
      child: Text(
        body,
        maxLines: _maxLinesBody,
        overflow: TextOverflow.ellipsis,
        style: preset200r.copyWith(
          color: theme.colors.neutral1000t64,
        ),
      ),
    );
  }
}

class _NotificationLink extends StatelessWidget {
  const _NotificationLink({
    Key? key,
    required this.onLinkPressed,
    required this.link,
  }) : super(key: key);

  final VoidCallback? onLinkPressed;
  final String link;

  @override
  Widget build(BuildContext context) {
    final theme = OptimusTheme.of(context);

    return GestureDetector(
      onTap: () => onLinkPressed?.call(),
      child: Padding(
        padding: const EdgeInsets.only(
          top: spacing50,
        ),
        child: Text(
          link,
          maxLines: _maxLinesLink,
          overflow: TextOverflow.ellipsis,
          style: preset200b.copyWith(
            color: theme.colors.neutral1000,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

class _NotificationCloseButton extends StatelessWidget {
  const _NotificationCloseButton({
    Key? key,
    required this.onDismissed,
  }) : super(key: key);

  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    final theme = OptimusTheme.of(context);

    return Positioned(
      top: spacing100,
      right: spacing100,
      child: GestureDetector(
        onTap: () => onDismissed?.call(),
        child: Padding(
          padding: const EdgeInsets.all(spacing100),
          child: Icon(
            OptimusIcons.cross_close,
            color: theme.colors.neutral500,
            size: _closeIconSize,
          ),
        ),
      ),
    );
  }
}

extension on Breakpoint {
  double getPadding() {
    switch (this) {
      case Breakpoint.medium:
      case Breakpoint.large:
      case Breakpoint.extraLarge:
        return spacing200;
      case Breakpoint.small:
      case Breakpoint.extraSmall:
        return spacing100;
    }
  }
}

extension on OptimusNotificationVariant {
  Color getBannerColor(OptimusThemeData theme) {
    switch (this) {
      case OptimusNotificationVariant.info:
        return theme.colors.info500;
      case OptimusNotificationVariant.success:
        return theme.colors.success500;
      case OptimusNotificationVariant.warning:
        return theme.colors.warning500;
      case OptimusNotificationVariant.danger:
        return theme.colors.danger500;
    }
  }

  IconData getBannerIcon() {
    switch (this) {
      case OptimusNotificationVariant.info:
        return OptimusIcons.info;
      case OptimusNotificationVariant.success:
        return OptimusIcons.done_circle;
      case OptimusNotificationVariant.warning:
        return OptimusIcons.problematic;
      case OptimusNotificationVariant.danger:
        return OptimusIcons.blacklist;
    }
  }

  Color getBannerIconColor(OptimusThemeData theme) {
    switch (this) {
      case OptimusNotificationVariant.info:
      case OptimusNotificationVariant.success:
      case OptimusNotificationVariant.danger:
        return theme.colors.neutral0;
      case OptimusNotificationVariant.warning:
        return theme.colors.neutral1000;
    }
  }
}

const double _maxWidth = 360;
const double _closeIconSize = 16;
const double _iconSize = 20;
const double _iconHorizontalPadding = 10;
const int _maxLinesTitle = 1;
const int _maxLinesBody = 5;
const int _maxLinesLink = 1;
