const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require("@firebase/rules-unit-testing");
const { test, before, after, beforeEach } = require("node:test");
const fs = require("node:fs");

let testEnv;
const PROJECT_ID = process.env.GCP_PROJECT || "demo-no-project";
const ALICE_UID = "alice_123";
const BOB_UID = "bob_456";

const [emulatorHost, emulatorPortStr] = (process.env.FIRESTORE_EMULATOR_HOST || "127.0.0.1:8085").split(":");
const emulatorPort = parseInt(emulatorPortStr, 10);

before(async () => {
  const rules = fs.readFileSync("./firestore.rules", "utf8");
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules,
      host: emulatorHost,
      port: emulatorPort,
    },
  });
});

after(async () => {
  if (testEnv) {
    await testEnv.cleanup();
  }
});

beforeEach(async () => {
  if (testEnv) {
    await testEnv.clearFirestore();
  }
});

test("Unauthenticated user: cannot read user profile", async () => {
  const unauthDb = testEnv.unauthenticatedContext().firestore();
  await assertFails(unauthDb.collection("users").doc(ALICE_UID).get());
});

test("Authenticated user: can create their own valid profile", async () => {
  const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
  await assertSucceeds(
    aliceDb.collection("users").doc(ALICE_UID).set({
      fullName: "Tolera Gemechu",
      phoneNumber: "+251911223344",
      schoolName: "Bishoftu No 1 Secondary",
      zoneName: "Shawaa Bahaa",
      targetScore: 92,
    })
  );
});

test("Authenticated user: cannot create invalid profile (missing required fields)", async () => {
  const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
  await assertFails(
    aliceDb.collection("users").doc(ALICE_UID).set({
      fullName: "", // invalid empty string
      schoolName: "Test School",
    })
  );
});

test("Cross-user isolation: Bob cannot read Alice's profile", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection("users").doc(ALICE_UID).set({
      fullName: "Alice Student",
      schoolName: "Adama High",
      zoneName: "Shawaa Bahaa",
      targetScore: 90,
    });
  });

  const bobDb = testEnv.authenticatedContext(BOB_UID).firestore();
  await assertFails(bobDb.collection("users").doc(ALICE_UID).get());
});

test("Authenticated user: can add exam attempt to own subcollection", async () => {
  const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
  await assertSucceeds(
    aliceDb.collection("users").doc(ALICE_UID).collection("exam_attempts").doc("attempt_1").set({
      subjectId: "herrega",
      examType: "MOCK_MINISTRY",
      totalQuestions: 20,
      correctAnswersCount: 18,
      scorePercentage: 90,
      timeTakenSeconds: 1200,
    })
  );
});

test("Cross-user isolation: Bob cannot read Alice's exam attempts", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection("users").doc(ALICE_UID).collection("exam_attempts").doc("attempt_1").set({
      subjectId: "herrega",
      examType: "MOCK_MINISTRY",
      totalQuestions: 20,
      correctAnswersCount: 18,
      scorePercentage: 90,
      timeTakenSeconds: 1200,
    });
  });

  const bobDb = testEnv.authenticatedContext(BOB_UID).firestore();
  await assertFails(bobDb.collection("users").doc(ALICE_UID).collection("exam_attempts").doc("attempt_1").get());
});
