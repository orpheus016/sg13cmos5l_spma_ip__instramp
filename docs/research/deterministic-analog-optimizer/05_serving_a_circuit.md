# 05: How to serve a circuit to DAO

## 1. Write (or export) the subckt with device classes
Start from the xschem netlist (`netlist/<cell>/schematic/<cell>.spice`). Make these changes:
- **Replace PDK model names with classes** from the profile: `nmos_lv`, `pmos_lv`, `res_hi`, `cap_mom`.
- **Write W, L and M in SI units as expressions** of parameter names.
- **Keep the node order:** MOS is `d g s b`, `res_hi` is `a b body`, `cap_mom` is `a b`.
- **Remove `.param` lines from inside the subckt.** They would override the optimiser. Defaults go in the problem YAML.

```spice
.subckt ota_cmos5l VSS IBIAS VDD VINN VINP VOUT
M1 net2 VINN net1 VDD pmos_lv W={winpair} L={linpair} M=1
C1 VOUT net4 cap_mom W=15e-6 L=15e-6 M={cc_units}
.ends ota_cmos5l
```
Matched devices should share parameters (M1/M2 both use `winpair`), so symmetry holds by construction. Lines without a device class pass through unchanged, but then they are tied to one PDK.

## 2. Map the pins to port roles
```yaml
circuit: {netlist: ota.cir, subckt: ota_cmos5l,
          ports: {vss: VSS, ibias: IBIAS, vdd: VDD, inn: VINN, inp: VINP, out: VOUT}}
```
- **Roles:** `vdd`, `vss`, `inp`, `inn` and `out` are required. `ibias` is optional (`kit.ibias: sink|source`).
- **Every subckt pin needs a role.** Pin names are case-insensitive.

## 3. Declare what is fixed, what is tied, and what moves
```yaml
conditions: {vdd: 1.2, vcm: 0.6, ib: 1.4e-6, cl: 3e-12, temp: 27}   # testbench conditions (match CACE)
fixed:      {m6: 1}
tied:       {lbias: "lcs"}                                         # optional, expressions
variables:
  - {name: winpair, low: 2e-6, high: 400e-6, log: true, grid: 5e-9, seed: 20e-6}   # seed = your current design
  - {name: m7, type: int, low: 1, high: 64, seed: 4}
```
- **Use `log: true` for widths, lengths, currents and capacitors.**
- **Use `grid:` to match the layout grid** (5 nm on IHP).
- **The seeds are your half-optimised design.** They are evaluated first and reported side by side with the result.
- **Keep variable names equal to the xschem `.param` names** if you want the automatic write-back.

## 4. Choose the measurements, the FoM and the constraints
```yaml
kit: {name: amplifier, noise: {spot: {IRN_1k: 1000.0, IRN_10k: 10000.0}, white: 1000000.0, band: [10.0, 100000000.0]}}
corners: [tt]                                # constraints hold worst-case over all listed corners
constraints: ["PM >= 60", "A0_dB >= 60", "UGF >= 2e6", "P <= 150e-6", "sat_margin >= 0.05", "area <= 20000e-12"]
objective: {minimize: "IRN_1k/1e-9 + IRN_10k/1e-9"}     # or {maximize: "FOM_S"}
```
**Metrics available from the amplifier kit:**
- `A0_dB`, `UGF`, `PM`, `GM_dB`, `F3DB_OL`, `polarity_ok`;
- `I_total`, `P`, `sat_margin` (the worst MOS: |Vds| − |Vdsat|);
- `IRN_<name>`, `IRN_white`, `IRN_int`;
- `area`, `area_active`, `area_cap`.

You can also use any variable or condition, library FoMs (`FOM_S`, `NEF`, …) and the functions `sqrt`, `log10`, `db`, `min`, `max` and `abs`.

**Write numbers with a decimal point** (`1000.0`, `1.0e+3`): YAML reads `1e3` as a string.

## 5. Pick the algorithm chain and run
```yaml
algorithm:
  - sobol:   {n: 512}                                        # space-filling screen
  - cmaes:   {budget: 3000, sigma0: 0.25, popsize: 24, starts: 4}   # global-ish, multi-start
  - cmaes:   {budget: 1000, sigma0: 0.05}                    # local refinement
  - pattern: {budget: 3000, delta0: 0.125, delta_min: 0.002} # certified polish
seed: 1
```
```bash
dao eval  problem.yaml       # just the seed: check the kit against your CACE numbers first
dao run   problem.yaml       # optimise -> runs/<name>/<digest>-s<seed>/summary.md
dao pareto problem.yaml --secondary P --eps 3e-5,6e-5,1e-4
```

## 6. Sign off
The `signoff:` block names the xschem file, the parameters to write and the instance `m` splits, plus the CACE command. `dao.signoff.signoff(problem, best_values)` edits only those tokens and runs CACE. Review the edit with `git diff`.

## Checklist before trusting a result
- [ ] `dao eval` on the seed matches CACE within a few %.
- [ ] Every constraint that matters for the application is in the list. The optimiser will use any freedom you leave it: tail saturation, area, phase margin, input range.
- [ ] Bounds are physically sensible (min L, max W, current budget).
- [ ] The certificate says "mesh-local optimum". If it doesn't, raise the pattern budget.
- [ ] Final CACE sign-off, including the PVT profile.
