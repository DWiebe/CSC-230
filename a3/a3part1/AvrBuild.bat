@ECHO OFF
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "E:\CSC 230\a3\a3part1\labels.tmp" -fI -W+ie -C V3 -o "E:\CSC 230\a3\a3part1\a3part1.hex" -d "E:\CSC 230\a3\a3part1\a3part1.obj" -e "E:\CSC 230\a3\a3part1\a3part1.eep" -m "E:\CSC 230\a3\a3part1\a3part1.map" "E:\CSC 230\a3\a3part1\a3part1.asm"
