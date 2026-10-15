# 04: Architecture (repository `/foss/designs/dao`)

```
src/dao/
  spec/models.py        Problem, Variable (real|int, low/high, log, grid, seed), Objective; YAML loader; problem digest
  fom/dsl.py            restricted-AST expressions + constraints (normalised violation); fom/library.py: FOM_S, FOM_L, NEF, NOISE_POWER
  pdk/profile.py        PdkProfile: corners -> .lib lines, device classes -> instance templates, length unit, op-variable access, init (OSDI)
  pdk/profiles/         ihp_sg13cmos5l.yaml (validated), sky130A.yaml (MOS validated)
  circuit/netlist.py    generic netlist (device classes, SI units) -> PDK netlist; device inventory
  kits/amplifier.py     port-based testbench: open loop (A0, UGF, PM, GM, F3DB_OL, polarity), follower (P, I, sat margin, gm/ID, noise)
  sim/ngspice.py        private dir + .spiceinit per run, num_threads=1, clean env, content-hash cache
  study.py              history, Deb ranking, worst-case-over-corners constraints, parallel ordered evaluation
  opt/                  registry: sobol, cmaes (multi-start), nelder_mead, pattern (certificate), eps_pareto; surrogate_gradient (planned)
  report/               history.csv (hash), best.json, seed.json, certificate.json, manifest.json, summary.md, convergence.png
  signoff/cace.py       write values into an xschem .param block + instance m=, then run CACE
  adapters/analoggym.py AnalogGym netlists/design variables -> generic netlist + problem skeleton
  graph/netlist2graph.py FALCON-style edge-centric graph of a subckt (IR for a future surrogate)
```

## Data flow
`problem.yaml` → `Study`:
1. **Seed** the run with the seed design.
2. **Each algorithm in the chain** asks for unit-cube points, and `Study.evaluate` turns each point into a full result:
   - decode the point (log scaling, grid, int) into variable values;
   - build the full parameter set (conditions, fixed, variables, then tied expressions);
   - for each corner, run the kit on the rendered deck and simulate it (cached);
   - read the metrics and compute the constraint violation (worst case over corners) and the objective (nominal corner);
   - rank the result with Deb's rules.
3. **Report** the run.

## Determinism contract
- **Inputs are hashed:** the problem spec, the netlist text, the PDK profile, the PDK version file and the ngspice version (see `manifest.json`).
- **The simulation is isolated:**
  - every evaluation runs in a fresh directory with its own `.spiceinit` (profile commands, OSDI loads, `set num_threads=1`);
  - `HOME` is replaced and `SPICE_USERINIT_DIR` removed, so neither the user's nor the PDK's init files can change results.
- **Algorithms are seeded:**
  - Sobol: scrambled, with a fixed seed;
  - CMA-ES: its `seed` option, plus restart index × 1000;
  - pattern search and Nelder–Mead: deterministic.
- **Evaluation is deterministic:** parallel evaluation keeps submission order. Duplicate designs are evaluated once; duplicates are detected on decoded, grid-snapped values formatted with `%.12g`.
- **Ranking is a total order:** feasibility first, then violation or objective, then evaluation index.
- **The output is hashable:** `history.csv` contains no timestamps or paths, so its SHA-256 identifies the run.

## Plug-in points
- **New algorithm:** subclass `dao.opt.Optimizer` and decorate it with `@register("name")`. Use only RNGs seeded from `self.seed`; evaluate through `self.study.evaluate(points)`.
- **New circuit class** (LDO, comparator, bandgap): add a kit with the same signature as `kits.amplifier.evaluate` to `dao.kits.KITS`.
- **New PDK:** add a profile YAML. It needs the corners, a template plus op-variable path per device class, the length unit and the init lines.
- **New FoM:** add it to `fom.library.LIBRARY`, or write the expression in the problem.
