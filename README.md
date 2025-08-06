# 🐍 Snakes Fight - Multiplayer Snake Game

A real-time multiplayer Snake game built with **Flutter** and **Firebase** that brings the classic Snake experience to multiple players in competitive online matches.

## 🎮 Game Overview

**Snakes Fight** is a modern take on the classic Snake game, designed for 2-4 players to compete in real-time matches. Players control their snakes to consume food, grow longer, and eliminate opponents by strategic movement and collision tactics.

### Core Gameplay
- **Objective**: Be the last snake alive or reach the target length first
- **Controls**: Swipe gestures (mobile) / Arrow keys (web)
- **Players**: 2-4 players per room
- **Platform**: Cross-platform (Web, Android, iOS)

## ✨ Features

### Core Game Mechanics
- ✅ Real-time multiplayer gameplay
- ✅ 4-directional snake movement with collision detection
- ✅ Dynamic food spawning system
- ✅ Configurable obstacles and map sizes
- ✅ Room-based matchmaking system

### Multiplayer Features  
- ✅ Create/join game rooms with room codes
- ✅ Real-time game state synchronization
- ✅ Host controls for game settings
- ✅ Spectator mode for ongoing matches

### Social Features
- ✅ In-room chat while waiting
- ✅ Player statistics tracking
- ✅ Global leaderboards
- ✅ Customizable snake skins/colors

### Technical Features
- ✅ Cross-platform compatibility
- ✅ Offline-capable architecture
- ✅ Performance optimized for 60fps
- ✅ Server-side cheat prevention

## 🏗️ Technical Architecture

### Frontend
- **Framework**: Flutter (Dart)
- **Platforms**: Web, Android, iOS
- **UI**: Responsive design with platform-specific controls

### Backend & Services
- **Database**: Firebase Realtime Database (game state sync)
- **Authentication**: Firebase Auth (anonymous + Google Sign-In)

## 🔒 Security & Setup

### Firebase Credentials
This project uses Firebase but **does not commit credentials to version control**. You must set up your own Firebase project:

