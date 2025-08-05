import * as functions from "firebase-functions";
import { DatabaseHelper, COLLECTIONS } from "../utils/database";
import { AuthHelper, ErrorHelper, GameValidation } from "../utils/validation";
import { MoveData, GameStateData } from "../utils/types";

interface ValidateMoveRequest {
    gameId: string;
    direction: string;
}

export const validateMove = functions.https.onCall(async (data: ValidateMoveRequest, context) => {
  try {
    // Validate authentication
    const user = await AuthHelper.validateAndGetUser(context);

    // Validate required fields
    if (!data.gameId || !data.direction) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Game ID and direction are required"
      );
    }

    // Validate direction
    if (!GameValidation.validateDirection(data.direction)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid direction. Must be up, down, left, or right"
      );
    }

    // Get game state
    const gameState = await DatabaseHelper.getDocument(COLLECTIONS.GAMES, data.gameId) as GameStateData | null;
    if (!gameState) {
      throw new functions.https.HttpsError(
        "not-found",
        "Game not found"
      );
    }

    // Check if game is active
    if (gameState.status !== "active") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Game is not active"
      );
    }

    // Find player in game
    const player = gameState.players.find(p => p.playerId === user.uid);
    if (!player) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Player not found in this game"
      );
    }

    // Check if player is still alive
    if (player.status !== "alive") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Player is not alive"
      );
    }

    // Get current snake head position
    const snakeHead = player.snake.positions[0];
    if (!snakeHead) {
      throw new functions.https.HttpsError(
        "internal",
        "Invalid snake state"
      );
    }

    // Calculate new position based on direction
    let newX = snakeHead.x;
    let newY = snakeHead.y;

    switch (data.direction.toLowerCase()) {
    case "up":
      newY -= 1;
      break;
    case "down":
      newY += 1;
      break;
    case "left":
      newX -= 1;
      break;
    case "right":
      newX += 1;
      break;
    }

    // Validate move is within board boundaries
    if (!GameValidation.validateMovePosition(newX, newY, gameState.boardSize)) {
      return {
        valid: false,
        reason: "Move would go out of bounds",
        newPosition: { x: newX, y: newY },
      };
    }

    // Check for collision with own snake body
    const wouldCollideWithSelf = player.snake.positions.some(pos =>
      pos.x === newX && pos.y === newY
    );

    if (wouldCollideWithSelf) {
      return {
        valid: false,
        reason: "Move would collide with own snake",
        newPosition: { x: newX, y: newY },
      };
    }

    // Check for collision with other snakes
    const wouldCollideWithOthers = gameState.players.some(otherPlayer => {
      if (otherPlayer.playerId === user.uid || otherPlayer.status !== "alive") {
        return false;
      }
      return otherPlayer.snake.positions.some(pos => pos.x === newX && pos.y === newY);
    });

    if (wouldCollideWithOthers) {
      return {
        valid: false,
        reason: "Move would collide with another snake",
        newPosition: { x: newX, y: newY },
      };
    }

    // Move is valid - store it for processing
    const moveData: MoveData = {
      playerId: user.uid,
      direction: data.direction.toLowerCase() as any,
      timestamp: Date.now(),
    };

    // Log the validated move
    functions.logger.info("Move validated successfully", {
      gameId: data.gameId,
      playerId: user.uid,
      direction: data.direction,
      newPosition: { x: newX, y: newY },
    });

    return {
      valid: true,
      newPosition: { x: newX, y: newY },
      moveData,
    };

  } catch (error) {
    ErrorHelper.logAndThrow(error, "validateMove", { data, userId: context.auth?.uid });
  }
});
