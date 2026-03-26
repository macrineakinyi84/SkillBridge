import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/student_data/data/hive/portfolio_records.dart';
import '../../features/student_data/data/hive/student_skill_record.dart';
import 'hive_adapters.dart';
import 'hive_boxes.dart';

class HiveInit {
  HiveInit._();

  static bool _ready = false;
  static bool get isReady => _ready;

  static Future<void> ensureInitialized() async {
    if (_ready) return;
    await Hive.initFlutter();
    HiveAdapters.registerAll();

    // Meta box is always opened early to store app flags.
    await Hive.openBox(HiveBoxes.meta);

    // Open frequently used boxes upfront (small, fast).
    await Future.wait([
      Hive.openBox<StudentSkillRecord>(HiveBoxes.studentSkills),
      Hive.openBox<PortfolioExperienceRecord>(HiveBoxes.studentPortfolioExperience),
      Hive.openBox<PortfolioEducationRecord>(HiveBoxes.studentPortfolioEducation),
      Hive.openBox<PortfolioProjectRecord>(HiveBoxes.studentPortfolioProjects),
      Hive.openBox<PortfolioCertificationRecord>(HiveBoxes.studentPortfolioCertifications),
      Hive.openBox<StudentProfileBasicsRecord>(HiveBoxes.studentProfile),
    ]);

    // Cache boxes can be opened lazily later, but opening is cheap and avoids first-hit jank.
    await Future.wait([
      Hive.openBox(HiveBoxes.cacheEmployerDashboard),
      Hive.openBox(HiveBoxes.cacheTalentPool),
      Hive.openBox(HiveBoxes.cacheCandidateProfiles),
    ]);

    _ready = true;
    if (kDebugMode) {
      // ignore: avoid_print
      print('Hive initialized');
    }
  }
}

