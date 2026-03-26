import 'package:hive/hive.dart';

import '../../features/student_data/data/hive/portfolio_records.dart';
import '../../features/student_data/data/hive/student_skill_record.dart';

class HiveAdapters {
  HiveAdapters._();

  static bool _registered = false;

  static void registerAll() {
    if (_registered) return;
    Hive
      ..registerAdapter(StudentSkillRecordAdapter())
      ..registerAdapter(StudentProfileBasicsRecordAdapter())
      ..registerAdapter(PortfolioExperienceRecordAdapter())
      ..registerAdapter(PortfolioEducationRecordAdapter())
      ..registerAdapter(PortfolioProjectRecordAdapter())
      ..registerAdapter(PortfolioCertificationRecordAdapter());
    _registered = true;
  }
}

