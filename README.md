# Simulation
To Run VGA simulator (VERY SLOW, around 0.3 frames/second!):

```bash
cmake -B build -G Ninja 
ninja -C build

# Run it
./build/Vour
```

# Synthesis
To generate bitstream:

1. Launch Vivado (Yikes!)
2. Select Tools Menu
3. Run TCL Scripts
4. Run `Pacman.tcl`

# Scripts
## Generate `font.sv` from `.ttf`:

```bash
python scripts/ttf_to_sv.py > rtl/ip/font.sv
```

## Generate `.mem` for audio.wav:
```bash
# It will overwite the .mem files
python scripts/convert_wav_to_mem.py 
```

# Format All code:
```bash
find . -name "*.sv" -exec verible-verilog-format --inplace {} \;
```
