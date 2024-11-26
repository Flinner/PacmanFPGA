from PIL import Image, ImageFont, ImageDraw  # Import ImageDraw here
import string

# Function to convert character to binary format
def char_to_bin(char, font, size=16):
    # Create an image with the given font and size
    img = Image.new('1', (size, size), 1)  # '1' means 1-bit pixels (black and white)
    draw = ImageDraw.Draw(img)
    draw.text((0, 0), char, font=font, fill=0)  # 0 for black text
    
    # Get pixel data
    pixels = list(img.getdata())
    # Convert pixels to a binary string
    bin_str = ''.join(['1' if pixel == 0 else '0' for pixel in pixels])  # 0 means black (font)
    # Group the bits into rows of 8 bits (assuming a 16x16 image)
    return [bin_str[i:i+64] for i in range(0, len(bin_str), 64)]

# Function to generate Verilog code from TTF font
def generate_verilog(font_path, size=8):
    font = ImageFont.truetype(font_path, size)
    
    # Verilog header
    verilog_code = """
      `timescale 1ns / 1ps

        module font (
        input logic [7:0] char,
        input logic [2:0] sy,
        output logic pixel
    );
    
    logic [63:0] row_data;

    always_comb begin
    case(char) // determinet the rows"""
    
    # Iterate over all printable characters
    for char in string.printable:
        bin_data = char_to_bin(char, font, size)
        verilog_code += f"\n        // Character: {repr(char)}"
        for row, binary in enumerate(bin_data):
            # Split binary data into 6 parts (as per your example)
            formatted_data = '_'.join([binary[i:i+8] for i in range(0, len(binary), 8)])
            verilog_code += f"\n        32'd{ord(char)}: row_data = 8'b{formatted_data};"
    
    # Verilog footer
    verilog_code += """
        default: row_data = 8'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
    endcase
    end

    assign pixel = row_data[sy*8+sx];

    endmodule
    """
    
    return verilog_code

# Example usage
font_path = 'assets/PixelOperatorMono8.ttf'  # Path to your TTF font file
verilog_code = generate_verilog(font_path)
print(verilog_code)

