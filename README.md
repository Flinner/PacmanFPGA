
![Pacman Game Image](https://ammar.engineer/posts/2024/12/04/pacman-on-an-fpga-in-systemverilog/images/pacman_game.png)

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
4. Navigate to cloned repo, Run `Pacman.tcl`
5. Write Bitstream

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
