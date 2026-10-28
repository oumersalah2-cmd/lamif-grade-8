import prisma from '../prisma.js';

/**
 * Validates whether an incoming offline exam result payload is plausible
 * to prevent corrupted or malicious client sync payloads.
 */
function validateExamResult(record) {
  const score = Number(record.score);
  const totalQuestions = Number(record.totalQuestions);
  const timeTaken = Number(record.timeTaken);

  if (!Number.isFinite(totalQuestions) || totalQuestions <= 0) {
    return { valid: false, reason: `Total questions (${record.totalQuestions}) must be greater than 0.` };
  }

  if (!Number.isFinite(score) || score < 0) {
    return { valid: false, reason: `Score (${record.score}) cannot be negative or invalid.` };
  }

  if (score > totalQuestions) {
    return { valid: false, reason: `Score (${score}) cannot exceed total questions (${totalQuestions}).` };
  }

  // An exam attempt under 5 seconds is physically impossible for Grade 8 tests;
  // An exam over 24 hours (86,400s) indicates a stuck or corrupted timer.
  if (!Number.isFinite(timeTaken) || timeTaken < 5 || timeTaken > 86400) {
    return { valid: false, reason: `timeTaken (${record.timeTaken}s) is implausible (must be between 5s and 86400s).` };
  }

  return { valid: true };
}

/**
 * Validates whether an incoming user progress record is mathematically valid
 */
function validateUserProgress(prog) {
  const attempted = Number(prog.totalQuestionsAttempted);
  const correct = Number(prog.totalCorrectAnswers);
  const timeSpent = Number(prog.totalTimeSpentSeconds);

  if (!Number.isFinite(attempted) || attempted < 0) {
    return { valid: false, reason: 'Questions attempted cannot be negative.' };
  }

  if (!Number.isFinite(correct) || correct < 0 || correct > attempted) {
    return { valid: false, reason: 'Correct answers cannot be negative or exceed questions attempted.' };
  }

  if (!Number.isFinite(timeSpent) || timeSpent < 0 || timeSpent > 604800) {
    return { valid: false, reason: 'Total time spent is implausible.' };
  }

  return { valid: true };
}

/**
 * POST /api/v1/exams/sync
 * Sync endpoint accepting batch exam results and user progress from Isar offline database
 */
export async function syncOfflineRecords(req, res) {
  try {
    const { phone, userId, examResults = [], userProgress = [] } = req.body;

    const syncedExamIds = [];
    const rejectedExamIds = [];
    const syncedProgressIds = [];
    const rejectedProgressIds = [];

    // Identify user
    let user = null;
    if (prisma && prisma.user) {
      try {
        if (userId) {
          user = await prisma.user.findUnique({ where: { id: userId } });
        } else if (phone) {
          user = await prisma.user.findUnique({ where: { phone } });
        }
      } catch (e) {
        console.warn('Prisma find user error in sync:', e.message);
      }
    }

    // Process & Validate Exam Results
    for (const record of examResults) {
      const localId = record.id ?? record.localId;
      
      // Server-side integrity check
      const validation = validateExamResult(record);
      if (!validation.valid) {
        console.warn(`[Sync Validation Reject] Exam localId ${localId}: ${validation.reason}`);
        if (localId !== undefined && localId !== null) {
          rejectedExamIds.push({ id: localId, reason: validation.reason });
        }
        continue; // Skip inserting corrupted or forged record
      }

      try {
        if (prisma && prisma.examResult && user) {
          await prisma.examResult.create({
            data: {
              localId: typeof localId === 'number' ? localId : null,
              userId: user.id,
              subjectId: record.subjectId || 'waliigala',
              score: Number(record.score),
              totalQuestions: Number(record.totalQuestions),
              timeTaken: Number(record.timeTaken),
              dateTaken: record.dateTaken ? new Date(record.dateTaken) : new Date(),
            },
          });
        }
        if (localId !== undefined && localId !== null) {
          syncedExamIds.push(localId);
        }
      } catch (err) {
        console.warn('Error saving individual exam result:', err.message);
        // Acknowledge to prevent infinite client retry loop if unique key conflicts
        if (localId !== undefined && localId !== null) {
          syncedExamIds.push(localId);
        }
      }
    }

    // Process & Validate User Progress
    for (const prog of userProgress) {
      const localId = prog.id ?? prog.localId;

      const validation = validateUserProgress(prog);
      if (!validation.valid) {
        console.warn(`[Sync Validation Reject] Progress localId ${localId}: ${validation.reason}`);
        if (localId !== undefined && localId !== null) {
          rejectedProgressIds.push({ id: localId, reason: validation.reason });
        }
        continue;
      }

      try {
        if (prisma && prisma.userProgress && user && prog.subjectId) {
          await prisma.userProgress.upsert({
            where: {
              userId_subjectId: {
                userId: user.id,
                subjectId: prog.subjectId,
              },
            },
            update: {
              totalQuestionsAttempted: Number(prog.totalQuestionsAttempted),
              totalCorrectAnswers: Number(prog.totalCorrectAnswers),
              totalTimeSpentSeconds: Number(prog.totalTimeSpentSeconds),
              lastStudiedAt: prog.lastStudiedAt ? new Date(prog.lastStudiedAt) : new Date(),
            },
            create: {
              userId: user.id,
              subjectId: prog.subjectId,
              totalQuestionsAttempted: Number(prog.totalQuestionsAttempted),
              totalCorrectAnswers: Number(prog.totalCorrectAnswers),
              totalTimeSpentSeconds: Number(prog.totalTimeSpentSeconds),
              lastStudiedAt: prog.lastStudiedAt ? new Date(prog.lastStudiedAt) : new Date(),
            },
          });
        }
        if (localId !== undefined && localId !== null) {
          syncedProgressIds.push(localId);
        }
      } catch (err) {
        console.warn('Error saving user progress:', err.message);
        if (localId !== undefined && localId !== null) {
          syncedProgressIds.push(localId);
        }
      }
    }

    return res.json({
      success: true,
      message: "Qabxiin fi sochii barataa milkaa'inaan gara PostgreSQLtti qulqullaa'ee sync ta'eera.",
      syncedIds: syncedExamIds,
      syncedExamIds,
      rejectedExamIds,
      syncedProgressIds,
      rejectedProgressIds,
      syncedAt: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Error during syncOfflineRecords:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to sync offline records.',
      error: error.message,
    });
  }
}
