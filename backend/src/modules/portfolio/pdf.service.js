// Portfolio PDF generation using pdf-lib.
// Generates a CV-style PDF and returns it as a Node Buffer for download.
const { PDFDocument, StandardFonts, rgb, degrees } = require('pdf-lib');

/**
 * Generate a CV PDF for a user.
 *
 * @param {Object} data
 * @param {Object} data.profile - Basic profile info.
 * @param {string} data.profile.name
 * @param {string} data.profile.headline
 * @param {string} data.profile.email
 * @param {string} [data.profile.phone]
 * @param {string} [data.profile.county]
 * @param {string} [data.profile.slug] - Public profile slug for footer URL.
 * @param {Array<{ name: string, score: number }>} [data.skills] - e.g. [{ name: 'Digital Literacy', score: 78 }]
 * @param {Array<Object>} [data.experience] - Reverse chronological.
 * @param {Array<Object>} [data.education]
 * @param {Array<Object>} [data.projects]
 * @param {Array<Object>} [data.certifications]
 * @returns {Promise<Buffer>}
 */
async function generatePortfolioPdf(data) {
  const pdfDoc = await PDFDocument.create();
  const page = pdfDoc.addPage();

  const { width, height } = page.getSize();
  const margin = 40;
  let cursorY = height - margin;

  const fontRegular = await pdfDoc.embedFont(StandardFonts.Helvetica);
  const fontBold = await pdfDoc.embedFont(StandardFonts.HelveticaBold);

  const profile = data.profile || {};
  const skills = data.skills || [];
  const experience = data.experience || [];
  const education = data.education || [];
  const projects = data.projects || [];
  const certifications = data.certifications || [];

  // Simple helper to write a heading.
  const drawHeading = (text) => {
    page.drawText(text, {
      x: margin,
      y: cursorY,
      size: 14,
      font: fontBold,
      color: rgb(0.16, 0.16, 0.22),
    });
    cursorY -= 18;
  };

  const drawBodyLine = (text, options = {}) => {
    const size = options.size || 10;
    const font = options.bold ? fontBold : fontRegular;
    page.drawText(text, {
      x: margin,
      y: cursorY,
      size,
      font,
      color: rgb(0.2, 0.2, 0.2),
    });
    cursorY -= size + 4;
  };

  // Header background bar for "Professional" theme look.
  page.drawRectangle({
    x: 0,
    y: height - 90,
    width,
    height: 90,
    color: rgb(0.38, 0.36, 0.91),
  });

  cursorY = height - margin - 10;

  // Name + headline.
  const headerName = profile.name || 'Your Name';
  page.drawText(headerName, {
    x: margin,
    y: cursorY,
    size: 20,
    font: fontBold,
    color: rgb(1, 1, 1),
  });
  cursorY -= 22;

  if (profile.headline) {
    page.drawText(profile.headline, {
      x: margin,
      y: cursorY,
      size: 11,
      font: fontRegular,
      color: rgb(1, 1, 1),
    });
  }

  // Contact info, right-aligned-ish.
  const contactLines = [];
  if (profile.email) contactLines.push(profile.email);
  if (profile.phone) contactLines.push(profile.phone);
  if (profile.county) contactLines.push(profile.county);

  let contactY = height - margin - 6;
  contactLines.forEach((line) => {
    const textWidth = fontRegular.widthOfTextAtSize(line, 10);
    page.drawText(line, {
      x: width - margin - textWidth,
      y: contactY,
      size: 10,
      font: fontRegular,
      color: rgb(1, 1, 1),
    });
    contactY -= 12;
  });

  // Move cursor below header block.
  cursorY = height - 110;

  const ensureSpace = (needed = 40) => {
    if (cursorY - needed < margin + 40) {
      const nextPage = pdfDoc.addPage();
      cursorY = nextPage.getSize().height - margin;
      // Rotate reference to the new page.
      page.setRotation(degrees(0)); // no-op but keeps linter happy
    }
  };

  // Skills: text-based radar-style summary.
  if (skills.length > 0) {
    ensureSpace(50);
    drawHeading('Skills');
    const summary = skills
      .map((s) => `${s.name} ${Math.round(s.score)}%`)
      .join('  |  ');
    drawBodyLine(`Top skills: ${summary}`);
    cursorY -= 6;
  }

  // Experience (reverse chronological).
  if (experience.length > 0) {
    ensureSpace(60);
    drawHeading('Experience');
    experience.forEach((exp) => {
      ensureSpace(40);
      const titleLine = [exp.role, exp.company].filter(Boolean).join(' • ');
      drawBodyLine(titleLine, { bold: true });
      if (exp.period) {
        drawBodyLine(exp.period, { size: 9 });
      }
      if (exp.summary) {
        drawBodyLine(exp.summary, { size: 9 });
      }
      cursorY -= 4;
    });
  }

  // Education.
  if (education.length > 0) {
    ensureSpace(50);
    drawHeading('Education');
    education.forEach((ed) => {
      ensureSpace(32);
      const line = [ed.degree, ed.institution].filter(Boolean).join(' • ');
      drawBodyLine(line, { bold: true });
      if (ed.period) {
        drawBodyLine(ed.period, { size: 9 });
      }
      if (ed.summary) {
        drawBodyLine(ed.summary, { size: 9 });
      }
      cursorY -= 4;
    });
  }

  // Projects.
  if (projects.length > 0) {
    ensureSpace(60);
    drawHeading('Projects');
    projects.forEach((p) => {
      ensureSpace(36);
      drawBodyLine(p.name || p.title || 'Project', { bold: true });
      if (p.url) {
        drawBodyLine(p.url, { size: 9 });
      }
      if (p.summary || p.description) {
        drawBodyLine(p.summary || p.description, { size: 9 });
      }
      cursorY -= 4;
    });
  }

  // Certifications.
  if (certifications.length > 0) {
    ensureSpace(40);
    drawHeading('Certifications');
    certifications.forEach((c) => {
      ensureSpace(26);
      drawBodyLine(c.name || c.title || 'Certification', { bold: true });
      if (c.issuer) {
        drawBodyLine(c.issuer, { size: 9 });
      }
      if (c.date) {
        drawBodyLine(String(c.date), { size: 9 });
      }
      cursorY -= 4;
    });
  }

  // Footer.
  const slug = profile.slug || 'your-profile';
  const footerText = `Generated by SkillUp Kenya | skillupkenya.com/u/${slug}`;
  const footerSize = 8;
  const textWidth = fontRegular.widthOfTextAtSize(footerText, footerSize);
  page.drawText(footerText, {
    x: (width - textWidth) / 2,
    y: margin / 2,
    size: footerSize,
    font: fontRegular,
    color: rgb(0.45, 0.45, 0.5),
  });

  const pdfBytes = await pdfDoc.save();
  return Buffer.from(pdfBytes);
}

module.exports = {
  generatePortfolioPdf,
};

