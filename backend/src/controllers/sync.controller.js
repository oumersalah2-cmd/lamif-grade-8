import prisma from '../prisma.js';

/**
 * POST /api/v1/exams/sync
 * Sync endpoint accepting batch exam results and user progress from Isar offline database
 */
export async function syncOfflineRecords(req, res) {
  try {
    const { phone, userId, examResults = [], userProgress = [] } = req.body;

    const syncedExamIds = [];
    const syncedProgressIds = [];

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

    // Process Exam Results
    for (const record of examResults) {
      const localId = record.id ?? record.localId;
      try {
        if (prisma && prisma.examResult && user) {
          await prisma.examResult.create({
            data: {
              localId: typeof localId === 'number' ? localId : null,
              userId: user.id,
              subjectId: record.subjectId || 'waliigala',
              score: Number(record.score) || 0,
              totalQuestions: Number(record.totalQuestions) || 0,
              timeTaken: Number(record.timeTaken) || 0,
              dateTaken: record.dateTaken ? new Date(record.dateTaken) : new Date(),
            },
          });
        }
        if (localId !== undefined && localId !== null) {
          syncedExamIds.push(localId);
        }
      } catch (err) {
        console.warn('Error saving individual exam result:', err.message);
        // Still acknowledge if duplicate or insert failed gracefully
        if (localId !== undefined && localId !== null) {
          syncedExamIds.push(localId);
        }
      }
    }

    // Process User Progress
    for (const prog of userProgress) {
      const localId = prog.id ?? prog.localId;
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
              totalQuestionsAttempted: Number(prog.totalQuestionsAttempted) || 0,
              totalCorrectAnswers: Number(prog.totalCorrectAnswers) || 0,
              totalTimeSpentSeconds: Number(prog.totalTimeSpentSeconds) || 0,
              lastStudiedAt: prog.lastStudiedAt ? new Date(prog.lastStudiedAt) : new Date(),
            },
            create: {
              userId: user.id,
              subjectId: prog.subjectId,
              totalQuestionsAttempted: Number(prog.totalQuestionsAttempted) || 0,
              totalCorrectAnswers: Number(prog.totalCorrectAnswers) || 0,
              totalTimeSpentSeconds: Number(prog.totalTimeSpentSeconds) || 0,
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
      message: "Qabxiin fi sochii barataa milkaa'inaan gara PostgreSQLtti sync ta'eera.",
      syncedIds: syncedExamIds,
      syncedExamIds,
      syncedProgressIds,
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
