# Bin Packing Problem Solver in MIPS Assembly

## 📌 Project Overview
This project implements a **Bin Packing Solver** in MIPS assembly language. It uses two heuristics to pack items of varying sizes (0.0–1.0) into the minimum number of unit-capacity bins (capacity = 1.0):
1. **First Fit (FF)**: Packs items into the first bin with available space.  
2. **Best Fit (BF)**: Packs items into the fullest bin that can accommodate them.  

---

## 🛠 Features
- **Input/Output**:  
  - Reads item sizes from a user-specified text file.  
  - Writes results (bin count + item distribution) to an output file.  
- **User Interface**:  
  - Interactive menu with heuristic selection (`FF`/`BF`).  
  - Case-insensitive input handling.  
  - Loop until user exits (`q`/`Q`).  
- **Error Handling**:  
  - Validates file existence and content (e.g., checks for invalid sizes).  

---

## 📂 Files
- `archProject.asm`: Main MIPS assembly program.  
- `input.txt`: Sample input file (one item size per line, e.g., `0.5`).  
- `output.txt`: Generated results file.

---

## 🚀 How to Run
- **Assemble & Execute**  -> Using MARS Simulator
