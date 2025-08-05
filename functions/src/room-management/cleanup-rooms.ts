import * as functions from "firebase-functions";
import { DatabaseHelper, COLLECTIONS } from "../utils/database";
import { ErrorHelper } from "../utils/validation";
import { RoomData } from "../utils/types";

export const cleanupRooms = functions.pubsub.schedule("every 1 hours").onRun(async context => {
  try {
    functions.logger.info("Starting room cleanup job");

    // Clean up rooms older than 24 hours that are not in progress
    const cutoffTime = new Date();
    cutoffTime.setHours(cutoffTime.getHours() - 24);

    const staleRooms = await DatabaseHelper.queryDocuments(COLLECTIONS.ROOMS, [
      { field: "createdAt", operator: "<", value: cutoffTime },
      { field: "status", operator: "in", value: ["waiting", "completed"] },
    ]) as RoomData[];

    functions.logger.info(`Found ${staleRooms.length} stale rooms to clean up`);

    // Delete stale rooms and associated player records
    const deletePromises = staleRooms.map(async room => {
      // Delete associated player records
      const players = await DatabaseHelper.queryDocuments(COLLECTIONS.PLAYERS, [
        { field: "roomCode", operator: "==", value: room.code },
      ]);

      const playerDeletePromises = players.map(player =>
        DatabaseHelper.deleteDocument(COLLECTIONS.PLAYERS, player.id)
      );

      await Promise.all(playerDeletePromises);

      // Delete the room
      await DatabaseHelper.deleteDocument(COLLECTIONS.ROOMS, room.id!);

      functions.logger.info(`Cleaned up room ${room.code} with ${players.length} players`);
    });

    await Promise.all(deletePromises);

    functions.logger.info(`Room cleanup completed. Deleted ${staleRooms.length} rooms`);

    return {
      success: true,
      deletedRooms: staleRooms.length,
    };

  } catch (error) {
    ErrorHelper.logAndThrow(error, "cleanupRooms", { context });
  }
});
