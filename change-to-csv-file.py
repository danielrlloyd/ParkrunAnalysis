import os
import glob

# Define the relative path to your data folder
data_path = "data"

# Get the full path to the data directory
full_data_path = os.path.join(os.getcwd(), data_path)

# Change to the data directory
os.chdir(full_data_path)

# Get all files without extensions in the data directory
files = [f for f in os.listdir('.') if os.path.isfile(f) and '.' not in f]

print(f"Found {len(files)} files without extensions")

# Rename each file by adding .csv extension
for file in files:
    new_name = file + '.csv'
    os.rename(file, new_name)
    print(f"Renamed: {file} -> {new_name}")

print(f"Processed {len(files)} files")