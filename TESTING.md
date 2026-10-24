# Testing Plan — Behind the Smile

## Test Environment

- **Engine:** Godot 4.x
- **Platform:** Windows PC
- **Resolution:** 1280 × 720

> **Note:** Godot is not currently available in the development environment.
> All tests below describe the expected behaviour and must be verified
> manually when the project is opened in Godot.

---

## Test Results Summary

| # | Test | Status |
|---|------|--------|
| 1 | Support Path | ⏳ Awaiting manual verification |
| 2 | Ignore Path | ⏳ Awaiting manual verification |
| 3 | Seek-Help Path | ⏳ Awaiting manual verification |
| 4 | Restart Clears State | ⏳ Awaiting manual verification |
| 5 | Memory Log Display | ⏳ Awaiting manual verification |
| 6 | Invalid/Missing State | ✅ Code review verified |
| 7 | Rapid Input Protection | ✅ Code review verified |
| 8 | Performance & Stability | ⏳ Awaiting manual verification |

---

## Detailed Test Cases

### TEST 1: Support Path

**Steps:**
1. Launch the game and click **Play**.
2. Read through the introduction (click Continue twice).
3. Select **"Approach Maya and offer support"**.
4. Observe the response scene showing you sitting with Maya.
5. Continue to the next day scene.
6. **Verify:** Maya says she remembers you coming to sit with her.
7. **Verify:** Maya does NOT claim you ignored her or sought help.
8. Select **"Ask Maya how she's feeling"**.
9. Observe Maya opening up about her feelings.
10. Continue to the ending.
11. **Verify:** Ending is "A Friend in Need" (supportive).
12. **Verify:** Ending mentions offering support AND asking how she felt.
13. **Verify:** Ending does NOT mention actions you didn't take.

**Expected Result:** Maya's dialogue consistently acknowledges the supportive actions. The ending accurately reflects the choices made.

**Actual Result:** ⏳ Awaiting verification.

---

### TEST 2: Ignore Path

**Steps:**
1. Restart the game (click Play Again or return to Main Menu → Play).
2. Read through the introduction.
3. Select **"Keep walking and don't get involved"**.
4. Observe the response showing you walking away.
5. Continue to the next day.
6. **Verify:** Maya says she noticed you were there but didn't come over.
7. **Verify:** Maya does NOT claim you offered support or reported anything.
8. **Verify:** Maya's tone is reserved but not hostile.
9. Select a second choice.
10. Continue to the ending.
11. **Verify:** Ending is "The Distance Between Us" (distant).
12. **Verify:** Ending mentions choosing not to approach.

**Expected Result:** Maya accurately remembers that the player did not interact. No invented positive or negative events.

**Actual Result:** ⏳ Awaiting verification.

---

### TEST 3: Seek-Help Path

**Steps:**
1. Restart the game.
2. Select **"Find a trusted teacher and report the bullying"**.
3. **Verify:** Scene shows you talking to Ms. Chen.
4. Continue to the next day.
5. **Verify:** Maya acknowledges that you went to talk to a teacher.
6. **Verify:** Maya's response reflects uncertainty but appreciation.
7. Select **"Offer to go with her to talk to a teacher"**.
8. Continue to the ending.
9. **Verify:** Ending is "Seeking Help" (help_seeking).
10. **Verify:** Ending mentions reporting AND offering to accompany.

**Expected Result:** Both help-seeking actions are recorded and reflected in the ending.

**Actual Result:** ⏳ Awaiting verification.

---

### TEST 4: Restart Clears State

**Steps:**
1. Complete any playthrough.
2. Open the Memory Log at the ending — note the recorded interactions.
3. Click **Play Again**.
4. Open the Memory Log immediately.
5. **Verify:** Interaction history is empty.
6. **Verify:** Trust is 0, support_count is 0, help_sought is false.
7. **Verify:** World facts are still present (they are always true).
8. Play through with a DIFFERENT choice than the previous game.
9. **Verify:** Maya's dialogue reflects the NEW choice, not the old one.

**Expected Result:** All player-dependent state is fully reset. World facts remain unchanged.

