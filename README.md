# MD-SEQ
A generative step sequencer for Elektron Machinedrum + Norns + Grid

MD-SEQ is a generative step sequencer for Norns that lets you create evolving, performance-ready rhythms for the Elektron Machinedrum using the Grid controller.  
It combines structured patterns with real-time randomness, global swing, and pattern storage.

---

## 🎛 Features
- 16-track step sequencer with random trigger variation per track  
- 4 save slots for recalling and performing with patterns  
- Global swing control  
- Clock-synced start for tight integration with other gear  

---

## 🧠 Requirements
- Norns (latest OS)
- Grid (optional, but highly recommended)
- Elektron Machinedrum (via MIDI out)

---

## ⚙️ Installation
Clone or download into your Norns `dust/code/` directory:

cd ~/dust/code
git clone https://github.com/YOURNAME/MD-SEQ.git

---

## 🕹 Controls

GRID SCREEN

- K2: Randomize the current pattern
- K3: Reset randomness values
- E2: Select track (1–16)
- E3: Adjust randomness value for selected track (0–10)

Grid (optional):

- Random +/– per track (rows 3 & 4)
- Pattern randomize/reset (row 5)
- Save/recall slots (row 6)
- Start/stop (row 7)
- Swing control (row 7 col 16 = increase, row 8 col 16 = decrease)

SAVE SCREEN

- K2: Save pattern to the selected slot
- K3: Recall the selected slot
- E2: Select save slot (1–4)

---

## 🧾 License

MIT License

© 2025 Scott Brown (@browncreativenz)
