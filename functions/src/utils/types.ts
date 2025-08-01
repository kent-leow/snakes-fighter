// Common types for Cloud Functions

export interface RoomData {
    id?: string;
    code: string;
    hostId: string;
    hostName: string;
    maxPlayers: number;
    currentPlayers: number;
    gameMode: string;
    isPrivate: boolean;
    status: "waiting" | "starting" | "in-progress" | "completed";
    players: string[];
    createdAt?: FirebaseFirestore.Timestamp;
    updatedAt?: FirebaseFirestore.Timestamp;
}

export interface PlayerData {
    id?: string;
    userId: string;
    roomCode: string;
    playerName: string;
    status: "active" | "disconnected" | "left";
    joinedAt: string;
    createdAt?: FirebaseFirestore.Timestamp;
    updatedAt?: FirebaseFirestore.Timestamp;
}

export interface GameStateData {
    id?: string;
    roomCode: string;
    gameId: string;
    status: "preparing" | "active" | "paused" | "completed";
    players: PlayerGameData[];
    boardSize: { width: number; height: number };
    createdAt?: FirebaseFirestore.Timestamp;
    updatedAt?: FirebaseFirestore.Timestamp;
}

export interface PlayerGameData {
    playerId: string;
    playerName: string;
    snake: SnakeData;
    score: number;
    status: "alive" | "dead";
}

export interface SnakeData {
    positions: Position[];
    direction: Direction;
    length: number;
}

export interface Position {
    x: number;
    y: number;
}

export type Direction = "up" | "down" | "left" | "right";

export interface MoveData {
    playerId: string;
    direction: Direction;
    timestamp: number;
}