**Actual Result:** ⏳ Awaiting verification.

**Code Review Notes:** `reset_memory()` clears `interaction_history`, resets `trust` to 0, `support_count` to 0, `help_sought` to false, and `_choice_lock` to false. World facts dictionary is not modified. ✅ Verified by code inspection.

---

### TEST 5: Memory Log Display

**Steps:**
1. Start a new game.
2. Press **M** or click the Memory Log button.
3. **Verify:** Established world facts are shown (Maya attends school, was bullied, etc.).
4. **Verify:** Interactions section shows "(No interactions recorded yet)".
5. **Verify:** Trust is 0, support_count is 0, help_sought is No.
6. Close the Memory Log.
7. **Verify:** Gameplay resumes normally.
8. Make a choice (e.g., offer support).
9. Open the Memory Log again.
10. **Verify:** The new interaction appears.
11. **Verify:** Trust and support values have updated.
12. **Verify:** No phantom interactions are shown.

**Expected Result:** Memory Log accurately reflects current state at all times.

**Actual Result:** ⏳ Awaiting verification.

---

### TEST 6: Invalid or Missing State

**Verification Method:** Code review (deterministic logic can be verified statically).

**Checks:**
- [x] `get_first_interaction()` returns `""` if no interactions recorded → handled by `_` fallback in match statements.
- [x] `get_last_interaction()` returns `""` if empty → handled by `_` fallback.
- [x] `get_valid_dialogue()` with unknown scene_id → returns generic fallback `{"speaker": "", "text": "...", "choices": []}`.
- [x] `record_interaction()` with unknown action_id → logs warning, does not crash. Trust/count unchanged.
- [x] `select_ending()` with no interactions → returns `"distant"` (fallback).
- [x] `get_memory_log_data()` with unknown action_id → displays "Unknown action: {id}".

**Result:** ✅ All edge cases handled by fallback logic. No crashes possible from missing state.

---

### TEST 7: Rapid Input Protection

**Verification Method:** Code review + manual testing needed.

**Mechanism:**
1. `_choice_lock` in `memory_manager.gd` — set to `true` when an interaction is recorded, reset after 0.3 seconds. Any call to `record_interaction()` while locked is ignored.
2. `_transitioning` flag in `game.gd` — prevents `_on_choice_selected()` and `_on_continue()` from processing while a transition is in progress.
3. Duplicate check in `record_interaction()` — even without the lock, the same action_id is not appended if it's already the last item in the history.

**Expected Result:** Rapidly clicking a choice button records it exactly once.

**Code Review Result:** ✅ Triple protection against double-registration is implemented.

**Manual Test Result:** ⏳ Awaiting verification.

---

### TEST 8: Performance and Stability

**Checks:**
- [ ] No script errors on launch.
- [ ] No invalid resource paths (all `.tscn` and `.gd` files exist and are referenced correctly).
- [ ] Scene transitions work without errors.
- [ ] No broken signal connections.
- [ ] Game remains responsive throughout a full playthrough.
- [ ] Memory Log opens and closes without lag.
- [ ] No heavy processing or resource loading during gameplay.

**Result:** ⏳ Awaiting manual verification in Godot.

**Code Review Notes:**
- All referenced scripts exist: `main_menu.gd`, `game.gd`, `memory_manager.gd`.
- All referenced scenes exist: `main_menu.tscn`, `game.tscn`.
- All node paths in `@onready` vars match the `.tscn` node tree.
- No external assets are required (no images, fonts, or audio files to fail loading).
- Theme resource exists at `assets/game_theme.tres`.
- Autoload registration in `project.godot` is correct.

---

## Limitations

1. **No automated testing framework** — tests require manual verification in Godot.
2. **Godot unavailable in dev environment** — runtime testing not possible during initial development.
3. **No unit tests** — the memory manager functions are testable but no GDScript testing framework is integrated.

## Recommendations for Team

1. Open the project in Godot 4.x and run each test case above.
2. Mark each test as ✅ Passed or ❌ Failed.
3. For any failures, note the actual result and fix the issue.
4. Re-run all tests after any fix.
5. Record a video of successful test runs for the competition submission.
