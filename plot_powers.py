import matplotlib.pyplot as plt
import pandas as pd
import sys

# Load the CSV file with manual column names
column_names = ['timestamp in ms', 'RF power (dBm)', 'RF power (mW)']
# data = pd.read_csv('20240813_165416.csv', names=column_names, usecols=[0, 1, 2])
data = pd.read_csv(sys.argv[1], names=column_names, usecols=[0, 1, 2])

data = data[data['timestamp in ms'] <= 3600000]
print(data.head())

# Convert timestamp from ms to minutes
data['timestamp in minutes'] = data['timestamp in ms'] / 60000

# Calculate the moving average for 'RF power (dBm)' and 'RF power (mW)' with a window size of 100
data['RF power (dBm) MA'] = data['RF power (dBm)'].rolling(window=100).mean()
data['RF power (mW) MA'] = data['RF power (mW)'].rolling(window=100).mean()

# Filter data to include only the first hour (3600000 ms)

# Create subplots
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(5, 6))

# Plot RF power (dBm)
ax1.plot(data['timestamp in minutes'], data['RF power (dBm)'], 'k.', markersize=2, label='Raw Data')
ax1.plot(data['timestamp in minutes'], data['RF power (dBm) MA'], 'b-', label='Moving Average')
ax1.set_title('RF Power (dBm)')
ax1.set_xlabel('Timestamp (minutes)')
ax1.set_ylabel('RF Power (dBm)')
ax1.legend()
ax1.grid(True, which='both', axis='y', linestyle='--', linewidth=0.5)

# Plot RF power (mW)
ax2.plot(data['timestamp in minutes'], data['RF power (mW)'], 'k.', markersize=2, label='Raw Data')
ax2.plot(data['timestamp in minutes'], data['RF power (mW) MA'], 'b-', label='Moving Average')
ax2.set_title('RF Power (mW)')
ax2.set_xlabel('Timestamp (minutes)')
ax2.set_ylabel('RF Power (mW)')
ax2.legend()
ax2.grid(True, which='both', axis='y', linestyle='--', linewidth=0.5)

# Adjust layout and show plot
plt.tight_layout()
plt.show()
