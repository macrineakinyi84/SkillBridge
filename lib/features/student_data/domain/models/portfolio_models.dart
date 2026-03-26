import 'package:equatable/equatable.dart';

class StudentProfileBasics extends Equatable {
  const StudentProfileBasics({
    required this.displayName,
    required this.headline,
    required this.county,
    required this.updatedAtMs,
  });

  final String displayName;
  final String headline;
  final String county;
  final int updatedAtMs;

  @override
  List<Object?> get props => [displayName, headline, county, updatedAtMs];
}

class PortfolioExperience extends Equatable {
  const PortfolioExperience({
    required this.id,
    required this.role,
    required this.company,
    required this.period,
    required this.summary,
    required this.updatedAtMs,
  });

  final String id;
  final String role;
  final String company;
  final String period;
  final String summary;
  final int updatedAtMs;

  @override
  List<Object?> get props => [id, role, company, period, summary, updatedAtMs];
}

class PortfolioEducation extends Equatable {
  const PortfolioEducation({
    required this.id,
    required this.degree,
    required this.institution,
    required this.period,
    required this.summary,
    required this.updatedAtMs,
  });

  final String id;
  final String degree;
  final String institution;
  final String period;
  final String summary;
  final int updatedAtMs;

  @override
  List<Object?> get props => [id, degree, institution, period, summary, updatedAtMs];
}

class PortfolioProject extends Equatable {
  const PortfolioProject({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.screenshotPath,
    required this.updatedAtMs,
  });

  final String id;
  final String title;
  final String description;
  final String? url;
  final String? screenshotPath;
  final int updatedAtMs;

  @override
  List<Object?> get props => [id, title, description, url, screenshotPath, updatedAtMs];
}

class PortfolioCertification extends Equatable {
  const PortfolioCertification({
    required this.id,
    required this.name,
    required this.issuer,
    required this.date,
    required this.updatedAtMs,
  });

  final String id;
  final String name;
  final String? issuer;
  final String? date;
  final int updatedAtMs;

  @override
  List<Object?> get props => [id, name, issuer, date, updatedAtMs];
}

