import '../domain/models/learning_path.dart';
import '../domain/models/micro_lesson.dart';
import '../domain/models/skill_gap_recommendation.dart';

/// Mock data for Learning Hub. Replace with repository/API when backend is ready.
class LearningMockData {
  LearningMockData._();

  static MicroLesson get todaysLesson => const MicroLesson(
        id: 'daily-1',
        title: 'Writing Clear Emails That Get Replies',
        durationMinutes: 5,
        category: 'Communication',
        skillImproved: 'Communication',
        content: '''
**Why it matters**
Clear emails save time and reduce back-and-forth. In the workplace, **concise** and **professional** emails help you build trust.

**Key principles**
1. **Subject line**: Use a short, specific subject so the reader knows what to expect.
2. **Opening**: State the purpose in the first sentence.
3. **Body**: Use short paragraphs and **bullet points** when listing items.
4. **Closing**: End with one clear **call to action** or question.
5. **Proofread**: Check for typos and tone before sending.

**Quick tip**
If your email is longer than a few paragraphs, consider whether a quick call might be better.
''',
        keyTerms: ['concise', 'professional', 'call to action', 'proofread'],
      );

  static int get learnStreakCount => 5;

  static List<LearningPath> get learningPaths => [
        LearningPath(
          id: 'path-1',
          title: 'Digital Literacy Essentials',
          category: 'Digital Literacy',
          totalWeeks: 4,
          estimatedHours: 12,
          progressPercent: 0.4,
          isRecommended: false,
          weeks: [
            PathWeek(
              weekNumber: 1,
              isUnlocked: true,
              isCompleted: true,
              resources: [
                const PathResource(id: 'r1', title: 'Intro to Digital Tools', type: ResourceType.video, durationMinutes: 10, url: 'https://example.com/1', isCompleted: true),
                const PathResource(id: 'r2', title: 'Reading: Online Safety', type: ResourceType.article, durationMinutes: 5, url: 'https://example.com/2', isCompleted: true),
              ],
            ),
            PathWeek(
              weekNumber: 2,
              isUnlocked: true,
              isCompleted: false,
              resources: [
                const PathResource(id: 'r3', title: 'Using Spreadsheets', type: ResourceType.video, durationMinutes: 15, url: 'https://example.com/3'),
                const PathResource(id: 'r4', title: 'Quiz: Basics', type: ResourceType.quiz, durationMinutes: 5, url: 'https://example.com/4'),
              ],
            ),
            PathWeek(weekNumber: 3, isUnlocked: false, resources: [const PathResource(id: 'r5', title: 'Week 3 Resource', type: ResourceType.article, durationMinutes: 8)]),
            PathWeek(weekNumber: 4, isUnlocked: false, resources: [const PathResource(id: 'r6', title: 'Week 4 Resource', type: ResourceType.video, durationMinutes: 12)]),
          ],
        ),
        LearningPath(
          id: 'path-2',
          title: 'Communication for Work',
          category: 'Communication',
          totalWeeks: 3,
          estimatedHours: 8,
          progressPercent: 0,
          isRecommended: true,
          weeks: [
            PathWeek(
              weekNumber: 1,
              isUnlocked: true,
              resources: [
                const PathResource(id: 'c1', title: 'Active Listening', type: ResourceType.video, durationMinutes: 12, url: 'https://example.com/c1'),
                const PathResource(id: 'c2', title: 'Email Etiquette', type: ResourceType.article, durationMinutes: 6, url: 'https://example.com/c2'),
              ],
            ),
            PathWeek(weekNumber: 2, isUnlocked: false, resources: []),
            PathWeek(weekNumber: 3, isUnlocked: false, resources: []),
          ],
        ),
        LearningPath(
          id: 'path-3',
          title: 'Technical (ICT) Foundations',
          category: 'Technical (ICT)',
          totalWeeks: 6,
          estimatedHours: 18,
          progressPercent: 0,
          isRecommended: true,
          weeks: List.generate(6, (i) => PathWeek(weekNumber: i + 1, isUnlocked: i == 0, resources: [PathResource(id: 't$i', title: 'Week ${i + 1} intro', type: ResourceType.video, durationMinutes: 10)])),
        ),
      ];

  static List<SkillGapRecommendation> get skillGapRecommendations => [
        SkillGapRecommendation(
          skillName: 'Digital Literacy',
          categoryId: 'digital-literacy',
          yourScore: 45,
          benchmarkScore: 70,
          resources: [
            const GapResourceLink(title: 'Digital basics (Khan Academy)', url: 'https://www.khanacademy.org/', type: 'article'),
            const GapResourceLink(title: 'Google Digital Garage', url: 'https://learndigital.withgoogle.com/', type: 'video'),
            const GapResourceLink(title: 'Practice quiz', url: 'https://example.com/quiz', type: 'quiz'),
          ],
        ),
        SkillGapRecommendation(
          skillName: 'Communication',
          categoryId: 'communication',
          yourScore: 52,
          benchmarkScore: 65,
          resources: [
            const GapResourceLink(title: 'Writing for work', url: 'https://example.com/writing', type: 'article'),
            const GapResourceLink(title: 'Presentation skills', url: 'https://example.com/present', type: 'video'),
            const GapResourceLink(title: 'Quick assessment', url: 'https://example.com/comm-quiz', type: 'quiz'),
          ],
        ),
        SkillGapRecommendation(
          skillName: 'Technical (ICT)',
          categoryId: 'technical-ict',
          yourScore: 38,
          benchmarkScore: 60,
          resources: [
            const GapResourceLink(title: 'Intro to coding', url: 'https://www.codecademy.com/', type: 'video'),
            const GapResourceLink(title: 'Computer basics', url: 'https://example.com/basics', type: 'article'),
            const GapResourceLink(title: 'Skills check', url: 'https://example.com/tech-quiz', type: 'quiz'),
          ],
        ),
      ];
}
