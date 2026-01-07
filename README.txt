Link to doc in google drive: https://docs.google.com/document/d/1Zml8joktNj2xHLqcGqJJOOTZdJE6ZOncRXUQ7DpZjXY/edit?tab=t.0

Imposter Syndrome Grid Game (Processing ↔ Max ↔ Python/Sensor)
Processing overview
-Receives player position over OSC: /position
-Draws the game (Rounds 1–3)
-Sends grid state to Max over OSC: /cells
-Can reset sensor on python side + processing side with r/. Resets player coordinates to 0,0. 

Quick start (no hardware)
Run gridGameFall B.pde in Processing.
Keys:
-W/A/S/D: move player (debug)
-B: bell hit (success)
-N: next round
-R: recalibrate + send /cells once

Note: if the sensor pipeline is running, it will overwrite keyboard movement.
Max sanity check
In Max, verify:
indices 0..24
exactly 25 cells worth of data
isHere flips when moving with WASD

OSC ports + addresses
Sensor/Python → Processing (receive)
Processing listens: 6800
Address: /position
Typetag: ff
Args: (x_mm, y_mm) floats

Processing → Max (send)
Sends to: 127.0.0.1:8100
Address: /cells
Payload: DO NOT CHANGE (see below)

Processing → Python (reset)
Sends to: 127.0.0.1:6801
Address: /reset
Used at calibration / start-of-round

DO NOT BREAK MAX (important)
Max assumes /cells is a fixed logical 5×5 grid.
Requirements:
Must represent 25 cells
Must send exactly 5 values per cell
Must be row-major order
Must use index = row * 5 + col (0..24)
Per-cell payload (5 ints), in this exact order:
1.index
2.col
3.row
4.isHere (0/1)
5.isGlitching (0/1)

Rounds (minimal)
Rounds 1–2: normal 5×5 Grid.display()
Round 3: HopscotchView.display() draws hopscotch, but logical grid + OSC output stay 5×5

Scoring model (summary)
Metrics:
Success: increments only on bell hits (B)

Confidence: derived from Beta belief + playfulness/bias

Core state in ScoreTracker:
successPoints (int)
a, b (floats)
r in [0,1]
i in [0,1]

Events:
Off-grid entry → r up, i down
Bell hit → success + success evidence
Missed bell opportunity → failure evidence

Calibration / sensor notes
Sensor sends mm → Processing converts to meters → divides by tileLength
tileLength assumed same in x/y
Each round start sets needsCalibration = true, which:
sends /reset to Python
forces user position to (0,0)

Round 3 mapping:
custom mapping from continuous posX → 5×5 column index matching hopscotch layout
