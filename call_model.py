import subprocess
import sys
import os

# Check if the correct number of arguments is passed
if len(sys.argv) < 2:
    print("Usage: python <scriptname>.py <english_directive>")
    sys.exit(1)

# Extract the English directive from command line arguments
english_directive = sys.argv[1]

# Prepare the system prompt for the LLM
system_prompt = f"""
You are an assistant trained to translate English directives into PowerShell commands. Given the directive: "{english_directive}", output only the PowerShell command(s) necessary to accomplish the task. Do not provide any additional explanations. Start every line of PowerShell command(s) with a `PS`.
"""

# Format the input text for the LLM
formatted_input_text = f"<s>[INST] {system_prompt} [/INST]"

# Get the absolute path to the directory containing the script
script_dir = os.path.dirname(os.path.abspath(__file__))

# Construct the path to the 'output' directory, one level deeper from this script's location
output_dir = os.path.join(script_dir, 'output')
os.makedirs(output_dir, exist_ok=True)

# Define paths and parameters for running the script
run_script_path = os.path.join(os.getenv('TENSORRT_LLM_DIR', 'default_path_if_not_set'), "examples", "run.py")
engine_dir = os.getenv('TRT_ENGINE_DIR', 'default_path_if_not_set')
tokenizer_dir = os.getenv('LLAMA_MODEL_DIR', 'default_path_if_not_set')
max_output_len = 500
max_input_len = 32768

# Construct the command to run the script with necessary parameters
command = [
    "python", run_script_path,
    "--engine_dir", engine_dir,
    "--tokenizer_dir", tokenizer_dir,
    "--input_text", formatted_input_text,
    "--max_output_len", str(max_output_len),
    "--max_input_length", str(max_input_len)
]

# Run the script and capture the output
process = subprocess.run(command, capture_output=True, text=True)
output = process.stdout

# Filter the output and prepare it for both file and terminal output
output_lines = output.split('\n')
cleaned_output = ' ; '.join([line[3:] for line in output_lines if line.startswith("PS")]).rstrip(' "')

# Write the cleaned output to a file
output_file_path = os.path.join(output_dir, 'output.txt')
with open(output_file_path, 'w') as file:
    file.write(cleaned_output)

print("PowerShell command(s): " + cleaned_output)
