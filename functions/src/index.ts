import * as functions from "firebase-functions";

// Test function to verify Firebase Functions setup
export const helloWorld = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    response.send("Hello from Snakes Fight Firebase Functions!");
});

// Health check function
export const healthCheck = functions.https.onRequest((request, response) => {
    response.json({
        status: "healthy",
        timestamp: new Date().toISOString(),
        project: "snakes-fight-dev",
        version: "1.0.0",
    });
});
