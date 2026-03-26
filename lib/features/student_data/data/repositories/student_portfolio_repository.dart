import 'dart:math';

import 'package:hive/hive.dart';

import '../../../../core/storage/hive_boxes.dart';
import '../../domain/models/portfolio_models.dart';
import '../hive/portfolio_records.dart';

class StudentPortfolioRepository {
  StudentPortfolioRepository({
    Box<StudentProfileBasicsRecord>? profileBox,
    Box<PortfolioExperienceRecord>? experienceBox,
    Box<PortfolioEducationRecord>? educationBox,
    Box<PortfolioProjectRecord>? projectsBox,
    Box<PortfolioCertificationRecord>? certificationsBox,
  })  : _profileBox = profileBox ?? Hive.box<StudentProfileBasicsRecord>(HiveBoxes.studentProfile),
        _experienceBox = experienceBox ?? Hive.box<PortfolioExperienceRecord>(HiveBoxes.studentPortfolioExperience),
        _educationBox = educationBox ?? Hive.box<PortfolioEducationRecord>(HiveBoxes.studentPortfolioEducation),
        _projectsBox = projectsBox ?? Hive.box<PortfolioProjectRecord>(HiveBoxes.studentPortfolioProjects),
        _certsBox = certificationsBox ?? Hive.box<PortfolioCertificationRecord>(HiveBoxes.studentPortfolioCertifications);

  final Box<StudentProfileBasicsRecord> _profileBox;
  final Box<PortfolioExperienceRecord> _experienceBox;
  final Box<PortfolioEducationRecord> _educationBox;
  final Box<PortfolioProjectRecord> _projectsBox;
  final Box<PortfolioCertificationRecord> _certsBox;

  StudentProfileBasics? getProfile() {
    final r = _profileBox.get('profile');
    if (r == null) return null;
    return StudentProfileBasics(
      displayName: r.displayName,
      headline: r.headline,
      county: r.county,
      updatedAtMs: r.updatedAtMs,
    );
  }

  Future<void> setProfile(StudentProfileBasics basics) async {
    await _profileBox.put(
      'profile',
      StudentProfileBasicsRecord(
        displayName: basics.displayName,
        headline: basics.headline,
        county: basics.county,
        updatedAtMs: basics.updatedAtMs,
      ),
    );
  }

  List<PortfolioExperience> listExperience() => _sorted(_experienceBox.values.map((r) => PortfolioExperience(
        id: r.id,
        role: r.role,
        company: r.company,
        period: r.period,
        summary: r.summary,
        updatedAtMs: r.updatedAtMs,
      )));

  List<PortfolioEducation> listEducation() => _sorted(_educationBox.values.map((r) => PortfolioEducation(
        id: r.id,
        degree: r.degree,
        institution: r.institution,
        period: r.period,
        summary: r.summary,
        updatedAtMs: r.updatedAtMs,
      )));

  List<PortfolioProject> listProjects() => _sorted(_projectsBox.values.map((r) => PortfolioProject(
        id: r.id,
        title: r.title,
        description: r.description,
        url: r.url,
        screenshotPath: r.screenshotPath,
        updatedAtMs: r.updatedAtMs,
      )));

  List<PortfolioCertification> listCertifications() => _sorted(_certsBox.values.map((r) => PortfolioCertification(
        id: r.id,
        name: r.name,
        issuer: r.issuer,
        date: r.date,
        updatedAtMs: r.updatedAtMs,
      )));

  Future<PortfolioExperience> createExperience({
    required String role,
    required String company,
    required String period,
    required String summary,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final item = PortfolioExperience(
      id: _randomId(),
      role: role.trim(),
      company: company.trim(),
      period: period.trim(),
      summary: summary.trim(),
      updatedAtMs: now,
    );
    await upsertExperience(item);
    return item;
  }

  Future<void> upsertExperience(PortfolioExperience e) async {
    await _experienceBox.put(
      e.id,
      PortfolioExperienceRecord(
        id: e.id,
        role: e.role,
        company: e.company,
        period: e.period,
        summary: e.summary,
        updatedAtMs: e.updatedAtMs,
      ),
    );
  }

  Future<void> deleteExperience(String id) => _experienceBox.delete(id);

  Future<PortfolioEducation> createEducation({
    required String degree,
    required String institution,
    required String period,
    required String summary,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final item = PortfolioEducation(
      id: _randomId(),
      degree: degree.trim(),
      institution: institution.trim(),
      period: period.trim(),
      summary: summary.trim(),
      updatedAtMs: now,
    );
    await upsertEducation(item);
    return item;
  }

  Future<void> upsertEducation(PortfolioEducation e) async {
    await _educationBox.put(
      e.id,
      PortfolioEducationRecord(
        id: e.id,
        degree: e.degree,
        institution: e.institution,
        period: e.period,
        summary: e.summary,
        updatedAtMs: e.updatedAtMs,
      ),
    );
  }

  Future<void> deleteEducation(String id) => _educationBox.delete(id);

  Future<PortfolioProject> createProject({
    required String title,
    required String description,
    String? url,
    String? screenshotPath,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final item = PortfolioProject(
      id: _randomId(),
      title: title.trim(),
      description: description.trim(),
      url: url?.trim().isEmpty == true ? null : url?.trim(),
      screenshotPath: screenshotPath,
      updatedAtMs: now,
    );
    await upsertProject(item);
    return item;
  }

  Future<void> upsertProject(PortfolioProject p) async {
    await _projectsBox.put(
      p.id,
      PortfolioProjectRecord(
        id: p.id,
        title: p.title,
        description: p.description,
        url: p.url,
        screenshotPath: p.screenshotPath,
        updatedAtMs: p.updatedAtMs,
      ),
    );
  }

  Future<void> deleteProject(String id) => _projectsBox.delete(id);

  Future<PortfolioCertification> createCertification({
    required String name,
    String? issuer,
    String? date,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final item = PortfolioCertification(
      id: _randomId(),
      name: name.trim(),
      issuer: issuer?.trim().isEmpty == true ? null : issuer?.trim(),
      date: date?.trim().isEmpty == true ? null : date?.trim(),
      updatedAtMs: now,
    );
    await upsertCertification(item);
    return item;
  }

  Future<void> upsertCertification(PortfolioCertification c) async {
    await _certsBox.put(
      c.id,
      PortfolioCertificationRecord(
        id: c.id,
        name: c.name,
        issuer: c.issuer,
        date: c.date,
        updatedAtMs: c.updatedAtMs,
      ),
    );
  }

  Future<void> deleteCertification(String id) => _certsBox.delete(id);

  List<T> _sorted<T extends Object>(Iterable<T> items) {
    final list = items.toList();
    list.sort((a, b) {
      final ams = (a as dynamic).updatedAtMs as int? ?? 0;
      final bms = (b as dynamic).updatedAtMs as int? ?? 0;
      return bms.compareTo(ams);
    });
    return list;
  }

  String _randomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = Random();
    return List.generate(12, (_) => chars[r.nextInt(chars.length)]).join();
  }
}

