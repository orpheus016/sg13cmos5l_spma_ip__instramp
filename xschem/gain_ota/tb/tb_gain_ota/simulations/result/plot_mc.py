import os
import matplotlib.pyplot as plt
import numpy as np

# 1. Resolve script directory to guarantee reliable file path resolution
current_dir = os.path.dirname(os.path.abspath(__file__))
file_path = os.path.join(current_dir, "tb_gain_ota_mc.txt")

# 2. Load Monte Carlo numerical dataset exported from ngspice
data = np.genfromtxt(file_path, names=True)
vos_raw = data["Vos_mV"]
iq_raw = data["Iq_uA"]

# 3. Filter out trailing empty rows or NaN tokens to prevent statistical degradation
valid_mask = ~np.isnan(vos_raw) & ~np.isnan(iq_raw)
vos = vos_raw[valid_mask]
iq = iq_raw[valid_mask]

# 4. Compute sample statistical metrics (mean and standard deviation)
mean_vos, std_vos = np.mean(vos), np.std(vos)
mean_iq, std_iq = np.mean(iq), np.std(iq)

# 5. Initialize figure canvas with two side-by-side subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.5))

# --- Subplot 1: Input Offset Voltage (Vos) Distribution ---
ax1.hist(vos, bins=10, edgecolor="black", alpha=0.7, color="skyblue")
ax1.set_title(
    f"Vos: Mean = {mean_vos:.3f} mV, Std = {std_vos:.4f} mV",
    fontsize=11,
    fontweight="bold",
)
ax1.set_xlabel("Input Offset Voltage (mV)")
ax1.set_ylabel("Occurrences")
ax1.grid(True, linestyle="--", alpha=0.5)

# --- Subplot 2: Total Quiescent Current (Iq) Distribution ---
ax2.hist(iq, bins=10, edgecolor="black", alpha=0.7, color="salmon")
ax2.set_title(
    f"Iq: Mean = {mean_iq:.2f} uA, Std = {std_iq:.4f} uA",
    fontsize=11,
    fontweight="bold",
)
ax2.set_xlabel("Quiescent Current (uA)")
ax2.set_ylabel("Occurrences")
ax2.grid(True, linestyle="--", alpha=0.5)

# 6. Format layout and render plot window
plt.tight_layout()
plt.show()
