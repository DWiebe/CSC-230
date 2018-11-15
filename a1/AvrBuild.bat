@ECHO OFF
"F:\Programs\AVR Studio\AvrAssembler2\avrasm2.exe" -S "H:\CSC 230\a1\labels.tmp" -fI -W+ie -C V3 -o "H:\CSC 230\a1\a1.hex" -d "H:\CSC 230\a1\a1.obj" -e "H:\CSC 230\a1\a1.eep" -m "H:\CSC 230\a1\a1.map" "H:\CSC 230\a1\modulo.asm"
