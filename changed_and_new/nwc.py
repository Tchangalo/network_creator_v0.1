import tkinter as tk
from tkinter import messagebox
from ttkthemes import ThemedTk
from tkinter import ttk
import subprocess
import json
import os

CONFIG_DIR = "/home/user/streams"
CONFIG_FILE = os.path.join(CONFIG_DIR, "config.json")
PROVIDER_CONFIG_FILE = os.path.join(CONFIG_DIR, "provider_config.json")
PROVIDER_TURBO_CONFIG_FILE = os.path.join(CONFIG_DIR, "provider_turbo_config.json")
SINGLE_ROUTER_CONFIG_FILE = os.path.join(CONFIG_DIR, "single_router_config.json")
SCRIPT_DIR = "/home/user/streams/ks/"
IMAGE_PATH = "/home/user/streams/mplan.png"

def ensure_config_dir_exists():
    if not os.path.exists(CONFIG_DIR):
        os.makedirs(CONFIG_DIR)

def load_config(file_path):
    if (file_path is not None) and os.path.exists(file_path):
        with open(file_path, 'r') as file:
            return json.load(file)
    return {}

def save_config(config, file_path):
    with open(file_path, 'w') as file:
        json.dump(config, file)

def call_script(script_name, *args):
    command = f"bash {SCRIPT_DIR}{script_name} {' '.join(map(str, args))}"
    
    try:
        subprocess.run(command, shell=True, check=True)
        messagebox.showinfo("Success", f"Script {script_name} executed successfully!")
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", f"Script execution failed: {e}")

def on_run_button(script_name, config_file, *entries):
    args = [entry.get() for entry in entries]
    
    # Save the config
    config = {
        script_name: args
    }
    save_config({**load_config(config_file), **config}, config_file)

    # Run the script
    call_script(script_name, *args)

def create_menu(window):
    menubar = tk.Menu(window)

    # Apply bold font only to the "Create" label in the menubar
    bold_font = ("TkDefaultFont", 10, "bold")
    
    # Normal font for the dropdown items
    normal_font = ("TkDefaultFont", 10, "normal")
    
    run_menu = tk.Menu(menubar, tearoff=0, font=normal_font)
    run_menu.add_command(label="Provider", command=lambda: show_window(provider_window))
    run_menu.add_command(label="Provider Turbo", command=lambda: show_window(provider_turbo_window))
    run_menu.add_command(label="Single Router", command=lambda: show_window(single_router_window))
    run_menu.add_command(label="General", command=lambda: show_window(general_window))
    
    # Apply the bold font to the menubar "Create" label
    menubar.add_cascade(label="Create", menu=run_menu, font=bold_font)
    
    window.config(menu=menubar)

def show_window(window):
    window.deiconify()
    for other_window in (provider_window, general_window, provider_turbo_window, single_router_window):
        if other_window != window:
            other_window.withdraw()

# Ensure the configuration directory exists
ensure_config_dir_exists()

# Load the previous configurations if they exist
config = load_config(CONFIG_FILE)
provider_config = load_config(PROVIDER_CONFIG_FILE)
provider_turbo_config = load_config(PROVIDER_TURBO_CONFIG_FILE)
single_router_config = load_config(SINGLE_ROUTER_CONFIG_FILE)

# Create the Provider window
provider_window = ThemedTk(theme="breeze")
provider_window.title("Network Creator v0.1")
create_menu(provider_window)

# Create a bold style for the LabelFrame title
style = ttk.Style()
style.configure("Bold.TLabelframe.Label", font=("TkDefaultFont", 10, "bold"))

# Create a frame for the provider controls with a bold title
provider_frame = ttk.LabelFrame(provider_window, text="Provider Creator", style="Bold.TLabelframe")
provider_frame.grid(row=0, column=0, padx=10, pady=10, sticky="nsew")

provider_labels = ["Node", "Provider", "Routers", "Limit", "Start Delay"]
provider_entries = []
limit_entry = None  # Store the Limit entry to bind the Delete key to it

for i, label_text in enumerate(provider_labels):
    ttk.Label(provider_frame, text=label_text + ":").grid(row=i if i < 2 else i+1, column=0, padx=5, pady=5, sticky="e")
    entry = ttk.Entry(provider_frame)
    entry.grid(row=i if i < 2 else i+1, column=1, padx=5, pady=5, sticky="w")
    entry.insert(0, provider_config.get(label_text, ""))
    provider_entries.append(entry)
    if label_text == "Limit":
        limit_entry = entry  # Keep reference to the Limit entry for Delete binding

# Add checkbox for Serial Mode
serial_mode_var = tk.BooleanVar()
serial_mode_check = ttk.Checkbutton(provider_frame, text="Serial Mode", variable=serial_mode_var)
serial_mode_check.grid(row=len(provider_labels) + 1, column=0, columnspan=2, pady=5)

