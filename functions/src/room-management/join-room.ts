import * as functions from "firebase-functions";
import { DatabaseHelper, COLLECTIONS } from "../utils/database";
import { ValidationHelper, AuthHelper, ErrorHelper } from "../utils/validation";
import { RoomData } from "../utils/types";

interface JoinRoomData {
    roomCode: string;
    playerName: string;
}

export const joinRoom = functions.https.onCall(async (data: JoinRoomData, context) => {
    try {
        // Validate authentication
        const user = await AuthHelper.validateAndGetUser(context);

        // Validate required fields
        ValidationHelper.validateRequiredFields(data, ["roomCode", "playerName"]);

        // Validate room code format
        if (!ValidationHelper.validateRoomCode(data.roomCode)) {
            throw new functions.https.HttpsError(
                "invalid-argument",
                "Invalid room code format"
            );
        }

        // Validate player name
        if (!ValidationHelper.validatePlayerName(data.playerName)) {
            throw new functions.https.HttpsError(
                "invalid-argument",
                "Player name must be 1-20 characters with letters, numbers, spaces, and basic punctuation"
            );
        }

        // Get room data
        const room = await DatabaseHelper.getDocument(COLLECTIONS.ROOMS, data.roomCode) as RoomData | null;
        if (!room) {
            throw new functions.https.HttpsError(
                "not-found",
                "Room not found"
            );
        }

        // Check room status
        if (room.status !== "waiting") {
            throw new functions.https.HttpsError(
                "failed-precondition",
                "Room is not accepting new players"
            );
        }

        // Check if room is full
        if (room.currentPlayers >= room.maxPlayers) {
            throw new functions.https.HttpsError(
                "failed-precondition",
                "Room is full"
            );
        }

        // Check if player is already in the room
        if (room.players.includes(user.uid)) {
            throw new functions.https.HttpsError(
                "already-exists",
                "Player is already in this room"
            );
        }

        // Add player to room
        const updatedPlayers = [...room.players, user.uid];
        await DatabaseHelper.updateDocument(COLLECTIONS.ROOMS, data.roomCode, {
            players: updatedPlayers,
            currentPlayers: updatedPlayers.length,
        });

        // Create player record
        await DatabaseHelper.createDocument(COLLECTIONS.PLAYERS, {
            userId: user.uid,
            roomCode: data.roomCode,
            playerName: ValidationHelper.sanitizeString(data.playerName),
            status: "active",
            joinedAt: new Date().toISOString(),
        });

        functions.logger.info("Player joined room successfully", {
            roomCode: data.roomCode,
            playerId: user.uid,
            playerName: data.playerName,
        });

        return {
            success: true,
            roomCode: data.roomCode,
            playerCount: updatedPlayers.length,
        };

    } catch (error) {
        ErrorHelper.logAndThrow(error, "joinRoom", { data, userId: context.auth?.uid });
    }
});