1. **Quick Setup**: Run `./scripts/setup-credentials.sh`
2. **Manual Setup**: See [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
3. **Verify Security**: Run `./scripts/verify-security.sh`

### Security Features
- ✅ Comprehensive Firebase security rules
- ✅ No API keys or credentials in git history
- ✅ Authentication required for all operations
- ✅ Data isolation between users and rooms
- **Game Logic**: Firebase Cloud Functions (move validation, game orchestration)
- **Hosting**: Firebase Hosting (web deployment)
- **Analytics**: Firebase Analytics

### Key Technical Decisions
- **Real-time Sync**: Firebase Realtime Database for <200ms latency
- **Cheat Prevention**: Server-side move validation
- **Scalability**: Firebase free-tier optimized architecture
- **Performance**: Batched writes and throttled updates

## 🎯 Game Rules

| Mechanic | Rule |
|----------|------|
| **Movement** | 4-directional (↑↓←→), constant speed, no backward movement |
| **Food System** | 1-5 food items spawn randomly, snake grows on consumption |
| **Win Conditions** | Last player alive OR first to reach target length |
| **Death** | Wall collision, self-collision, or hitting other snakes |
| **Respawn** | No respawn - elimination based gameplay |
| **Room Settings** | Configurable: player limit, map size, target length, obstacles |

## 📱 Platform Support

| Platform | Status | Controls |
|----------|---------|----------|
| **Web** | ✅ Supported | Arrow keys + on-screen controls |
| **Android** | ✅ Supported | Swipe gestures |
| **iOS** | ✅ Supported | Swipe gestures |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Firebase CLI
- Node.js (for Firebase Functions)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/[username]/snakes-fight.git
   cd snakes-fight
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase (follow prompts)
   firebase init
   ```

4. **Configure Firebase**
   - Create a new Firebase project
   - Enable Realtime Database, Authentication, Cloud Functions, Hosting
   - Add your Firebase config to the Flutter app

5. **Run the application**
   ```bash
   # Web
   flutter run -d web
   
   # Android/iOS
   flutter run
   ```

### Code Formatting

This project uses consistent code formatting with **80-character line length**:

```bash
# Format all files (recommended before commits)
./scripts/format.sh

# Check formatting without changes (CI mode)
./scripts/format.sh --check

# Manual formatting command
dart format --page-width=80 .
```

**IDE Configuration:**
- VS Code: Settings already configured in `.vscode/settings.json`
- Android Studio: Set right margin to 80 characters
- See [FORMATTING.md](FORMATTING.md) for detailed setup instructions

### Firebase Deployment

**Quick Setup:**
```bash
# Test Firebase deployment locally
./scripts/test-firebase-deploy.sh
```

**GitHub Secrets Required:**
- `FIREBASE_SERVICE_ACCOUNT_DEV` - Development environment service account JSON

**Setup Instructions:**
1. Go to [Firebase Console](https://console.firebase.google.com/) → Your Project → Project Settings → Service Accounts
2. Click "Generate New Private Key" and download the JSON file
3. In GitHub: Settings → Secrets and variables → Actions
4. Add secret `FIREBASE_SERVICE_ACCOUNT_DEV` with the entire JSON content

See [FIREBASE_DEPLOYMENT_SETUP.md](FIREBASE_DEPLOYMENT_SETUP.md) for detailed instructions.

### Firebase Setup Details
```bash
# Enable required Firebase services
firebase projects:list
firebase use [your-project-id]

# Deploy Cloud Functions
cd functions
npm install
firebase deploy --only functions

# Deploy to Firebase Hosting (web)
flutter build web
firebase deploy --only hosting
```

## 📊 Firebase Free Tier Usage

| Service | Free Tier Limit | Project Usage |
|---------|----------------|---------------|
| **Realtime Database** | 1GB storage, 50K reads/day | Game state sync |
| **Cloud Functions** | 2M invocations/month | Move validation, game logic |
| **Authentication** | 10K users/month | Anonymous + Google auth |
| **Hosting** | 1GB storage, 10GB transfer/month | Web app hosting |
| **Analytics** | Unlimited | Usage tracking |

## 🎮 How to Play

1. **Create or Join Room**
   - Create a new game room with custom settings
   - Join existing room using room code
   - Wait for 2-4 players to join

2. **Game Setup**
   - Host configures: map size, target length, obstacles, timeout
   - All players ready up
   - Host starts the game

3. **Gameplay**
   - Control your snake using swipes (mobile) or arrows (web)
   - Eat food to grow your snake
   - Avoid walls, your own body, and other snakes
   - Strategically block other players

4. **Victory**
   - Be the last snake alive, OR
   - Reach the target length first
   - View results and statistics

## 🛠️ Development Status

This project follows a structured development approach with detailed requirements analysis and implementation planning:

### Project Structure
```
snakes-fight/
├── .docs/              # Project documentation and analysis
│   ├── analysis/       # Business requirements analysis
│   └── requirements/   # Original requirements documents
├── .github/            # Development workflows and instructions
│   ├── instructions/   # Coding standards and best practices
│   └── prompts/        # Development phase templates
└── [Flutter project structure to be created]
```

### Current Phase
- ✅ Requirements Analysis Complete
- ✅ Technical Architecture Defined  
- 🔄 Implementation Planning (Next)
- ⏳ User Stories Generation
- ⏳ Implementation Tasks Creation
- ⏳ Development Execution

## 📄 Documentation

- [**Requirements Analysis**](.docs/analysis/multiplayer-snake-requirements-v1.md) - Detailed business requirements
- [**Original Requirements**](.docs/requirements/multiplayer_snake_game_requirements.md) - Initial project specifications
- [**Development Instructions**](.github/instructions/) - Coding standards and best practices

## 🤝 Contributing

This is currently a single-developer project following structured development practices. The project uses:

- **Atomic commits** with clear messages
- **Structured requirements** and implementation planning
- **Anti-hallucination protocols** for reliable development
- **Test-driven development** approach

## 📈 Roadmap

### Phase 1: Core Game (MVP)
- [ ] Basic snake movement and collision detection
- [ ] Food system and snake growth
- [ ] Single-player prototype

### Phase 2: Multiplayer Foundation
- [ ] Firebase integration
- [ ] Room creation and joining
- [ ] Real-time game state synchronization

### Phase 3: Enhanced Features
- [ ] Chat system and spectator mode
- [ ] Player statistics and leaderboards
- [ ] Snake customization options

### Phase 4: Polish & Optimization
- [ ] Performance optimization
- [ ] Advanced game modes
- [ ] Push notifications and social features

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Demo**: [Coming Soon]
- **Documentation**: [Project Docs](.docs/)
- **Issues**: [GitHub Issues](https://github.com/[username]/snakes-fight/issues)

---

**Built with ❤️ using Flutter & Firebase**
