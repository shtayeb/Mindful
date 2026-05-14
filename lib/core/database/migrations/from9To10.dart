// ignore_for_file: file_names

import 'package:drift/drift.dart';
import 'package:mindful/core/database/schemas/schema_versions.dart';
import 'package:mindful/core/utils/db_utils.dart';

Future<void> from9To10(Migrator m, Schema10 schema) async => await runSafe(
      "Migration(9 to 10)",
      () async {
        /// Add Pause Point columns to [AppRestrictionTable]
        await m.addColumn(
          schema.appRestrictionTable,
          schema.appRestrictionTable.pausePointSec,
        );
        await m.addColumn(
          schema.appRestrictionTable,
          schema.appRestrictionTable.pausePointCooldownMin,
        );
      },
    );
