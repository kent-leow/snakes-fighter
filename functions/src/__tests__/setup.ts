import * as admin from "firebase-admin";

// Initialize Firebase Admin for testing
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: "snakes-fight-test",
  });
}

// Mock Firebase Functions test environment
process.env.FIRESTORE_EMULATOR_HOST = "localhost:8080";
process.env.FIREBASE_AUTH_EMULATOR_HOST = "localhost:9099";

// Placeholder test to make Jest happy
test("setup complete", () => {
  expect(true).toBe(true);
});
