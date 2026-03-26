const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

function pick(arr, i) {
  return arr[i % arr.length];
}

async function main() {
  const firstNames = [
    'Wanjiku', 'Akinyi', 'Njeri', 'Wambui', 'Atieno', 'Chebet', 'Wairimu', 'Wangari',
    'Auma', 'Mwende', 'Kendi', 'Naliaka', 'Cherono', 'Moraa',
    'Kiptoo', 'Mutiso', 'Omondi', 'Wanjala', 'Barasa', 'Kamau',
  ];
  const lastNames = [
    'Ochieng', 'Odhiambo', 'Mwangi', 'Waweru', 'Kiprotich', 'Kariuki', 'Mutua', 'Chege',
    'Gitau', 'Njuguna', 'Wafula', 'Wekesa', 'Korir', 'Bii', 'Mbugua', 'Kilonzo',
  ];
  const counties = ['Nairobi', 'Mombasa', 'Kisumu', 'Nakuru', 'Kiambu', 'Uasin Gishu', 'Machakos', 'Kakamega', 'Nyeri', 'Meru'];

  // Employers
  const employers = [
    { email: 'hr@kaributech.co.ke', displayName: 'KaribuTech HR', county: 'Nairobi' },
    { email: 'talent@pwaniworks.co.ke', displayName: 'PwaniWorks Talent', county: 'Mombasa' },
  ];

  for (const e of employers) {
    await prisma.user.upsert({
      where: { email: e.email },
      update: { role: 'employer', isVerified: true, displayName: e.displayName, county: e.county },
      create: { email: e.email, role: 'employer', isVerified: true, displayName: e.displayName, county: e.county },
    });
  }

  // Students
  const studentCount = 18;
  const students = [];
  for (let i = 0; i < studentCount; i++) {
    const first = pick(firstNames, i);
    const last = pick(lastNames, i * 3 + 1);
    const displayName = `${first} ${last}`;
    const email = `${first.toLowerCase()}.${last.toLowerCase()}@example.com`;
    const county = pick(counties, i * 7 + 2);
    const user = await prisma.user.upsert({
      where: { email },
      update: { role: 'student', isVerified: true, displayName, county },
      create: { email, role: 'student', isVerified: true, displayName, county },
    });
    students.push(user);
  }

  const categories = [
    'digital-literacy',
    'communication',
    'business-entrepreneurship',
    'technical-ict',
    'soft-skills-leadership',
  ];

  // SkillScores + Assessments
  for (let i = 0; i < students.length; i++) {
    const u = students[i];
    for (let c = 0; c < categories.length; c++) {
      const categoryId = categories[c];
      const base = 45 + ((i * 9 + c * 13) % 45); // 45-89
      await prisma.skillScore.upsert({
        where: { userId_categoryId: { userId: u.id, categoryId } },
        update: { currentScore: base, updatedAt: new Date() },
        create: { userId: u.id, categoryId, currentScore: base },
      });
      await prisma.assessment.create({
        data: {
          userId: u.id,
          categoryId,
          normalisedScore: base,
          rawScore: Math.round((base / 100) * 24),
          maxPossibleScore: 24,
          tier: base >= 80 ? 'Advanced' : base >= 60 ? 'Intermediate' : 'Beginner',
        },
      });
    }
  }

  console.log(`Seeded ${employers.length} employers and ${students.length} students with skill scores/assessments.`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

