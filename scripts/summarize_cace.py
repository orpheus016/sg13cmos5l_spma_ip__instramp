#!/usr/bin/env python3
"""Summarise the latest CACE run into markdown (PVT min/max with worst-case conditions, MC mean/sigma per corner).
usage: scripts/summarize_cace.py [cell=ota_cmos5l] [runs/RUN_xxx]   -> prints markdown
Reads the raw *.data files (SI base units) and the yaml (variable order + display units)."""
import glob, os, statistics as st, sys
import yaml

cell = sys.argv[1] if len(sys.argv) > 1 else 'ota_cmos5l'
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
run = sys.argv[2] if len(sys.argv) > 2 else sorted(glob.glob(f'{root}/runs/RUN_*'))[-1]
ds = yaml.safe_load(open(f'{root}/cace/{cell}.yaml'))
SCALE = {'m': 1e-3, 'u': 1e-6, 'n': 1e-9, 'k': 1e3, 'M': 1e6, 'G': 1e9, 'p': 1e-12}
def scale(unit):
    if unit in ('%',): return 1e-2
    if unit == 'ppm': return 1e-6
    if unit in ('V/s', 'V/V', 'Hz', 'dB', '°', 'V', 'A', 'W', 's', 'F'): return 1.0
    if unit.endswith('-rms') or '/' in unit:
        return SCALE.get(unit[0], 1.0) if unit[0] in SCALE and unit not in ('V/s', 'V/V') else 1.0
    return SCALE.get(unit[0], 1.0) if len(unit) > 1 and unit[0] in SCALE else 1.0

def cond(path):
    c = yaml.safe_load(open(path)) or {}
    return c

def read(d):
    f = glob.glob(d + '/*.data')
    return [float(x) for x in open(f[0]).read().split()] if f else None

out = [f'# {cell} – CACE results ({os.path.basename(run)})\n']
for pname, p in ds['parameters'].items():
    pdir = f'{run}/parameters/{pname}'
    if not os.path.isdir(pdir): continue
    tool = p.get('tool', {}); tool = tool.get('ngspice') if isinstance(tool, dict) else None
    if not tool: continue
    variables = tool['variables']; mc = tool.get('collate') == 'iterations'
    specs = p['spec']
    out.append(f"\n## {pname} – {p.get('display', '')}\n")
    if mc:
        out.append('| metric | corner | N | mean | σ | min | max | mean−3σ | mean+3σ |\n|---|---|---|---|---|---|---|---|---|')
        for ci, cdir in enumerate(sorted(glob.glob(pdir + '/run_*'), key=lambda x: int(x.rsplit('_', 1)[1]))):
            samples = {}
            corner = None
            for idir in sorted(glob.glob(cdir + '/run_*')):
                v = read(idir)
                if v is None: continue
                corner = corner or cond(idir + '/conditions.yaml').get('corner')
                for name, val in zip(variables, v):
                    if name and name != 'null': samples.setdefault(name, []).append(val)
            for name, xs in samples.items():
                u = specs[name]['unit']; s = scale(u)
                xs = [x / s for x in xs]; m = st.mean(xs); sd = st.stdev(xs) if len(xs) > 1 else 0
                out.append(f'| {name} [{u}] | {corner} | {len(xs)} | {m:.4g} | {sd:.3g} | {min(xs):.4g} | {max(xs):.4g} | {m-3*sd:.4g} | {m+3*sd:.4g} |')
    else:
        rows = []
        for d in sorted(glob.glob(pdir + '/run_*')):
            v = read(d)
            if v is None: continue
            c = cond(d + '/conditions.yaml')
            rows.append((c.get('corner'), float(c.get('vdd', 0)), float(c.get('temperature', 0)), v))
        out.append(f'{len(rows)} runs.\n\n| metric | min | at (corner, vdd, T) | max | at (corner, vdd, T) | spec |\n|---|---|---|---|---|---|')
        for i, name in enumerate(variables):
            if not name or name == 'null': continue
            u = specs[name]['unit']; s = scale(u)
            lo = min(rows, key=lambda r: r[3][i]); hi = max(rows, key=lambda r: r[3][i])
            sp = specs[name]; lim = []
            if sp['minimum']['value'] != 'any': lim.append(f"≥ {sp['minimum']['value']}")
            if sp['maximum']['value'] != 'any': lim.append(f"≤ {sp['maximum']['value']}")
            bad = sum(1 for r in rows if (sp['minimum']['value'] != 'any' and r[3][i] / s < float(sp['minimum']['value'])) or (sp['maximum']['value'] != 'any' and r[3][i] / s > float(sp['maximum']['value'])))
            lims = (' '.join(lim) + (f' (**{bad}/{len(rows)} fail**)' if bad else ' (pass)')) if lim else 'any'
            out.append(f'| {name} [{u}] | {lo[3][i]/s:.4g} | {lo[0]}, {lo[1]}, {lo[2]:g} | {hi[3][i]/s:.4g} | {hi[0]}, {hi[1]}, {hi[2]:g} | {lims} |')
print('\n'.join(out))
