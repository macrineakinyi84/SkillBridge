import 'dart:math';

import 'package:hive/hive.dart';

import '../storage/hive_boxes.dart';
import '../../features/student_data/data/repositories/student_portfolio_repository.dart';
import '../../features/student_data/data/repositories/student_skills_repository.dart';
import '../../features/student_data/domain/models/portfolio_models.dart';
import '../seed/seed_data.dart';

class SeedService {
  SeedService({
    required StudentSkillsRepository skillsRepo,
    required StudentPortfolioRepository portfolioRepo,
    Box? metaBox,
  })  : _skillsRepo = skillsRepo,
        _portfolioRepo = portfolioRepo,
        _metaBox = metaBox ?? Hive.box(HiveBoxes.meta);

  final StudentSkillsRepository _skillsRepo;
  final StudentPortfolioRepository _portfolioRepo;
  final Box _metaBox;

  static const _seededKey = 'seeded.v1';

  Future<void> seedIfNeeded() async {
    final seeded = _metaBox.get(_seededKey) == true;
    if (seeded) return;

    await _seedStudentData();
    await _metaBox.put(_seededKey, true);
  }

  Future<void> resetSeed() async {
    await _metaBox.delete(_seededKey);
    // Do not wipe user-generated data automatically; reset just re-runs seeding if needed.
  }

  Future<void> _seedStudentData() async {
    // Skills (only if empty)
    if (_skillsRepo.list().isEmpty) {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _skillsRepo.create(name: 'Flutter', level: 'Advanced', progress: 86);
      await _skillsRepo.create(name: 'Dart', level: 'Intermediate', progress: 74);
      await _skillsRepo.create(name: 'Firebase', level: 'Intermediate', progress: 63);
      await _skillsRepo.create(name: 'REST APIs', level: 'Intermediate', progress: 58);
      await _skillsRepo.create(name: 'UI/UX', level: 'Beginner', progress: 44);
      // Touch meta time to keep ordering consistent.
      await _metaBox.put('seededAtMs', now);
    }

    // Portfolio (only if empty)
    final experienceEmpty = _portfolioRepo.listExperience().isEmpty;
    final educationEmpty = _portfolioRepo.listEducation().isEmpty;
    final projectsEmpty = _portfolioRepo.listProjects().isEmpty;
    final certsEmpty = _portfolioRepo.listCertifications().isEmpty;
    final profileEmpty = _portfolioRepo.getProfile() == null;

    if (profileEmpty) {
      final fullName = _pickName();
      await _portfolioRepo.setProfile(
        StudentProfileBasics(
          displayName: fullName,
          headline: 'Flutter developer • Product-minded',
          county: _pickCounty(),
          updatedAtMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }

    if (experienceEmpty) {
      await _portfolioRepo.createExperience(
        role: 'Flutter Intern',
        company: 'Mtaa Digital Studio',
        period: 'Jan 2026 – Mar 2026',
        summary: 'Built reusable UI components, fixed layout bugs, improved loading states, and shipped weekly updates.',
      );
      await _portfolioRepo.createExperience(
        role: 'Mobile Dev Freelancer',
        company: 'Kazi Connect',
        period: 'Sep 2025 – Dec 2025',
        summary: 'Delivered two Flutter apps with OTP auth, REST integration, and admin dashboards.',
      );
      await _portfolioRepo.createExperience(
        role: 'Tech Community Lead',
        company: 'Campus Dev Circle',
        period: '2024 – 2025',
        summary: 'Led weekly meetups on Git, Flutter basics, and teamwork; mentored 20+ peers.',
      );
      await _portfolioRepo.createExperience(
        role: 'Attachment Trainee',
        company: 'County ICT Office',
        period: 'May 2023 – Aug 2023',
        summary: 'Supported troubleshooting, user support, and documentation; assisted with basic networking tasks.',
      );
      await _portfolioRepo.createExperience(
        role: 'Peer Mentor',
        company: 'Women in Tech Program',
        period: '2024',
        summary: 'Guided juniors on debugging, clean architecture, and interview preparation.',
      );
    }

    if (educationEmpty) {
      await _portfolioRepo.createEducation(
        degree: 'BSc Computer Science',
        institution: 'Jomo Kenyatta University of Agriculture and Technology',
        period: '2022 – 2026',
        summary: 'Mobile development, databases, software engineering, and product design projects.',
      );
      await _portfolioRepo.createEducation(
        degree: 'UI/UX Design (Certificate)',
        institution: 'ALX Africa',
        period: '2025',
        summary: 'User research, prototyping, accessibility, and usability testing.',
      );
      await _portfolioRepo.createEducation(
        degree: 'Data Structures & Algorithms',
        institution: 'Self-study',
        period: '2025',
        summary: 'Big-O, arrays, trees, graphs, and problem solving practice.',
      );
      await _portfolioRepo.createEducation(
        degree: 'Cloud Fundamentals',
        institution: 'AWS Educate',
        period: '2024',
        summary: 'Core cloud concepts, IAM, storage, and basic deployment workflows.',
      );
      await _portfolioRepo.createEducation(
        degree: 'Agile & Product Thinking',
        institution: 'Google Digital Skills for Africa',
        period: '2024',
        summary: 'MVP thinking, iteration, roadmaps, and stakeholder communication.',
      );
    }

    if (projectsEmpty) {
      await _portfolioRepo.createProject(
        title: 'SkillBridge',
        description: 'Student + Employer flows with role routing, modern UI, and assessment-driven insights.',
        url: 'https://github.com/macrineakinyi84/SkillBridge',
      );
      await _portfolioRepo.createProject(
        title: 'Mtaa Events',
        description: 'Browse events, RSVP, share, and get directions. Focused on clean UI and accessibility.',
      );
      await _portfolioRepo.createProject(
        title: 'HuruDrive (Prototype)',
        description: 'File upload and organization prototype; learned state management and error handling.',
      );
      await _portfolioRepo.createProject(
        title: 'KaziBoard UI Kit',
        description: 'Reusable job board components: filters, cards, skeleton loaders, empty states.',
      );
      await _portfolioRepo.createProject(
        title: 'Habit Streak Tracker',
        description: 'Streaks, reminders, and weekly summaries; offline-first with local persistence.',
      );
    }

    if (certsEmpty) {
      await _portfolioRepo.createCertification(name: 'Flutter & Dart', issuer: 'Udemy', date: 'Dec 2025');
      await _portfolioRepo.createCertification(name: 'Git & GitHub', issuer: 'freeCodeCamp', date: 'Aug 2025');
      await _portfolioRepo.createCertification(name: 'REST APIs', issuer: 'Postman', date: 'Jun 2025');
      await _portfolioRepo.createCertification(name: 'UI Design Basics', issuer: 'Coursera', date: 'Mar 2025');
      await _portfolioRepo.createCertification(name: 'Agile Foundations', issuer: 'LinkedIn Learning', date: 'Jan 2025');
    }
  }

  String _pickName() {
    final r = Random();
    final first = SeedData.firstNames[r.nextInt(SeedData.firstNames.length)];
    final last = SeedData.lastNames[r.nextInt(SeedData.lastNames.length)];
    return '$first $last';
  }

  String _pickCounty() {
    final r = Random();
    return SeedData.counties[r.nextInt(SeedData.counties.length)];
  }
}

