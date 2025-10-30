# MD-SEQ
Generative performance sequencer for Elektron Machinedrum and Norns.

MD-SEQ is a generative sequencer built for Norns + Grid, designed to explore evolving rhythmic structures and real-time pattern mutation on the Elektron Machinedrum. It combines hands-on randomness controls, pattern saving, and live performance tools — all in a minimal, responsive interface.

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
git clone https://github.com/browncreativenz/MD-SEQ.git

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

## 📘 User Guide
A detailed PDF user guide is available here:  
[View or download MD-SEQ User Guide (PDF)]([https://github.com/browncreativenz/MD-SEQ/blob/main/lib/MDSEQ-guide.pdf])

---

## 🧾 License

MIT License

© 2025 Scott Brown (@browncreativenz)
