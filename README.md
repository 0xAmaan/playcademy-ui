# Word Warriors 🎮⚔️

A vocabulary learning game built with Godot Engine for the Playcademy platform. Word Warriors challenges players to master vocabulary through engaging, interactive activities set in a medieval-themed world.

## Overview

Word Warriors is an educational game that combines learning with gameplay. Players progress through various vocabulary challenges, earning XP and unlocking new content as they improve their language skills.

## Features

- **Multiple Activity Types**: 
  - Multiple Choice
  - Fill in the Blank
  - Spelling
  - Flashcards
  - Antonyms
  - Synonyms & Antonyms

- **Progress Tracking**: XP system to track player advancement
- **Medieval Theme**: Beautiful medieval-themed assets and UI
- **Smooth Animations**: Powered by the Anima plugin for polished transitions
- **Playcademy Integration**: Fully integrated with the Playcademy platform for seamless deployment

## Tech Stack

- **Engine**: Godot 4.5
- **Platform**: Playcademy
- **Plugins**:
  - [Playcademy SDK](addons/playcademy/) - Platform integration and backend services
  - [Anima](addons/anima/) - Animation library for smooth UI transitions

## Project Structure

```
playcademy-ui/
├── scenes/              # Game scenes (Main, Home, Summary, Activities)
├── scripts/            # Game logic and activity implementations
├── assets/             # Sprites, fonts, and game assets
├── addons/            # Godot plugins (Playcademy, Anima)
└── server/            # Custom API routes
```

## Getting Started

1. **Prerequisites**:
   - Godot Engine 4.5+
   - Node.js/npm or Bun (for Playcademy sandbox)

2. **Setup**:
   - Open the project in Godot
   - Ensure plugins are enabled in `Project > Project Settings > Plugins`
   - The Playcademy SDK is configured as an AutoLoad singleton

3. **Running Locally**:
   - Use the Playcademy sandbox plugin for local development
   - Press `F5` or `Cmd+B` to run the game

## Activities

The game includes six different activity types, each designed to test different aspects of vocabulary knowledge:

- **Multiple Choice**: Select the correct answer from options
- **Fill in the Blank**: Complete sentences with missing words
- **Spelling**: Spell words correctly
- **Flashcards**: Learn vocabulary through visual cards
- **Antonyms**: Identify opposite words
- **Synonyms & Antonyms**: Match words with their synonyms or antonyms

## Version

Current version: **0.12.0**

## License

See individual asset licenses in their respective directories.