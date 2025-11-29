# Love2D RPG Engine Prototype

A simple, data-driven RPG engine built with [LÖVE](https://love2d.org/).

## Features

-   **High Resolution**: Native 1280x720 resolution with 64x64 pixel tiles.
-   **Turn-Based Battle**: Classic JRPG style combat with Attack, Skills, Items, and Run options.
-   **Procedural Assets**: Graphics (sprites, tiles) and Audio (BGM, SFX) are generated at runtime—no external assets required.
-   **State Machine**: Clean separation of game states (Title, Map, Menu, Battle).
-   **Interaction**: NPCs with dialog systems and world interaction.

## How to Run

### Windows
1.  Ensure LÖVE is installed.
2.  Double-click `run.bat` to launch the game.
    -   *Alternatively, drag the project folder onto `love.exe`.*

## Controls

| Action | Key |
| :--- | :--- |
| **Move** | Arrow Keys |
| **Interact / Confirm** | Enter (Return) |
| **Open Menu** | Escape |
| **Cancel / Back** | Escape |

## Project Structure

-   `main.lua`: Entry point and game loop.
-   `conf.lua`: Configuration (window size, flags).
-   `src/`: Source code directory.
    -   `state/`: Game states (Title, Map, Menu, Battle).
    -   `entity/`: Game entities (Player, NPC).
    -   `system/`: Core systems (Input, Camera, Assets, Audio).
    -   `map/`: Map data files.

## Credits

Developed as a prototype for a Love2D RPG Engine.
