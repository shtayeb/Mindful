import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/core/enums/item_position.dart';
import 'package:mindful/core/extensions/ext_build_context.dart';
import 'package:mindful/core/extensions/ext_num.dart';
import 'package:mindful/core/utils/default_models_utils.dart';
import 'package:mindful/core/utils/widget_utils.dart';
import 'package:mindful/models/app_info.dart';
import 'package:mindful/providers/restrictions/apps_restrictions_provider.dart';
import 'package:mindful/ui/common/default_expandable_list_tile.dart';
import 'package:mindful/ui/common/rounded_container.dart';
import 'package:mindful/ui/common/styled_text.dart';

const _defaultPausePointSec = 10;
const _maxPausePointSec = 60;
const _maxCooldownMin = 240;

class PausePointTile extends ConsumerWidget {
  const PausePointTile({super.key, required this.appInfo});

  final AppInfo appInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restriction = ref.watch(
          appsRestrictionsProvider.select((v) => v[appInfo.packageName]),
        ) ??
        defaultAppRestrictionModel;

    final pauseSec = restriction.pausePointSec;
    final cooldownMin = restriction.pausePointCooldownMin;
    final isOn = pauseSec > 0;

    return DefaultExpandableListTile(
      enabled: !appInfo.isImpSysApp,
      position: ItemPosition.mid,
      leadingIcon: FluentIcons.pause_circle_20_regular,
      titleText: context.locale.pause_point_tile_title,
      subtitleText: isOn
          ? context.locale
              .pause_point_tile_subtitle_on(pauseSec, cooldownMin)
          : context.locale.pause_point_tile_subtitle_off,
      content: _PausePointContent(
        appPackage: appInfo.packageName,
        pauseSec: pauseSec,
        cooldownMin: cooldownMin,
      ),
    );
  }
}

class _PausePointContent extends ConsumerWidget {
  const _PausePointContent({
    required this.appPackage,
    required this.pauseSec,
    required this.cooldownMin,
  });

  final String appPackage;
  final int pauseSec;
  final int cooldownMin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(appsRestrictionsProvider.notifier);

    return RoundedContainer(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.all(16),
      borderRadius: getBorderRadiusFromPosition(ItemPosition.mid),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StyledText(
            context.locale.pause_point_info,
            color: Theme.of(context).hintColor,
          ),
          16.vBox,

          /// Pause length
          Row(
            children: [
              Expanded(
                child: StyledText(context.locale.pause_point_duration_label),
              ),
              StyledText(
                pauseSec > 0 ? "${pauseSec}s" : context.locale.app_limit_status_not_set,
              ),
            ],
          ),
          Slider(
            value: pauseSec.toDouble(),
            min: 0,
            max: _maxPausePointSec.toDouble(),
            divisions: _maxPausePointSec ~/ 5,
            label: pauseSec > 0 ? "${pauseSec}s" : "Off",
            onChanged: (v) {
              final snapped = (v / 5).round() * 5;
              if (snapped == pauseSec) return;
              // Snap "near zero" to the default-on value so a single tap
              // doesn't leave the user stuck at "Off" when toggling on.
              final next = snapped == 0 ? 0 : snapped;
              notifier.updatePausePoint(appPackage, next);
            },
          ),

          12.vBox,

          /// Cooldown
          Row(
            children: [
              Expanded(
                child: StyledText(context.locale.pause_point_cooldown_label),
              ),
              StyledText("${cooldownMin}m"),
            ],
          ),
          Slider(
            value: cooldownMin.toDouble().clamp(0, _maxCooldownMin.toDouble()),
            min: 0,
            max: _maxCooldownMin.toDouble(),
            divisions: _maxCooldownMin ~/ 5,
            label: "${cooldownMin}m",
            onChanged: pauseSec > 0
                ? (v) {
                    final snapped = (v / 5).round() * 5;
                    if (snapped == cooldownMin) return;
                    notifier.updatePausePointCooldown(appPackage, snapped);
                  }
                : null,
          ),

          12.vBox,

          /// Quick toggle: enable with default duration, or disable
          FittedBox(
            child: TextButton.icon(
              icon: Icon(
                pauseSec > 0
                    ? FluentIcons.dismiss_circle_20_filled
                    : FluentIcons.play_circle_20_filled,
              ),
              label: Text(
                pauseSec > 0
                    ? context.locale.pause_point_action_disable
                    : context.locale.pause_point_action_enable,
              ),
              onPressed: () {
                notifier.updatePausePoint(
                  appPackage,
                  pauseSec > 0 ? 0 : _defaultPausePointSec,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
