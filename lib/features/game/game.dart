/// Game feature module
///
/// This module handles:
/// - Game logic and state management
/// - Snake movement and collision detection
/// - Game rendering and UI
/// - Real-time game synchronization
library game;

// Models
export 'models/direction.dart';
export 'models/food.dart';
export 'models/snake.dart';

// Logic
export 'logic/consumption_system.dart';
export 'logic/food_spawner.dart';
export 'logic/growth_system.dart';
export 'logic/movement_system.dart';

// Controllers
export 'controllers/game_controller.dart';
export 'controllers/input_controller.dart';

// Rendering
export 'rendering/food_renderer.dart';
export 'rendering/grid_renderer.dart';
export 'rendering/snake_renderer.dart';

// Widgets
export 'widgets/game_canvas.dart';
export 'widgets/responsive_game_container.dart';

// Future exports (to be implemented)
// export 'presentation/game_screen.dart';
// export 'data/game_repository.dart';
// export 'domain/game_service.dart';