def run_provider_script(event=None):  # Added `event` parameter for key binding
    args = [entry.get() for entry in provider_entries]
    args.insert(2, "1")  # Set Destroy to 1

    provider_config = {label: entry.get() for label, entry in zip(provider_labels, provider_entries)}
    provider_config["Destroy"] = "1"
    save_config(provider_config, PROVIDER_CONFIG_FILE)

    # Determine which script to call based on Serial Mode checkbox
    script_name = "provider_serial.sh" if serial_mode_var.get() else "provider.sh"

    command = f"bash {script_name} {' '.join(args)}"
    try:
        subprocess.run(command, shell=True, check=True)
        messagebox.showinfo("Success", f"{script_name} executed successfully!")
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", f"{script_name} execution failed: {e}")

style.configure("Contrast.TButton", background="#d9d9d9", foreground="#333", padding=6)

create_provider_button = ttk.Button(provider_frame, text="Create Provider", style="Contrast.TButton", command=run_provider_script)
create_provider_button.grid(row=len(provider_labels)+2, column=0, columnspan=2, pady=10)

# Define Delete key behavior for the Limit entry
def delete_in_limit_entry(event):
    current_position = limit_entry.index(tk.INSERT)
    limit_entry.delete(current_position)

# Bind Return and Delete keys to the provider window
provider_window.bind('<Return>', run_provider_script)
if limit_entry:
    limit_entry.bind('<Delete>', delete_in_limit_entry)
    limit_entry.bind('<KP_Delete>', delete_in_limit_entry)  # Bind Delete key on the keypad

# Load and display the image in the column next to provider_frame (only in Provider window)
img = tk.PhotoImage(file=IMAGE_PATH)
image_label = ttk.Label(provider_window, image=img)
image_label.grid(row=0, column=1, padx=10, pady=10, sticky="nsew")

# Create the General window
general_window = ThemedTk(theme="breeze")
general_window.title("Network Creator v0.1")
create_menu(general_window)

def create_ui(row, col, label_text, script_name, param_count):
    # Create a LabelFrame
    frame = ttk.LabelFrame(general_window, text="", style="Bold.TLabelframe")
    frame.grid(row=row+1, column=col, padx=10, pady=5, sticky="nsew")
    
    # Add a bold label inside the LabelFrame
    bold_label = tk.Label(frame, text=label_text, font=("TkDefaultFont", 10, "bold"))
    bold_label.grid(row=0, column=0, columnspan=2, pady=(0, 10))

    entries = []
    for i in range(param_count):
        label = "Routers:" if i == 0 else "Delay:"
        ttk.Label(frame, text=label).grid(row=i+1, column=0, padx=5, pady=5)
        entry = ttk.Entry(frame)
        entry.grid(row=i+1, column=1, padx=5, pady=5)
        entry.insert(0, config.get(script_name, [""] * param_count)[i])
        entries.append(entry)
    
    run_button = ttk.Button(frame, text="Go", style="Contrast.TButton", command=lambda: on_run_button(script_name, CONFIG_FILE, *entries))
    run_button.grid(row=param_count+1, column=0, columnspan=2, pady=5)

# Create the UI for the General window with bold LabelFrame titles
# New column for Restart ISP
create_ui(0, 0, "Restart ISP1", "restart_isp1.sh", 2)
create_ui(1, 0, "Restart ISP2", "restart_isp2.sh", 2)
create_ui(2, 0, "Restart ISP3", "restart_isp3.sh", 2)

# Shift other columns to the right
create_ui(0, 1, "Start ISP1", "start_isp1.sh", 2)
create_ui(1, 1, "Start ISP2", "start_isp2.sh", 2)
create_ui(2, 1, "Start ISP3", "start_isp3.sh", 2)

create_ui(0, 2, "Shutdown ISP1", "shutdown_isp1.sh", 1)
create_ui(1, 2, "Shutdown ISP2", "shutdown_isp2.sh", 1)
create_ui(2, 2, "Shutdown ISP3", "shutdown_isp3.sh", 1)

create_ui(0, 3, "Destroy ISP1", "destroy_isp1.sh", 1)
create_ui(1, 3, "Destroy ISP2", "destroy_isp2.sh", 1)
create_ui(2, 3, "Destroy ISP3", "destroy_isp3.sh", 1)

# Create the Provider Turbo window
provider_turbo_window = ThemedTk(theme="breeze")
provider_turbo_window.title("Network Creator v0.1")
create_menu(provider_turbo_window)

# Create a frame for the provider turbo controls with a bold title
provider_turbo_frame = ttk.LabelFrame(provider_turbo_window, text="", style="Bold.TLabelframe")
provider_turbo_frame.grid(row=0, column=0, padx=10, pady=10, sticky="nsew")

# Add a bold label inside the LabelFrame
bold_label = tk.Label(provider_turbo_frame, text="Turbo Provider Creator", font=("TkDefaultFont", 10, "bold"))
bold_label.grid(row=0, column=0, columnspan=2, pady=(0, 10))

provider_turbo_labels = ["Node", "Provider", "Routers", "Limit"]
provider_turbo_entries = []

