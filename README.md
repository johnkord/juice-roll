# JuiceRoll

A Flutter app that emulates the Juice Oracle dice mechanics for solo roleplaying games. Runs on iOS, web, and Linux.

## Features

### Core Roll Engine
- **NdX Dice**: Roll any combination of standard dice (d4, d6, d8, d10, d12, d20, d100)
- **Fate Dice (dF)**: Roll Fate/Fudge dice with +, -, and blank faces
- **Advantage/Disadvantage**: Roll twice and take the higher or lower result
- **Skewed d6**: Weighted dice favoring higher or lower results
- **Modifiers**: Add or subtract from any roll

### Oracle Presets (24 Total)

#### Core Oracles
- **Fate Check**: Yes/no questions with 2dF + 1d6 intensity (-4 Impossible to +4 Sure Thing)
- **Expectation Check**: Test assumptions about the world
- **Next Scene**: Determine scene types with chaos modifiers (doubles trigger Random Events)
- **Random Event**: Generate unexpected events with Focus + Action/Subject tables
- **Discover Meaning**: Two-word prompts for interpretation
- **Interrupt Plot Point**: Story interruptions and twists
- **Scale**: Determine magnitude/scope of effects

#### Character Oracles
- **NPC Action**: Determine what NPCs do based on disposition
- **Dialog Generator**: Generate NPC dialog and responses
- **Name Generator**: Generate character and place names
- **Extended NPC Conversation**: Deep dialog system for complex interactions

#### World Building Oracles
- **Settlement**: Generate towns, cities, and their features
- **Wilderness**: Environment-based exploration with weather and encounters
- **Dungeon Generator**: Two-phase area generation with entrance/next area modes
- **Location**: Grid-based location generation
- **Monster Encounter**: Formula-based monster generation by environment
- **Quest**: Generate adventure hooks and objectives
- **Treasure**: Generate loot and items

#### Challenge Oracles
- **Challenge**: Generate obstacles and difficulty ratings
- **Pay the Price**: Consequences for failure

#### Flavor Oracles
- **Details**: Generate descriptive properties (color, material, condition)
- **Immersion**: Sensory and emotional details
- **Abstract Icons**: Visual oracle prompts using abstract images

### Session Management
- **Multiple Sessions**: Create, switch, and manage separate play sessions
- **Persistent History**: Roll history saved per session (up to 200 rolls each)
- **Session Export/Import**: Copy sessions to clipboard as JSON for backup
- **Wilderness/Dungeon State**: Track exploration state across sessions

### User Interface
- Clean, dark-themed Material Design 3 with custom Juice theme
- 24 oracle buttons organized in a 4×6 grid
- Scrollable roll history with detailed result cards
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

3. Run the app:
```bash
# Web
flutter run -d web-server --web-port=8080

# iOS (requires Mac with Xcode)
flutter run -d ios

# Linux
flutter run -d linux
```

### Building

```bash
# Web
flutter build web

# iOS
flutter build ios

# Linux
flutter build linux
```

Built files will be in `build/<platform>/`.

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── core/
│   ├── roll_engine.dart           # Core dice rolling logic
│   ├── preset_registry.dart       # Lazy-loaded preset management
│   ├── table_lookup.dart          # Table lookup system
│   ├── dice_display_formatter.dart
│   └── fate_dice_formatter.dart
├── data/
│   ├── dungeon_data.dart          # Dungeon generation tables
│   ├── monster_encounter_data.dart
│   ├── npc_action_data.dart
│   ├── settlement_data.dart
│   └── wilderness_data.dart
├── models/
│   ├── roll_result.dart           # Base roll result types
│   ├── roll_result_factory.dart   # Result creation helpers
│   ├── session.dart               # Session model with export/import
│   └── results/                   # Specialized result types
│       ├── oracle_results.dart
│       ├── character_results.dart
│       ├── exploration_results.dart
│       ├── world_results.dart
│       └── ...
├── presets/                       # 24 oracle presets
│   ├── fate_check.dart
│   ├── expectation_check.dart
│   ├── next_scene.dart
│   ├── random_event.dart
│   ├── discover_meaning.dart
│   ├── npc_action.dart
│   ├── dialog_generator.dart
│   ├── name_generator.dart
│   ├── settlement.dart
│   ├── wilderness.dart
│   ├── dungeon_generator.dart
│   ├── monster_encounter.dart
│   ├── challenge.dart
│   ├── pay_the_price.dart
│   ├── details.dart
│   ├── immersion.dart
│   ├── abstract_icons.dart
│   └── ...
├── services/
│   └── session_service.dart       # Local storage persistence
└── ui/
    ├── home_screen.dart           # Main screen
    ├── home_state.dart            # State management
    ├── theme/
    │   └── juice_theme.dart       # Custom dark theme
    ├── dialogs/                   # Oracle configuration dialogs
    │   ├── dialogs.dart
    │   ├── session_dialogs.dart
    │   └── ...
    ├── widgets/
    │   ├── roll_button.dart
    │   ├── roll_history.dart
    │   ├── dice_roll_dialog.dart
    │   └── ...
    └── shared/                    # Shared UI components
```

## Running Tests

```bash
flutter test
```

## Deployment

### Azure Static Web Apps (Recommended)

The project includes Infrastructure as Code for Azure Static Web Apps:

1. **Deploy infrastructure with Azure CLI:**
   ```bash
   # Login to Azure
   az login

   # Create resource group and deploy
   ./scripts/deploy-azure.sh [resource-group] [app-name] [location]
   
   # Or manually:
   az group create --name rg-juice-roll --location eastus2
   az deployment group create \
     --resource-group rg-juice-roll \
     --template-file infra/main.bicep \
     --parameters staticWebAppName='swa-juice-roll'
   ```

2. **Configure GitHub Actions:**
   - Get the deployment token from Azure portal or CLI
   - Add it as a secret `AZURE_STATIC_WEB_APPS_API_TOKEN` in your GitHub repo
   - Push to main branch to trigger automatic deployment

See [infra/README.md](infra/README.md) for detailed instructions.

### Docker/Kubernetes

Previous Docker and Kubernetes deployment instructions have been removed.
Use Azure Static Web Apps (see above) for hosting the web build.

## License

This project is licensed under **CC BY-NC-SA 4.0** (Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International).

See the [LICENSE](LICENSE) file for details.

[![License: CC BY-NC-SA 4.0](https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

## Acknowledgments

- **[Juice Oracle](https://thunder9861.itch.io/juice-oracle)** by thunder9861 - The original oracle system that this app implements, licensed under CC BY-NC-SA 4.0
