import os
import sys
import subprocess
from PIL import Image


WIDTH, HEIGHT = 128, 128
OUT_WIDTH, OUT_HEIGHT = 126, 126


PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
BUILD_DIR = os.path.join(PROJECT_ROOT, "build")
IN_HEX = os.path.join(BUILD_DIR, "input_image.hex")
OUT_HEX = os.path.join(BUILD_DIR, "output_image.hex")

FILTERS = [
    ("sobelx", "tb/sobelx_tb.v"),
    ("sobely", "tb/sobely_tb.v"),
    ("gaussianblur", "tb/gaussianblur_tb.v")
]

RTL_FILES = [
    "rtl/top.v", 
    "rtl/window_gen.v", 
    "rtl/convolution.v", 
    "rtl/linebuffer.v"
]

def image_to_hex(image_path):
    os.makedirs(BUILD_DIR, exist_ok=True)
    img = Image.open(image_path).convert('L').resize((WIDTH, HEIGHT))
    pixels = list(img.getdata())
    
    with open(IN_HEX, "w") as f:
        for p in pixels:
            f.write(f"{p:02x}\n")
    print(f"[*] Converted {image_path} to {WIDTH}x{HEIGHT} hex format.")

def run_simulation(testbench_path, sim_executable):
    compile_cmd = ["iverilog", "-g2012", "-o", sim_executable] + RTL_FILES + [testbench_path]
    
    if subprocess.run(compile_cmd).returncode != 0:
        sys.exit(f"Error: Compilation failed for {testbench_path}")
    
    if subprocess.run(["vvp", sim_executable], cwd=PROJECT_ROOT).returncode != 0:
        sys.exit(f"Error: Simulation failed for {testbench_path}")

def hex_to_image(output_image_path):
    if not os.path.exists(OUT_HEX):
        sys.exit("Error: Output hex file not found.")
        
    with open(OUT_HEX, "r") as f:
        lines = f.readlines()
        
    pixels = []
    for line in lines:
        val = line.strip()
        if not val: continue

        if 'x' in val.lower():
            pixels.append(0)
        else:
            pixels.append(int(val, 16))
    
    expected = OUT_WIDTH * OUT_HEIGHT
    if len(pixels) != expected:
        pixels = (pixels + [0] * expected)[:expected]

    img = Image.new('L', (OUT_WIDTH, OUT_HEIGHT))
    img.putdata(pixels)
    img.save(output_image_path)
    print(f"[+] Saved hardware output to {output_image_path}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python run.py <path_to_image>")
        print("Example: python run.py images/image1.png")
        sys.exit(1)

    input_img_path = sys.argv[1]
    
    if not os.path.exists(input_img_path):
        sys.exit(f"Error: File '{input_img_path}' not found.")

    image_to_hex(input_img_path)

    input_dir = os.path.dirname(input_img_path)
    output_dir = os.path.join(input_dir, "output")
    os.makedirs(output_dir, exist_ok=True)
    
    input_filename = os.path.basename(input_img_path)
    base_name, ext = os.path.splitext(input_filename)

    for filter_prefix, tb_file in FILTERS:
        print(f"\n" + "="*40)
        print(f"Running Filter: {filter_prefix.upper()}")
        print("="*40)
        
        if not os.path.exists(tb_file):
            print(f"[-] Skipping {filter_prefix}: Testbench '{tb_file}' not found.")
            continue
            
        sim_executable = os.path.join(BUILD_DIR, f"sim_{filter_prefix}.vvp")
        
        run_simulation(tb_file, sim_executable)
        
        out_name = f"{base_name}_{filter_prefix}{ext}"
        out_path = os.path.join(output_dir, out_name)
        hex_to_image(out_path)
        
    print("\nAll requested filter simulations completed successfully!")