for i, label_text in enumerate(provider_turbo_labels):
    ttk.Label(provider_turbo_frame, text=label_text + ":").grid(row=i+1 if i < 2 else i+2, column=0, padx=5, pady=5, sticky="e")
    entry = ttk.Entry(provider_turbo_frame)
    entry.grid(row=i+1 if i < 2 else i+2, column=1, padx=5, pady=5, sticky="w")
    entry.insert(0, provider_turbo_config.get(label_text, ""))
    provider_turbo_entries.append(entry)
    if label_text == "Limit":
        entry.bind('<Delete>', delete_in_limit_entry)
        entry.bind('<KP_Delete>', delete_in_limit_entry)

def run_provider_turbo_script(event=None):  # Added `event` parameter for key binding
    args = [entry.get() for entry in provider_turbo_entries]
    args.insert(2, "1")  # Set Destroy to 1

    provider_turbo_config = {label: entry.get() for label, entry in zip(provider_turbo_labels, provider_turbo_entries)}
    provider_turbo_config["Destroy"] = "1"
    
    # Save the config in the file
    save_config(provider_turbo_config, PROVIDER_TURBO_CONFIG_FILE)

    command = f"bash provider-turbo.sh {' '.join(args)}"
    try:
        subprocess.run(command, shell=True, check=True)
        messagebox.showinfo("Success", "Provider Turbo script executed successfully!")
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", f"Provider Turbo script execution failed: {e}")

create_provider_turbo_button = ttk.Button(provider_turbo_frame, text="Create Provider Turbo", style="Contrast.TButton", command=run_provider_turbo_script)
create_provider_turbo_button.grid(row=len(provider_turbo_labels)+2, column=0, columnspan=2, pady=10)

# Bind Return key to run the provider turbo script
provider_turbo_window.bind('<Return>', run_provider_turbo_script)

# Create the Single Router window
single_router_window = ThemedTk(theme="breeze")
single_router_window.title("Network Creator v0.1")
create_menu(single_router_window)

# Create a frame for the single router controls with a bold title
single_router_frame = ttk.LabelFrame(single_router_window, text="", style="Bold.TLabelframe")
single_router_frame.grid(row=0, column=0, padx=10, pady=10, sticky="nsew")

# Add a bold label inside the LabelFrame
bold_label = tk.Label(single_router_frame, text="Single Router Creator", font=("TkDefaultFont", 10, "bold"))
bold_label.grid(row=0, column=0, columnspan=2, pady=(0, 10))

# Node input field
ttk.Label(single_router_frame, text="Node:").grid(row=1, column=0, padx=5, pady=5, sticky="e")
node_entry = ttk.Entry(single_router_frame)
node_entry.grid(row=1, column=1, padx=5, pady=5, sticky="w")
node_entry.insert(0, single_router_config.get("Node", ""))

# Provider input field
ttk.Label(single_router_frame, text="Provider:").grid(row=2, column=0, padx=5, pady=5, sticky="e")
provider_entry = ttk.Entry(single_router_frame)
provider_entry.grid(row=2, column=1, padx=5, pady=5, sticky="w")
provider_entry.insert(0, single_router_config.get("Provider", ""))

# Router input field
ttk.Label(single_router_frame, text="Router:").grid(row=3, column=0, padx=5, pady=5, sticky="e")
router_entry = ttk.Entry(single_router_frame)
router_entry.grid(row=3, column=1, padx=5, pady=5, sticky="w")
router_entry.insert(0, single_router_config.get("Router", ""))

# Collect all the entries
single_router_entries = [node_entry, provider_entry, router_entry]

def run_single_router_script(event=None):  # Added `event` parameter for key binding
    args = [node_entry.get(), provider_entry.get(), "1", router_entry.get()]  # Set Destroy to 1

    single_router_config = {
        "Node": node_entry.get(),
        "Provider": provider_entry.get(),
        "Destroy": "1",
        "Router": router_entry.get()
    }
    save_config(single_router_config, SINGLE_ROUTER_CONFIG_FILE)

    command = f"bash single_router.sh {' '.join(args)}"
    try:
        subprocess.run(command, shell=True, check=True)
        messagebox.showinfo("Success", "Single Router script executed successfully!")
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", f"Single Router script execution failed: {e}")

create_single_router_button = ttk.Button(single_router_frame, text="Create Single Router", style="Contrast.TButton", command=run_single_router_script)
create_single_router_button.grid(row=4, column=0, columnspan=2, pady=10)

# Bind Return key to run the single router script
single_router_window.bind('<Return>', run_single_router_script)

# Make all windows resizable
for window in [provider_window, general_window, provider_turbo_window, single_router_window]:
    for i in range(3):
        window.grid_columnconfigure(i, weight=1)
        window.grid_rowconfigure(i, weight=1)

# Set the initial state (show one window, hide the others)
show_window(provider_window)
general_window.withdraw()
provider_turbo_window.withdraw()
single_router_window.withdraw()

# Start the main loop
provider_window.mainloop()
