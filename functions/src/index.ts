import * as functions from "firebase-functions";

// Import function modules
import { createRoom } from "./room-management/create-room";
import { joinRoom } from "./room-management/join-room";
import { cleanupRooms } from "./room-management/cleanup-rooms";
import { validateMove } from "./game-logic/validate-move";
import { createGameState, updateGameState } from "./game-logic/game-state";

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

// Room Management Functions
export { createRoom, joinRoom, cleanupRooms };

// Game Logic Functions
export { validateMove, createGameState, updateGameState };
