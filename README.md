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

#### Exploration
For wilderness and dungeon adventures:

**Weather**
- Season modifiers (Spring, Summer, Autumn, Winter)
- Climate modifiers (Arctic, Temperate, Tropical, Desert)
- Results from Extreme to Perfect conditions

**Encounters**
- Wilderness and Dungeon encounter tables
- Danger level adjustment
- Encounter types: Threats, Obstacles, Clues, Discoveries, Treasures, etc.
- Distance and disposition rolls for creature encounters

### User Interface
- Clean, dark-themed Material Design 3
- Roll buttons organized by category
- Scrollable roll history (last 100 rolls)
- Detailed result cards with context
- Tap history items for full details

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Xcode (for iOS development)

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

3. Run the app:
```bash
flutter run
```

### Building for iOS

```bash
flutter build ios
```

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
│   └── exploration.dart      # Weather & encounter tables
└── ui/
    ├── home_screen.dart      # Main screen
    └── widgets/
        ├── roll_history.dart         # History list
        ├── dice_roll_dialog.dart     # Custom dice dialog
        ├── fate_check_dialog.dart    # Fate Check dialog
        ├── next_scene_dialog.dart    # Next Scene dialog
        └── exploration_dialog.dart   # Exploration dialog
```

## Running Tests

```bash
flutter test
```

## License

MIT License - See LICENSE file for details.

## Acknowledgments

Inspired by the Juice Oracle and other solo RPG oracles like Mythic GME.
