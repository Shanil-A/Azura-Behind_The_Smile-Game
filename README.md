# Behind the Smile

> *"Sometimes, the smallest choices make the biggest difference."*

**Team:** Gamesmith  
**Genre:** Narrative Adventure / Interactive Visual Novel  
**Platform:** Windows PC (Desktop)  
**Engine:** Godot 4.x (GDScript)  
**Competition Problem:** Problem 09 — NPC Memory Without Invented Lore

---

## 🎮 Game Concept

**Behind the Smile** is a short narrative adventure that explores themes of bullying, empathy, and the power of small choices. You play as a student who witnesses a classmate, Maya, being bullied at school. Your choices determine how Maya remembers you and how the story ends.

The game demonstrates **Problem 09 — NPC Memory Without Invented Lore**: NPCs remember meaningful player interactions without contradicting established characters or world facts. Maya will never claim something happened that didn't — her responses are selected deterministically based on your actual recorded choices.

---

## 📖 Gameplay Instructions

1. **Read** the story as it unfolds on screen.
2. **Choose** your actions when choice buttons appear.
3. **Observe** how Maya's dialogue changes based on what you actually did.
4. **Check** the Memory Log to see what the game recorded.
5. **Replay** to see different paths and endings.

### Playtime
Approximately 3–7 minutes per playthrough.

### Story Paths
- **Support Path:** Approach Maya and offer comfort.
- **Ignore Path:** Walk away and avoid involvement.
- **Help-Seeking Path:** Report the bullying to a trusted teacher.

Each path leads to different dialogue and one of **three endings**.

---

## 🕹️ Controls

| Control | Action |
|---------|--------|
| **Mouse Click** | Select choices, advance dialogue |
| **M Key** | Toggle Memory Log overlay |

---

## 💻 Technology

- **Engine:** Godot 4.x
- **Language:** GDScript
- **Renderer:** GL Compatibility (broad hardware support)
- **Dependencies:** None — fully offline, self-contained
- **Resolution:** 1280 × 720, canvas_items stretch mode

---

## 📁 Project Structure

```
BehindTheSmile/
├── project.godot              # Godot project configuration
├── icon.svg                   # Application icon
├── assets/
│   └── game_theme.tres        # Global UI theme resource
├── scenes/
│   ├── main_menu.tscn         # Main menu scene
│   └── game.tscn              # Main gameplay scene
├── scripts/
│   ├── main_menu.gd           # Main menu controller
│   ├── game.gd                # Game flow controller
│   └── memory_manager.gd      # NPC Memory System (autoload)
├── README.md                  # This file
├── ARCHITECTURE.md            # Technical architecture doc
├── TESTING.md                 # Test plan and results
└── DEMO_SCRIPT.md             # Competition demo recording plan
```

---

## 🏗️ Architecture Overview

```
PLAYER CHOICE
     ↓
INTERACTION HANDLER (game.gd)
     ↓
MEMORY MANAGER (memory_manager.gd — autoload singleton)
     ↓
RECORDED INTERACTION + RELATIONSHIP STATE
     ↓
STORY CONDITION CHECKS
     ↓
VALID DIALOGUE SELECTION
     ↓
NPC RESPONSE (Maya's dialogue)
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for full details.

---

## 🧠 NPC Memory System

The memory system is the **core competition feature**. It stores three distinct categories of data:

### A. Established World Facts
Immutable facts about the story world:
- Maya attends Westridge High
- Maya was bullied earlier today
- The player witnessed the bullying
- Maya was sitting alone in the courtyard

These **never change** during gameplay.

### B. Player Interaction Memories
An ordered list of player actions, recorded only when the player makes a choice:
- `offered_support` — sat with Maya
- `ignored_maya` — walked away
- `sought_help` — reported to a teacher
- `asked_feeling` — asked how she's doing
- `offered_accompany` — offered to go to a teacher with her
- `gave_space` — respectful distance

### C. Relationship State
Numerical values derived from (but stored separately from) interactions:
- `trust` — overall trust level (can go negative)
- `support_count` — number of supportive actions
- `help_sought` — whether adult help was requested

### How It Prevents Invented Memories

1. **Dialogue selection uses `match` statements** on actual recorded interactions.
2. **Maya never references actions that weren't recorded** in `interaction_history`.
3. **World facts are read-only** — they cannot be modified by player choices.
4. **Fallback dialogue** exists for unexpected states but never invents events.
5. **Endings are built from actual recorded interactions**, listing only what happened.

This is a **deterministic, rule-based system** — not an AI model. The same inputs always produce the same outputs.

---

## 🚀 How to Run

### In Godot Editor
1. Install [Godot 4.x](https://godotengine.org/download) (standard or .NET version).
2. Open Godot and click **Import**.
3. Navigate to the project folder and select `project.godot`.
4. Click **Import & Edit**.
5. Press **F5** (or the Play button ▶) to run.

### Exported Windows Build
If an exported build is provided, simply run `BehindTheSmile.exe`.

---

## 📦 How to Export (Windows Build)

1. In Godot, go to **Project → Export**.
2. Click **Add…** and select **Windows Desktop**.
3. Download export templates if prompted.
4. Set the export path (e.g., `build/BehindTheSmile.exe`).
5. Click **Export Project**.
6. The resulting `.exe` and `.pck` files are the complete game.

---

## ⚠️ Known Limitations

1. **No audio** — sound effects and music are not included in this prototype.
2. **Simplified visuals** — backgrounds use ColorRect shapes rather than illustrated artwork.
3. **Single NPC** — only Maya has a memory system; a full game would extend this to other characters.
4. **Short story** — the prototype covers one day of the story; a full version would span multiple days.
5. **No save/load** — playthroughs are short enough that saving is unnecessary.
6. **Emoji characters** — character portraits use emoji rather than illustrated art.

---

## 🧪 Testing Summary

See [TESTING.md](TESTING.md) for detailed test cases, expected results, and actual results.

Key test scenarios:
- ✅ Support path playthrough
- ✅ Ignore path playthrough
- ✅ Help-seeking path playthrough
- ✅ Restart clears all state
- ✅ Memory Log displays only actual interactions
- ✅ Rapid click protection
- ✅ Invalid state fallback handling

---

## 📄 License

This project was created for educational/competition purposes by **Team Gamesmith**.
