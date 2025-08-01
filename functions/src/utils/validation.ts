import * as functions from "firebase-functions";

// Common validation utilities
export class ValidationHelper {
    static validateRequiredFields(data: any, requiredFields: string[]): void {
        const missingFields = requiredFields.filter(field => !data[field]);
        if (missingFields.length > 0) {
            throw new functions.https.HttpsError(
                "invalid-argument",
                `Missing required fields: ${missingFields.join(", ")}`
            );
        }
    }

    static validateEmail(email: string): boolean {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    static validateRoomCode(roomCode: string): boolean {
        // Room codes should be 6 characters alphanumeric
        const roomCodeRegex = /^[A-Z0-9]{6}$/;
        return roomCodeRegex.test(roomCode);
    }

    static validatePlayerName(name: string): boolean {
        // Player names should be 1-20 characters, letters, numbers, spaces, and basic punctuation
        const nameRegex = /^[a-zA-Z0-9\s\-_.]{1,20}$/;
        return nameRegex.test(name);
    }

    static sanitizeString(input: string): string {
        return input.trim().replace(/[<>]/g, "");
    }

    static generateRoomCode(): string {
        const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        let result = "";
        for (let i = 0; i < 6; i++) {
            result += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return result;
    }
}

// Authentication utilities
export class AuthHelper {
    static async validateUser(context: functions.https.CallableContext): Promise<string> {
        if (!context.auth) {
            throw new functions.https.HttpsError(
                "unauthenticated",
                "User must be authenticated to perform this action"
            );
        }
        return context.auth.uid;
    }

    static async validateAndGetUser(context: functions.https.CallableContext) {
        const uid = await AuthHelper.validateUser(context);
        return {
            uid,
            email: context.auth?.token.email,
            name: context.auth?.token.name,
        };
    }
}

// Game state validation utilities
export class GameValidation {
    static validateMovePosition(x: number, y: number, boardSize: { width: number; height: number }): boolean {
        return x >= 0 && x < boardSize.width && y >= 0 && y < boardSize.height;
    }

    static validateDirection(direction: string): boolean {
        const validDirections = ["up", "down", "left", "right"];
        return validDirections.includes(direction.toLowerCase());
    }
}

// Error handling utilities
export class ErrorHelper {
    static logAndThrow(error: any, functionName: string, context?: any): never {
        functions.logger.error(`Error in ${functionName}:`, {
            error: error.message,
            stack: error.stack,
            context,
        });

        if (error instanceof functions.https.HttpsError) {
            throw error;
        }

        throw new functions.https.HttpsError(
            "internal",
            "An internal error occurred"
        );
    }
}
