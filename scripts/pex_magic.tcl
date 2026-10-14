# Magic RC extraction (wire resistance + capacitance) of a prepared GDS; run by scripts/run_pex.sh --rc magic:
#   PEX_GDS=<prepared.gds> PEX_CELL=<top> PEX_OUT=<raw.spice> [PEX_CAPS=<prepared.gds.caps>] [PEX_RTHRESH=0] [PEX_CTHRESH=0.01]
#   magic -dnull -noconsole -rcfile .../ihp-sg13cmos5l.magicrc < scripts/pex_magic.tcl
# Output: PEX_OUT (ngspice, devices as PDK subckt calls, R/C network wired to the device terminals) and PEX_OUT.capnodes
# (one line per MoM cap: the two nets Magic finds under the Metal4 terminal bars of the cap marker).
#
# Why the extra steps (all found by experiment, Magic 8.3.684 + ihp-sg13cmos5l tech):
#  * `extresist all` only extracts nets that are ports ("Nets extracted: 6" of 11 otherwise). Every net that is not a port yet is
#    therefore given a port label (pnN) at the location Magic itself reports for the node; scripts/pex_netlist.py drops those
#    names from the .subckt line again.
#  * Magic knows no cap_cmomi device (the extract tech has none); the GDS copy has the fingers stripped, so the cap is two
#    Metal4 bars. They are asked for their nets (getnode) and pex_netlist.py puts the compact-model cap back from the schematic.
proc envor {name default} { if {[info exists ::env($name)]} { return $::env($name) } else { return $default } }
set gds   $::env(PEX_GDS)
set cell  $::env(PEX_CELL)
set out   $::env(PEX_OUT)
set caps  [envor PEX_CAPS ""]
set rthr  [envor PEX_RTHRESH 0]
set cthr  [envor PEX_CTHRESH 0.01]
set unit  0.005   ;# um per Magic internal unit of the .ext coordinates (checked against the pin labels of the GDS)

gds read $gds
load $cell
select top cell
expand
extract path extfiles
extract all

# 1. every node that is not a port gets one
set fp [open extfiles/$cell.ext r]
set ports {}
set nodes {}
while {[gets $fp line] >= 0} {
    switch -- [lindex $line 0] {
        port { lappend ports [lindex $line 1] }
        node { lappend nodes [list [lindex $line 1] [lindex $line 4] [lindex $line 5] [lindex $line 6]] }
    }
}
close $fp
set k 0
# the order of the node lines varies from run to run: sort, so that pnN (and then Magic's R network) is reproducible
foreach n [lsort -index 3 [lsort -integer -index 2 [lsort -integer -index 1 [lsort -index 0 $nodes]]]] {
    lassign $n name x y type
    if {[lsearch -exact $ports $name] >= 0} { continue }
    incr k
    box position [expr {$x * $unit}]um [expr {$y * $unit}]um
    box size 0.01um 0.01um
    if {[catch { label pn$k FreeSans 0.1um 0 0 0 c $type; port make } err]} {
        puts "pex_magic: WARNING cannot label node $name ($type): $err"
    }
}
puts "pex_magic: [llength $ports] port(s), $k internal net(s) labelled"

# 2. nets under the MoM cap terminals
if {$caps ne "" && [file exists $caps]} {
    set cf [open ${out}.capnodes w]
    set cp [open $caps r]
    while {[gets $cp line] >= 0} {
        if {[llength $line] != 4} { continue }
        set names {}
        foreach {x y} $line {
            box position ${x}um ${y}um
            box size 0.1um 0.1um
            select area m4
            lappend names [getnode]
        }
        puts $cf $names
    }
    close $cp
    close $cf
}

# 3. extraction with resistance
extract all
ext2sim labels on
ext2sim -p extfiles
extresist threshold $rthr
extresist minresist $rthr
extresist mindelay 0
extresist all
ext2spice lvs
ext2spice cthresh $cthr
ext2spice extresist on
ext2spice -p extfiles -o $out
quit -noprompt
