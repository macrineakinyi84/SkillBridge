import 'package:hive/hive.dart';

part 'portfolio_records.g.dart';

@HiveType(typeId: 42)
class StudentProfileBasicsRecord extends HiveObject {
  StudentProfileBasicsRecord({
    required this.displayName,
    required this.headline,
    required this.county,
    required this.updatedAtMs,
  });

  @HiveField(0)
  final String displayName;

  @HiveField(1)
  final String headline;

  @HiveField(2)
  final String county;

  @HiveField(3)
  final int updatedAtMs;
}

@HiveType(typeId: 43)
class PortfolioExperienceRecord extends HiveObject {
  PortfolioExperienceRecord({
    required this.id,
    required this.role,
    required this.company,
    required this.period,
    required this.summary,
    required this.updatedAtMs,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String role;

  @HiveField(2)
  final String company;

  @HiveField(3)
  final String period;

  @HiveField(4)
  final String summary;

  @HiveField(5)
  final int updatedAtMs;
}

@HiveType(typeId: 44)
class PortfolioEducationRecord extends HiveObject {
  PortfolioEducationRecord({
    required this.id,
    required this.degree,
    required this.institution,
    required this.period,
    required this.summary,
    required this.updatedAtMs,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String degree;

  @HiveField(2)
  final String institution;

  @HiveField(3)
  final String period;

  @HiveField(4)
  final String summary;

  @HiveField(5)
  final int updatedAtMs;
}

@HiveType(typeId: 45)
class PortfolioProjectRecord extends HiveObject {
  PortfolioProjectRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.screenshotPath,
    required this.updatedAtMs,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String? url;

  @HiveField(4)
  final String? screenshotPath;

  @HiveField(5)
  final int updatedAtMs;
}

@HiveType(typeId: 46)
class PortfolioCertificationRecord extends HiveObject {
  PortfolioCertificationRecord({
    required this.id,
    required this.name,
    required this.issuer,
    required this.date,
    required this.updatedAtMs,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? issuer;

  @HiveField(3)
  final String? date;

  @HiveField(4)
  final int updatedAtMs;
}

