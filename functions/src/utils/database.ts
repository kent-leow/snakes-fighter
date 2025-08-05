import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp();
}

export const db = admin.firestore();
export const auth = admin.auth();

// Database collection references
export const COLLECTIONS = {
  ROOMS: "rooms",
  GAMES: "games",
  PLAYERS: "players",
  MATCHES: "matches",
} as const;

// Helper functions for database operations
export class DatabaseHelper {
  static async createDocument(collection: string, data: any, id?: string) {
    const docRef = id ? db.collection(collection).doc(id) : db.collection(collection).doc();
    await docRef.set({
      ...data,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  static async updateDocument(collection: string, id: string, data: any) {
    await db.collection(collection).doc(id).update({
      ...data,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  static async getDocument(collection: string, id: string) {
    const doc = await db.collection(collection).doc(id).get();
    return doc.exists ? { id: doc.id, ...doc.data() } as any : null;
  }

  static async deleteDocument(collection: string, id: string) {
    await db.collection(collection).doc(id).delete();
  }

  static async queryDocuments(collection: string, filters: any[] = []) {
    let query: admin.firestore.Query = db.collection(collection);

    filters.forEach(filter => {
      query = query.where(filter.field, filter.operator, filter.value);
    });

    const snapshot = await query.get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }
}
