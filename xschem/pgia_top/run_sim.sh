#!/usr/bin/env bash
# ===============================================================================
# PGIA Top-Level Automated Verification Flow
# Pipeline: Schematic (.sch) -> Netlist (.spice) -> Simulation (Ngspice) -> Audit (Python)
# ===============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SIM_DIR="$SCRIPT_DIR/simulations"
SIM_LOG="$SIM_DIR/tb_pgia_top.log"

# Add standard tool paths
export PATH="$ROOT_DIR/scripts/bin:/foss/tools/xschem/bin:/usr/local/bin:/usr/bin:$PATH"

mkdir -p "$SIM_DIR"

echo "================================================================================"
echo "    PGIA TOP-LEVEL FULL VERIFICATION: SCHEMATIC (.sch) -> AUDIT"
echo "================================================================================"

# ------------------------------------------------------------------------------
# STEP 1: Netlist from Schematic (.sch) using Xschem
# ------------------------------------------------------------------------------
echo "[Step 1/3] Netlisting from master schematic (tb_pgia_top.sch -> tb_pgia_top.spice)..."

XSCHEM_BIN="$(command -v xschem || true)"
if [ -z "$XSCHEM_BIN" ]; then
    echo "[!] Error: 'xschem' binary was not found on PATH."
    echo "    PATH=$PATH"
    exit 1
fi

(cd "$SCRIPT_DIR" && "$XSCHEM_BIN" -q -n -s --rcfile xschemrc -o simulations/ tb_pgia_top.sch)

if [ ! -f "$SIM_DIR/tb_pgia_top.spice" ]; then
    echo "[!] Error: Netlisting failed. $SIM_DIR/tb_pgia_top.spice was not generated."
    exit 1
fi
echo "  -> Netlist successfully generated: $SIM_DIR/tb_pgia_top.spice"

# ------------------------------------------------------------------------------
# STEP 2: Run Batch Co-Simulation Battery using Ngspice
# ------------------------------------------------------------------------------
echo
echo "[Step 2/3] Running Ngspice mixed-signal co-simulation battery..."

NGSPICE_BIN="$(command -v ngspice || true)"
if [ -z "$NGSPICE_BIN" ]; then
    echo "[!] Error: 'ngspice' binary was not found on PATH."
    exit 1
fi

(cd "$SIM_DIR" && "$NGSPICE_BIN" -b tb_pgia_top.spice > "$SIM_LOG" 2>&1)

echo "  -> Simulation raw log captured: $SIM_LOG"

# ------------------------------------------------------------------------------
# STEP 3: Parse & Audit Results against Specifications using Python
# ------------------------------------------------------------------------------
echo
echo "[Step 3/3] Parsing simulation results and auditing specifications..."
python3 "$SCRIPT_DIR/verify_pgia_top.py" --log "$SIM_LOG" "$@"


