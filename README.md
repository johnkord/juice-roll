# JuiceRoll

A Flutter iOS app that emulates the Juice Oracle dice mechanics for solo roleplaying games.

## Features

### Core Roll Engine
- **NdX Dice**: Roll any combination of standard dice (d4, d6, d8, d10, d12, d20, d100)
- **Fate Dice (dF)**: Roll Fate/Fudge dice with +, -, and blank faces
- **Advantage/Disadvantage**: Roll twice and take the higher or lower result
- **Skewed d6**: Weighted dice favoring higher or lower results
- **Modifiers**: Add or subtract from any roll

### Oracle Presets

#### Fate Check
Ask yes/no questions with varying likelihoods:
- Impossible (-4) to A Sure Thing (+4)
- Results range from "Extreme No!" to "Extreme Yes!"
- Includes "Yes, but...", "No, and..." nuanced outcomes

#### Next Scene
Determine what type of scene comes next:
- Scene types: Dramatic Twist, Complication, Delay, Expected, Advantage, Opportunity, Revelation
- Chaos level modifiers (Controlled to Chaotic)
- Rolling doubles triggers a Random Event interrupt

#### Random Event
Generate unexpected events with:
- Event Focus (PC, NPC, Current Scene, Remote Event, Plot Thread)
- Action + Subject idea generation from 100-word tables
- Quick "Idea" button for just action/subject

#### Wilderness & Dungeon
For wilderness and dungeon adventures using Juice Oracle tables:

**Wilderness Button**
- Environment selection (Temperate Forest, Mountain, etc.)
- Weather roll (1d6@Environment skew)
- Encounter check (d10 based)
- Monster generation with formula-based dice

**Dungeon Button**
- Two-phase area generation (Entrance → Next Area)
- Encounter tables (Feature, Trap, Hazard, Monster)
- Boss encounters on doubles

### User Interface
- Clean, dark-themed Material Design 3
- Roll buttons organized by category
- Scrollable roll history (last 100 rolls)
- Detailed result cards with context
- Tap history items for full details

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher

### Installation

1. Clone the repository:
```bash
git clone https://github.com/johnkord/juice-roll.git
cd juice-roll
```

2. Get dependencies:
```bash
flutter pub get
```

3. Add web platform support (if not already configured):
```bash
flutter create --platforms=web .
```

4. Run the app in web mode:
```bash
flutter run -d web-server --web-port=8080
```

5. Open your browser to `http://localhost:8080`

The app displays in a phone-sized frame (430×932px) to simulate the mobile experience.

### Building for iOS

iOS development requires a Mac with Xcode installed.

```bash
flutter build ios
```

### Building for Web

```bash
flutter build web
```

The built files will be in `build/web/`.

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/
│   ├── roll_engine.dart      # Core dice rolling logic
│   └── table_lookup.dart     # Table lookup system
├── models/
│   └── roll_result.dart      # Roll result models
├── presets/
│   ├── fate_check.dart       # Fate Check oracle
│   ├── next_scene.dart       # Next Scene oracle
│   ├── random_event.dart     # Random Event generator
│   └── wilderness.dart       # Weather, encounter & monster tables
└── ui/
    ├── home_screen.dart      # Main screen
    └── widgets/
        ├── roll_history.dart         # History list
        ├── dice_roll_dialog.dart     # Custom dice dialog
        ├── fate_check_dialog.dart    # Fate Check dialog
        └── next_scene_dialog.dart    # Next Scene dialog
```

## Running Tests

```bash
flutter test
```

## License

MIT License - See LICENSE file for details.

## Acknowledgments

Inspired by the Juice Oracle and other solo RPG oracles like Mythic GME.
