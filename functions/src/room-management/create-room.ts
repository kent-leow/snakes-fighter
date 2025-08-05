import * as functions from "firebase-functions";
import { DatabaseHelper, COLLECTIONS } from "../utils/database";
import { ValidationHelper, AuthHelper, ErrorHelper } from "../utils/validation";

interface CreateRoomData {
    playerName: string;
    maxPlayers?: number;
    gameMode?: string;
    isPrivate?: boolean;
}

interface RoomData {
    code: string;
    hostId: string;
    hostName: string;
    maxPlayers: number;
    currentPlayers: number;
    gameMode: string;
    isPrivate: boolean;
    status: "waiting" | "starting" | "in-progress" | "completed";
    players: string[];
    createdAt: FirebaseFirestore.Timestamp;
    updatedAt: FirebaseFirestore.Timestamp;
}

export const createRoom = functions.https.onCall(async (data: CreateRoomData, context) => {
  try {
    // Validate authentication
    const user = await AuthHelper.validateAndGetUser(context);

    // Validate required fields
    ValidationHelper.validateRequiredFields(data, ["playerName"]);

    // Validate player name
    if (!ValidationHelper.validatePlayerName(data.playerName)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Player name must be 1-20 characters with letters, numbers, spaces, and basic punctuation"
      );
    }

    // Generate unique room code
    let roomCode: string;
    let attempts = 0;
    const maxAttempts = 10;

    do {
      roomCode = ValidationHelper.generateRoomCode();
      const existingRoom = await DatabaseHelper.getDocument(COLLECTIONS.ROOMS, roomCode);
      if (!existingRoom) break;
      attempts++;
    } while (attempts < maxAttempts);

    if (attempts >= maxAttempts) {
      throw new functions.https.HttpsError(
        "internal",
        "Failed to generate unique room code"
      );
    }

    // Create room data
    const roomData: Omit<RoomData, "createdAt" | "updatedAt"> = {
      code: roomCode,
      hostId: user.uid,
      hostName: ValidationHelper.sanitizeString(data.playerName),
      maxPlayers: data.maxPlayers || 4,
      currentPlayers: 1,
      gameMode: data.gameMode || "classic",
      isPrivate: data.isPrivate || false,
      status: "waiting",
      players: [user.uid],
    };

    // Save room to database
    await DatabaseHelper.createDocument(COLLECTIONS.ROOMS, roomData, roomCode);

    functions.logger.info("Room created successfully", {
      roomCode,
      hostId: user.uid,
      playerName: data.playerName,
    });

    return {
      success: true,
      roomCode,
      room: roomData,
    };

  } catch (error) {
    ErrorHelper.logAndThrow(error, "createRoom", { data, userId: context.auth?.uid });
  }
});
