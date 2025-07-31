# 🐍 Greedy Snake Multiplayer Game - Requirements

## 🎯 Game Overview

- **Game Type**: Real-time, competitive greedy snake
- **Platform**: Flutter (Web, Android, iOS)
- **Multiplayer**: Online-only (1 device = 1 player)
- **Objective**: Reach target snake length or be the last player alive

---

## 📐 Core Game Rules (Draft)

| Feature          | Requirement                                     |
| ---------------- | ----------------------------------------------- |
| Snake Movement   | 4-directional (↑ ↓ ← →), constant speed         |
| Food Spawn       | Random on grid, 1–5 visible at a time           |
| Win Condition    | - First to reach length X- OR last player alive |
| Death Conditions | - Hits wall- Hits own or another snake’s body   |
| Respawn          | ❌ No respawn after death                        |
| Controls         | Swipe gestures for mobile                       |
| Player Limit     | 2–4 players per room                            |
| Game Timeout     | Auto-end after N minutes (set in room settings) |
| Map Size         | Set in room settings (Fixed or adaptive)        |
| Obstacles        | ✅ Yes — static or random, configurable          |

---

## 🧩 Game Elements

| Element       | Properties                                                            |
| ------------- | --------------------------------------------------------------------- |
| Player Snake  | ID, Color, Position, Direction, Body (list of points), Alive status   |
| Food          | ID, Position                                                          |
| Game Room     | Room ID, Player list, Game state (waiting/active/ended), Host ID      |
| Game Settings | Target length, Max players, Map size, Timeout duration, Obstacle mode |

---

## 👥 Multiplayer Architecture (Firebase)

| Requirement         | Tool/Method                                         |
| ------------------- | --------------------------------------------------- |
| Room Join/Create    | Firebase Realtime DB                                |
| Realtime Sync       | Firebase Realtime DB                                |
| Game Logic          | Firebase Cloud Functions (validate moves, game end) |
| Cheat Prevention    | Server-side validation                              |
| Player Sync Latency | Batched writes/throttling                           |

---

## 💬 Optional Features (To Confirm)

| Feature             | Include? | Notes                                    |
| ------------------- | -------- | ---------------------------------------- |
| Lobby Chat          | ✅ Yes    | Chat while waiting in room               |
| Spectator Mode      | ✅ Yes    | Watch ongoing match                      |
| Leaderboard         | ✅ Yes    | Global or per-room                       |
| Player Stats        | ✅ Yes    | Track wins, games played, average length |
| Skins/Customization | ✅ Yes    | Change snake color or style              |
| Push Notifications  | ✅ Yes    | Game invites/reminders                   |

---

## 🔌 GCP/Firebase Service Mapping

| Feature               | Service                  | Free Tier                          |
| --------------------- | ------------------------ | ---------------------------------- |
| Auth                  | Firebase Auth            | ✅ 10K users/month                  |
| Game State Sync       | Firebase Realtime DB     | ✅ 1GB storage, 50K reads/day       |
| Room/Game Logic       | Firebase Cloud Functions | ✅ 2M invocations/month             |
| Hosting (Flutter Web) | Firebase Hosting         | ✅ 1GB storage, 10GB transfer/month |
| Analytics             | Firebase Analytics       | ✅ Free                             |

---

## 📲 UI & Controls

| Platform   | Controls                         |
| ---------- | -------------------------------- |
| Mobile     | Swipe gestures                   |
| Web        | Arrow keys or on-screen controls |
| Responsive | Layout adapts to device size     |

---

## 🔧 Development Checklist

-

---

## 📌 Next Steps

✅ Confirmed:

1. **Controls**: Swipe for mobile
2. **Obstacles**: Yes — include them
3. **Optional features**: Include all listed examples
4. **Game timeout/map size/target length**: All configurable per room settings

---

## 🗂️ Firebase Realtime DB Schema (Draft)

```json
{
  "rooms": {
    "roomId123": {
      "host": "user123",
      "state": "waiting", // waiting, active, ended
      "settings": {
        "maxPlayers": 4,
        "mapSize": "medium",
        "timeout": 300,
        "targetLength": 30,
        "obstacles": true
      },
      "players": {
        "user123": {
          "name": "Player1",
          "color": "#00FF00",
          "position": [5, 5],
          "direction": "up",
          "body": [[5,5],[5,4],[5,3]],
          "alive": true
        }
      },
      "food": {
        "foodId1": { "x": 10, "y": 15 },
        "foodId2": { "x": 20, "y": 25 }
      },
      "obstacles": {
        "obs1": { "x": 3, "y": 7 },
        "obs2": { "x": 14, "y": 6 }
      }
    }
  }
}
```

---

## 🔁 Game Logic Flow (High-Level)

1. **Create/Join Room**
2. **Wait for players to join** (room = "waiting")
3. **Game Start** (room = "active")
4. **Game loop (every X ms):**
   - Move snakes
   - Check for collisions (walls, self, others, food)
   - Spawn food if needed
   - Update snake body & length
   - Sync changes to Firebase
   - Trigger Cloud Function if someone dies or wins
5. **End Game:**
   - All but one snake dead OR max timeout reached OR target length reached
   - Set room = "ended"
   - Show results

---

## ⚙️ Setup Plan

- Firebase Project with:
  - Realtime DB
  - Cloud Functions
  - Hosting (if using web)
  - Firebase Auth (anonymous for MVP)
- Flutter Project:
  - Game UI
  - Firebase integration
  - Swipe input & animation
  - DB sync with game state
- Local Testing:
  - Firebase Emulator Suite
  - Multiplayer test with at least 2 clients

---

## 📊 Free-Tier Usage Monitoring Tips

- Use `firebase-debug.log` and GCP billing dashboard
- Throttle game updates (e.g., 5-10 times/sec max)
- Clean up ended rooms to save DB space
- Bundle Cloud Function logic efficiently to reduce invocations

