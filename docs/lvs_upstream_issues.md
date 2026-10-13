# Draft issues for IHP-Open-PDK (LVS, MoM capacitors)

Drafts only, nothing has been posted. Seen with `hpretl/iic-osic-tools:2026.09`, KLayout 0.30.12, `ihp-sg13cmos5l` (rule decks are shared with `ihp-sg13g2`); the same code is on `main` of IHP-Open-PDK. Workaround in this repo: [LVS guide, L5a](README.md#l5a-mom-caps-cap_cmomi-cap_cmomf-with-m--1).

## 1. `cap_cmomi` / `cap_cmomf`: schematic `m` is ignored in KLayout LVS

`ihp-sg13g2/libs.tech/klayout/tech/lvs/rule_decks/custom_reader.lvs`, `map_capacitor_params`:

```ruby
device.set_parameter('m', params['M'] || params['MF'] || 1.0) if model.downcase.include?('mim')
...
if model.downcase.include?('mim')   # A and P
```

`cap_cmomi`, `cap_cmomf` do not contain `mim`, so `m`, `A`, `P` stay at their defaults. A schematic line `C1 a b cap_cmomi w=15u l=15u m=9` is read as `m=1` (see the `.lvsdb`), and never matches a layout with 9 caps.

Suggested fix: use `include?('mim') || include?('cmom')` in both conditions.

## 2. MoM cap combiner ignores the declared terminal equivalence

`custom_combiner.lvs`, `MIMCAPNDeviceCombiner#combine_devices` requires `same_net(a, b, 'mim_top') && same_net(a, b, 'mim_btm')`. For `cap_cmomi`/`cap_cmomf` the two terminals are declared equivalent (`custom_mim_extractor.lvs`) because `CapMomExtractor` orders them by geometry, so mirrored/rotated instances swap them. The combiner then refuses to merge electrically parallel caps: an array drawn as 5 x `r90` and 4 x `m135` around a common bus extracts as two devices (`m=5`, `m=4`) between the same two nets.

Suggested fix: for models containing `cmom` also accept `top(a)==btm(b) && btm(a)==top(b)`; merge by summing `m` as today.

## Reproduce

Layout: nine `cap_cmomi` (w=15u, l=15u, `double` feed) between nets X and Y, rows with different orientation. Schematic: one `cap_cmomi m=9` between X and Y. Result: schematic cap `m=1.0`; layout caps `m=5` and `m=4`; nets X, Y mismatch.
