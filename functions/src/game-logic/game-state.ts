import * as functions from "firebase-functions";
import { DatabaseHelper, COLLECTIONS } from "../utils/database";
import { AuthHelper, ErrorHelper } from "../utils/validation";
import { GameStateData, PlayerGameData, SnakeData, Position } from "../utils/types";

interface CreateGameStateRequest {
    roomCode: string;
    boardWidth?: number;
    boardHeight?: number;
}

export const createGameState = functions.https.onCall(async (data: CreateGameStateRequest, context) => {
  try {
    // Validate authentication
    const user = await AuthHelper.validateAndGetUser(context);

    // Validate required fields
    if (!data.roomCode) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Room code is required"
      );
    }

    // Get room data
    const room = await DatabaseHelper.getDocument(COLLECTIONS.ROOMS, data.roomCode) as any;
    if (!room) {
      throw new functions.https.HttpsError(
        "not-found",
        "Room not found"
      );
    }

    // Check if user is the host
    if (room.hostId !== user.uid) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only the room host can start the game"
      );
    }

    // Check if room has enough players
    if (room.currentPlayers < 2) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Need at least 2 players to start the game"
      );
    }

    // Get all players in the room
    const players = await DatabaseHelper.queryDocuments(COLLECTIONS.PLAYERS, [
      { field: "roomCode", operator: "==", value: data.roomCode },
      { field: "status", operator: "==", value: "active" },
    ]) as any[];

    if (players.length !== room.currentPlayers) {
      throw new functions.https.HttpsError(
        "internal",
        "Player count mismatch"
      );
    }

    // Create game state
    const boardSize = {
      width: data.boardWidth || 20,
      height: data.boardHeight || 20,
    };

    // Initialize player positions (spread around the board)
    const gameId = `game_${data.roomCode}_${Date.now()}`;
    const gameStatePlayers: PlayerGameData[] = players.map((player, index) => {
      const startPosition = getStartPosition(index, players.length, boardSize);
      const snake: SnakeData = {
        positions: [startPosition],
        direction: getStartDirection(index, players.length),
        length: 1,
      };

      return {
        playerId: player.userId,
        playerName: player.playerName,
        snake,
        score: 0,
        status: "alive",
      };
    });

    const gameState: Omit<GameStateData, "createdAt" | "updatedAt"> = {
      roomCode: data.roomCode,
      gameId,
      status: "preparing",
      players: gameStatePlayers,
      boardSize,
    };

    // Save game state
    await DatabaseHelper.createDocument(COLLECTIONS.GAMES, gameState, gameId);

    // Update room status
    await DatabaseHelper.updateDocument(COLLECTIONS.ROOMS, data.roomCode, {
      status: "starting",
    });

    functions.logger.info("Game state created successfully", {
      gameId,
      roomCode: data.roomCode,
      playerCount: players.length,
      boardSize,
    });

    return {
      success: true,
      gameId,
      gameState,
    };

  } catch (error) {
    ErrorHelper.logAndThrow(error, "createGameState", { data, userId: context.auth?.uid });
  }
});

export const updateGameState = functions.https.onCall(async (data: any, context) => {
  try {
    // Validate authentication
    await AuthHelper.validateAndGetUser(context);

    // This is a placeholder for game state updates
    // In a real implementation, this would handle turn-based updates

    return {
      success: true,
      message: "Game state update functionality will be implemented in future tasks",
    };

  } catch (error) {
    ErrorHelper.logAndThrow(error, "updateGameState", { data, userId: context.auth?.uid });
  }
});

// Helper functions for game initialization
function getStartPosition(playerIndex: number, totalPlayers: number,
  boardSize: { width: number; height: number }): Position {
  const padding = 3; // Distance from board edges

  switch (totalPlayers) {
  case 2:
    return playerIndex === 0
      ? { x: padding, y: Math.floor(boardSize.height / 2) }
      : { x: boardSize.width - padding - 1, y: Math.floor(boardSize.height / 2) };

  case 3:
    const positions3 = [
      { x: padding, y: padding },
      { x: boardSize.width - padding - 1, y: padding },
      { x: Math.floor(boardSize.width / 2), y: boardSize.height - padding - 1 },
    ];
    return positions3[playerIndex];

  case 4:
  default:
    const positions4 = [
      { x: padding, y: padding },
      { x: boardSize.width - padding - 1, y: padding },
      { x: padding, y: boardSize.height - padding - 1 },
      { x: boardSize.width - padding - 1, y: boardSize.height - padding - 1 },
    ];
    return positions4[playerIndex % 4];
  }
}

function getStartDirection(playerIndex: number, totalPlayers: number): "up" | "down" | "left" | "right" {
  switch (totalPlayers) {
  case 2:
    return playerIndex === 0 ? "right" : "left";

  case 3:
    const directions3 = ["right", "left", "up"];
    return directions3[playerIndex] as any;

  case 4:
  default:
    const directions4 = ["right", "left", "right", "left"];
    return directions4[playerIndex % 4] as any;
  }
}
