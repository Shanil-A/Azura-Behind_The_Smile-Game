# Demo Recording Script — Behind the Smile

## Purpose

This script guides the team through recording a competition demo video that demonstrates Problem 09 (NPC Memory Without Invented Lore) in action.

**Target Length:** 4–6 minutes

---

## Pre-Recording Checklist

- [ ] Godot 4.x installed and project loads without errors.
- [ ] Game runs at 1280 × 720.
- [ ] Screen recording software ready (OBS, Game Bar, or similar).
- [ ] Microphone ready (if doing voiceover).
- [ ] All test paths verified before recording.

---

## Recording Plan

### SEGMENT 1: Introduction (30 seconds)

**Show:** Main menu screen

**Say/Caption:**
> "This is *Behind the Smile*, a narrative adventure by Team Gamesmith.
> We're demonstrating Problem 09 — NPC Memory Without Invented Lore.
> In this game, Maya — our NPC — remembers exactly what you do.
> She never makes up events that didn't happen."

### SEGMENT 2: Architecture Overview (30 seconds)

**Show:** ARCHITECTURE.md or a slide with the architecture diagram

**Say/Caption:**
> "Our architecture separates three types of data:
> 1. Established world facts — always true.
> 2. Player interaction memories — recorded when you make choices.
> 3. Relationship values — derived from your actions.
>
> Dialogue is selected deterministically using only recorded interactions."

### SEGMENT 3: Playthrough 1 — Support Path (90 seconds)

**Show:** Full gameplay

1. Click **Play**.
2. Read introduction (Continue through narration).
3. **Choose:** "Approach Maya and offer support."
4. Read the response scene.
5. Continue to the next day.
6. **Pause and highlight:** Maya's dialogue acknowledges you sat with her.
7. **Open Memory Log (press M):**
   - Point out "Offered Maya support and company" in recorded interactions.
   - Point out trust level.
8. **Close Memory Log.**
9. **Choose:** "Ask Maya how she's feeling."
10. Read Maya's response.
11. Continue to the ending.
12. **Pause and highlight:** Ending mentions both actions (support + asking).

**Say/Caption:**
> "Notice how Maya specifically remembers that we sat with her.
> The ending only describes actions we actually took.
> Nothing was invented."

### SEGMENT 4: Playthrough 2 — Ignore Path (90 seconds)

**Show:** Full gameplay

1. Click **Play Again**.
2. Speed through introduction.
3. **Choose:** "Keep walking and don't get involved."
4. Read the response.
5. Continue to the next day.
6. **Pause and highlight:** Maya says she noticed you but you didn't come over.
7. **Open Memory Log:**
   - Point out the DIFFERENT recorded interaction.
   - Point out trust is now negative.
8. **Choose:** "Give her some space."
9. Continue to the ending.
10. **Pause and highlight:** Ending is completely different — "The Distance Between Us."

**Say/Caption:**
> "Same game, different choice. Maya's memory changed because
> our recorded interaction changed. She didn't claim we were supportive
> because we weren't. The Memory Log proves exactly what was recorded."

### SEGMENT 5: Key Comparison (30 seconds)

**Say/Caption:**
> "In Playthrough 1, Maya said: 'I remember you came and sat with me.'
> In Playthrough 2, Maya said: 'You didn't come over.'
>
> Both statements are accurate. Neither contradicts what happened.
> This is NPC Memory Without Invented Lore in action."

### SEGMENT 6: Technical Demonstration (30 seconds)

**Show:** Open `memory_manager.gd` briefly in the Godot editor

**Say/Caption:**
> "The memory system uses simple GDScript:
> - A dictionary for world facts.
> - An array for interaction history.
> - Match statements to select valid dialogue.
> No AI model, no internet connection, no database."

### SEGMENT 7: Closing (20 seconds)

**Show:** Main menu or ending screen

**Say/Caption:**
> "Behind the Smile — by Team Gamesmith.
> Problem 09: NPC Memory Without Invented Lore.
> A deterministic, rule-based system that ensures NPCs
> only remember what actually happened."

---

## Alternative: Third Playthrough (Help-Seeking Path)

If time permits, add a third playthrough showing:

1. Choose "Find a trusted teacher."
2. Maya acknowledges the teacher was told.
3. Ending focuses on "Seeking Help."

This demonstrates all three main paths and three distinct endings.

---

## Tips for Recording

1. **Speak slowly and clearly** during voiceover.
2. **Pause on key moments** — especially Maya's dialogue responses and the Memory Log.
3. **Use cursor highlighting** to draw attention to specific UI elements.
4. **Don't rush** — judges need to read the dialogue.
5. **Compare the two playthroughs explicitly** — this is the strongest proof of the memory system.
