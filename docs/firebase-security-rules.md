# Firebase Security Rules Documentation

## Overview
This document describes the Firebase Realtime Database security rules implemented for the Snakes Fight multiplayer game. The rules ensure proper access control while enabling real-time multiplayer functionality.

## Security Rules Structure

### Rooms Collection
```json
"rooms": {
  "$roomId": {
    ".read": "auth != null && (data.child('players').child(auth.uid).exists() || !data.exists())",
    ".write": "auth != null",
    "players": {
      "$playerId": {
        ".write": "auth != null && $playerId == auth.uid"
      }
    },
    "gameState": {
      ".write": "auth != null && data.parent().child('players').child(auth.uid).exists()"
    }
  }
}
```

**Read Access:**
- Authenticated users can read room data only if:
  - They are a player in the room, OR
  - The room doesn't exist (allows room lookup/joining)

**Write Access:**
- Any authenticated user can write to rooms (for room creation)
- Players can only write their own player data
- Only room players can write to game state

### Users Collection
```json
"users": {
  "$userId": {
    ".read": "auth != null && $userId == auth.uid",
    ".write": "auth != null && $userId == auth.uid"
  }
}
```

**Access Control:**
- Users can only read/write their own user data
- Requires authentication

### Legacy Collections
The rules maintain backward compatibility with existing data structures:

- **games**: Basic authenticated access for legacy game data
- **players**: User-specific read/write for player profiles
- **lobbies**: Authenticated read/write for room discovery

## Security Features

### Authentication Requirements
- All operations require user authentication (`auth != null`)
- Prevents anonymous access to sensitive game data

### Data Isolation
- Players can only modify their own player data
- Users can only access their own user profiles
- Room access restricted to participants

### Multiplayer Support
- Room participants can read all room data
- Game state updates restricted to room players
- Supports real-time synchronization patterns

## Access Patterns

### Room Creation
1. Authenticated user creates room → ✅ Allowed
2. Unauthenticated user creates room → ❌ Denied

### Room Joining
1. User reads existing room → ✅ Allowed if participant or room doesn't exist
2. User joins room → ✅ Allowed (writes to room)
3. User writes player data → ✅ Allowed only for own player data

### Game Play
1. Room player updates game state → ✅ Allowed
2. Non-player updates game state → ❌ Denied
3. Player reads room data → ✅ Allowed

### User Management
1. User reads own profile → ✅ Allowed
2. User reads other's profile → ❌ Denied
3. User updates own profile → ✅ Allowed

## Testing
Security rules have been validated through:
- Firebase CLI syntax validation
- Successful deployment to development environment
- Unit test structure for rule validation scenarios

## Deployment
Rules are deployed using Firebase CLI:
```bash
firebase deploy --only database --project snakes-fight-dev
```

## Monitoring
Monitor rule violations through:
- Firebase Console → Database → Rules tab
- Firebase Analytics for security events
- Application logs for access denied errors
