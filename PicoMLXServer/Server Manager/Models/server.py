import sys
from mlxserver import MLXServer

# Default model name
default_model = "mlx-community/Nous-Hermes-2-Mistral-7B-DPO-4bit-MLX"

# Default port
default_port = 5000

# Set default values for model and port
model_name = default_model
port = default_port

# Check if command-line arguments are provided
if len(sys.argv) > 1:
    for arg in sys.argv[1:]:
        if arg.startswith("model="):
            _, model_name = arg.split("=", 1)
        elif arg.startswith("port="):
            _, port = arg.split("=", 1)
        else:
            print("Invalid argument. Please use the format 'model=model_name' or 'port=port_number'.")

# Initialize the MLXServer with the specified or default model and port
server = MLXServer(model=model_name, port=int(port))
