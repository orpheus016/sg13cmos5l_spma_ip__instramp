v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -130 -410 -130 -400 {lab=VDD}
N -50 -410 -50 -390 {lab=VDD}
N -50 -330 -50 -310 {lab=I_B}
N -130 -340 -130 -320 {lab=0}
N -190 -340 -190 -320 {lab=0}
N -190 -410 -190 -400 {lab=VSS}
N 70 -180 70 -160 {lab=I_B}
N 50 -180 70 -180 {lab=I_B}
N 90 -180 90 -160 {lab=VDD}
N 140 -10 140 10 {lab=VSS}
N 140 10 150 10 {lab=VSS}
N 10 -330 10 -310 {lab=VSS
}
N 10 -420 20 -420 {lab=VCM
}
N 10 -420 10 -390 {lab=VCM
}
N -60 -80 -40 -80 {lab=VCM}
N -60 -100 -40 -100 {lab=IN2}
N 200 -90 220 -90 {lab=OUT2}
N 100 -310 100 -300 {lab=VSS
}
N 100 -390 100 -370 {lab=OUT2
}
N 20 -10 20 20 {lab=S5}
N 40 -10 40 20 {lab=S4}
N 60 -10 60 20 {lab=S3}
N 80 -10 80 20 {lab=S2}
N 100 -10 100 20 {lab=S1}
N 120 -10 120 20 {lab=S0}
N -370 -70 -370 -60 {lab=VSS}
N -310 -70 -310 -60 {lab=VSS}
N -370 -60 -310 -60 {lab=VSS}
N -370 -170 -370 -160 {lab=VSS}
N -250 -160 -190 -160 {lab=VSS}
N -190 -170 -190 -160 {lab=VSS}
N -310 -170 -310 -160 {lab=VSS}
N -370 -160 -310 -160 {lab=VSS}
N -250 -170 -250 -160 {lab=VSS}
N -310 -160 -250 -160 {lab=VSS}
N -190 -160 -170 -160 {lab=VSS}
N -310 -60 -290 -60 {lab=VSS}
N -370 -250 -370 -230 {lab=S0}
N -310 -250 -310 -230 {lab=S1}
N -250 -250 -250 -230 {lab=S2}
N -190 -250 -190 -230 {lab=S3}
N -370 -150 -370 -130 {lab=S4}
N -310 -150 -310 -130 {lab=S5}
N 180 -320 180 -300 {lab=VSS
}
N 180 -410 190 -410 {lab=IN2
}
N 180 -410 180 -380 {lab=IN2
}
C {isource.sym} -50 -360 0 0 {name=I0 value=\{ib\}}
C {vsource.sym} -130 -370 0 0 {name=V2 value=\{vdd\} savecurrent=false}
C {gnd.sym} -130 -320 0 0 {name=l1 lab=0}
C {vdd.sym} -130 -410 0 0 {name=l3 lab=VDD}
C {vdd.sym} -50 -410 0 0 {name=l4 lab=VDD}
C {lab_pin.sym} -50 -310 3 0 {name=p7 sig_type=std_logic lab=I_B}
C {vsource.sym} -190 -370 0 0 {name=V3 value=0 savecurrent=false}
C {gnd.sym} -190 -320 0 0 {name=l7 lab=0}
C {lab_pin.sym} -190 -410 1 0 {name=p3 sig_type=std_logic lab=VSS
}
C {simulator_commands_shown.sym} -430 -410 0 0 {name=General_Params
simulator=ngspice
only_toplevel=false
value=".param temp=27
.param cl=2p
.param ib=1u
.param vdd=1.2
.param vicm=vdd/2
.param vid=0
"
      }
C {simulator_commands_shown.sym} -420 -640 0 0 {name=Libs_Ngspice_Typ
simulator=ngspice
only_toplevel=false
value="tcleval(
.lib $::MODELS_NGSPICE/cornerMOSlv.lib mos_tt
.lib $::MODELS_NGSPICE/cornerMOShv.lib mos_tt
.lib $::MODELS_NGSPICE/cornerRES.lib res_typ
.lib $::MODELS_NGSPICE/cornerDIO.lib dio_tt
.lib $::MODELS_NGSPICE/cornerCAP.lib cap_typ
.lib $::MODELS_NGSPICE/cornerMOSCAP.lib moscap_tt 
)"
      }
C {lab_pin.sym} 50 -180 0 0 {name=p1 sig_type=std_logic lab=I_B}
C {vdd.sym} 90 -180 0 0 {name=l2 lab=VDD}
C {lab_pin.sym} 150 10 2 0 {name=p2 sig_type=std_logic lab=VSS
}
C {vsource.sym} 10 -360 0 0 {name=V1 value=\{vicm\} savecurrent=false
}
C {lab_pin.sym} 20 -420 2 0 {name=p10 sig_type=std_logic lab=VCM
}
C {lab_pin.sym} 10 -310 3 0 {name=p8 sig_type=std_logic lab=VSS
}
C {lab_pin.sym} -60 -80 0 0 {name=p4 sig_type=std_logic lab=VCM
}
C {lab_pin.sym} -60 -100 0 0 {name=p5 sig_type=std_logic lab=IN2}
C {lab_pin.sym} 220 -90 2 0 {name=p6 sig_type=std_logic lab=OUT2}
C {simulator_commands.sym} 290 -400 0 0 {name=5_LEVELS_SWEEP
simulator=ngspice
only_toplevel=false 
value="* ==============================================================================
* BINARY GAIN-STAGE NETWORK (PGA) 6-TAP AC & DC TELEMETRY CHARACTERIZATION
* Topology  : Inverting Switched-Resistor Feedback Ladder (R to 32R)
* Step Size : Pure Binary Stepping (+6.0206 dB / 2x Gain per Step)
* Technology: IHP SG13CMOS5L (130nm BiCMOS)
* ==============================================================================

.control
destroy all
save all
shell mkdir -p result
shell rm -f ./result/tb_cg_network_summary.txt

* Initialize summary report table header
echo \\"==================================================================================================================================\\" >> ./result/tb_cg_network_summary.txt
echo \\" Tap   Code   Target(dB)   Meas(dB)   Err(dB)    Err(Step)   Acc_FS(%)   -3dB BW(kHz)   Vos_out(mV)   V_vg_err(mV)   P_dc(uW) \\" >> ./result/tb_cg_network_summary.txt
echo \\"==================================================================================================================================\\" >> ./result/tb_cg_network_summary.txt

echo \\"==================================================================================================================================\\"
echo \\" STARTING BINARY GAIN-STAGE AC & DC CHARACTERIZATION (R TO 32R, S0 TO S5)                                                        \\"
echo \\"==================================================================================================================================\\"

* ------------------------------------------------------------------------------
* STEP 0: DC OFFSET PRE-CALIBRATION (NOMINAL TAP S0 AT 0 dB)
* ------------------------------------------------------------------------------
alter @vs1[dc] = 1.2
alter @vs2[dc] = 0
alter @vs3[dc] = 0
alter @vs4[dc] = 0
alter @vs5[dc] = 0
alter @vs6[dc] = 0

op
let v_vg_nominal = v(x1.net7)
echo \\" Calibrated Input DC Bias to Virtual Ground: \\" $&v_vg_nominal \\" V\\"

alter @v4[dc] = $&v_vg_nominal

set appendwrite

* ------------------------------------------------------------------------------
* STEP 1: SEQUENTIAL 6-TAP BINARY EVALUATION LOOP (S0 TO S5)
* ------------------------------------------------------------------------------
foreach tap 0 1 2 3 4 5

  * 1. Reset all 6 control switch gate voltages to 0V (OFF state)
  alter @vs1[dc] = 0
  alter @vs2[dc] = 0
  alter @vs3[dc] = 0
  alter @vs4[dc] = 0
  alter @vs5[dc] = 0
  alter @vs6[dc] = 0

  * 2. Assert active binary tap
  if ($tap = 0)
    alter @vs1[dc] = 1.2
  end
  if ($tap = 1)
    alter @vs2[dc] = 1.2
  end
  if ($tap = 2)
    alter @vs3[dc] = 1.2
  end
  if ($tap = 3)
    alter @vs4[dc] = 1.2
  end
  if ($tap = 4)
    alter @vs5[dc] = 1.2
  end
  if ($tap = 5)
    alter @vs6[dc] = 1.2
  end

  * 3. DC Operating Point Analysis
  op
  let cur_vos_mv = (v(out2) - v(vcm)) * 1e3
  let cur_vvg_mv = (v(x1.net7) - v(vcm)) * 1e3
  let cur_pdc_uw = -i(v2) * 1.2 * 1e6

  * Lock DC variables to shell environment BEFORE plot context switches to AC
  set s_vos = \\"$&cur_vos_mv\\"
  set s_vvg = \\"$&cur_vvg_mv\\"
  set s_pdc = \\"$&cur_pdc_uw\\"

  * 4. Small-Signal AC Frequency Response Analysis
  ac dec 30 10 100MEG

  let gain_db = db(v(out2))
  let ph_deg  = cph(v(out2)) * 180 / pi

  * Measure midband flatband gain at 1 kHz
  meas ac g_meas_db find gain_db at=1k

  * Measure -3 dB cutoff bandwidth
  let target_3db = g_meas_db - 3
  meas ac f_3db when gain_db=target_3db
  let f_3db_khz = f_3db / 1e3

  * 5. Binary Gain Metrics & dB-Based Error Computation
  let ideal_lin = 2^($tap)
  let ideal_db  = db(ideal_lin)
  let err_db    = g_meas_db - ideal_db
  let err_step  = err_db / 6.0206
  let acc_fs    = 100 - (abs(err_db) / 30.103 * 100)

  * Save curves into consolidated multi-run rawfile
  write ./result/tb_cg_network_all_taps.raw gain_db ph_deg

  * Lock remaining AC variables to shell environment
  set s_ideal = \\"$&ideal_db\\"
  set s_meas  = \\"$&g_meas_db\\"
  set s_err   = \\"$&err_db\\"
  set s_step  = \\"$&err_step\\"
  set s_acc   = \\"$&acc_fs\\"
  set s_f3db  = \\"$&f_3db_khz\\"

  * Print progress to terminal
  echo \\" S$tap | Target: $s_ideal dB | Meas: $s_meas dB | Err: $s_err dB ($s_step LSB) | BW: $s_f3db kHz | Vos: $s_vos mV\\"

  * Append telemetry row to text report
  echo \\" S$tap   | $tap    | $s_ideal       | $s_meas       | $s_err     | $s_step     | $s_acc    | $s_f3db        | $s_vos       | $s_vvg       | $s_pdc\\" >> ./result/tb_cg_network_summary.txt

end

unset appendwrite
echo \\"==================================================================================================================================\\"
echo \\" CHARACTERIZATION COMPLETED! Full telemetry log is exported to:                                                                 \\"
echo \\" ./result/tb_cg_network_summary.txt                                                                                             \\"
echo \\" Frequency response waveforms saved to: ./result/tb_cg_network_all_taps.raw                                                     \\"
echo \\"==================================================================================================================================\\"
.endc"}
C {capa.sym} 100 -340 0 0 {name=C1
m=1
value=\{cl\}
footprint=1206
device="ceramic capacitor"
}
C {lab_pin.sym} 100 -300 3 0 {name=p12 sig_type=std_logic lab=VSS
}
C {lab_pin.sym} 100 -390 1 0 {name=p13 sig_type=std_logic lab=OUT2
}
C {lab_pin.sym} 20 20 3 0 {name=p22 sig_type=std_logic lab=S5
}
C {lab_pin.sym} 40 20 3 0 {name=p23 sig_type=std_logic lab=S4
}
C {lab_pin.sym} 60 20 3 0 {name=p24 sig_type=std_logic lab=S3
}
C {lab_pin.sym} 80 20 3 0 {name=p25 sig_type=std_logic lab=S2
}
C {lab_pin.sym} 100 20 3 0 {name=p26 sig_type=std_logic lab=S1
}
C {lab_pin.sym} 120 20 3 0 {name=p27 sig_type=std_logic lab=S0
}
C {vsource.sym} -370 -200 0 0 {name=VS1 value=0 savecurrent=false}
C {vsource.sym} -310 -200 0 0 {name=VS2 value=0 savecurrent=false}
C {vsource.sym} -250 -200 0 0 {name=VS3 value=0 savecurrent=false}
C {vsource.sym} -190 -200 0 0 {name=VS4 value=0 savecurrent=false}
C {vsource.sym} -370 -100 0 0 {name=VS5 value=0 savecurrent=false}
C {vsource.sym} -310 -100 0 0 {name=VS6 value=0 savecurrent=false}
C {lab_pin.sym} -170 -160 2 0 {name=p28 sig_type=std_logic lab=VSS
}
C {lab_pin.sym} -290 -60 2 0 {name=p29 sig_type=std_logic lab=VSS
}
C {lab_pin.sym} -370 -250 1 0 {name=p32 sig_type=std_logic lab=S0
}
C {lab_pin.sym} -310 -250 1 0 {name=p33 sig_type=std_logic lab=S1
}
C {lab_pin.sym} -250 -250 1 0 {name=p34 sig_type=std_logic lab=S2
}
C {lab_pin.sym} -190 -250 1 0 {name=p35 sig_type=std_logic lab=S3
}
C {lab_pin.sym} -370 -150 0 0 {name=p36 sig_type=std_logic lab=S4
}
C {lab_pin.sym} -310 -150 0 0 {name=p37 sig_type=std_logic lab=S5
}
C {vsource.sym} 180 -350 0 0 {name=V4 value="DC 0.6 AC 1" savecurrent=false
}
C {lab_pin.sym} 190 -410 2 0 {name=p48 sig_type=std_logic lab=IN2
}
C {lab_pin.sym} 180 -300 3 0 {name=p49 sig_type=std_logic lab=VSS
}
C {launcher.sym} -130 130 0 0 {name=h5
descr=SimulateNGSPICE
tclcommand="
# Setup the default simulation commands if not already set up
# for example by already launched simulations.
set_sim_defaults
puts $sim(spice,1,cmd) 

# Change the Xyce command. In the spice category there are currently
# 5 commands (0, 1, 2, 3, 4). Command 3 is the Xyce batch
# you can get the number by querying $sim(spice,n)
set sim(spice,1,cmd) \{ngspice  \\"$N\\" -a\}

# change the simulator to be used (Xyce)
set sim(spice,default) 0

# Create FET .save file
mkdir -p $netlist_dir
write_data [save_params] $netlist_dir/[file rootname [file tail [xschem get current_name]]].save

# run netlist and simulation
xschem netlist
xschem simulate
"}
C {simulator_commands_shown.sym} -220 -680 0 0 {name=Include_STDCELLS
simulator=ngspice
only_toplevel=false
value=".include $PDK_ROOT/$PDK/libs.ref/sg13cmos5l_stdcell/spice/sg13cmos5l_stdcell.spice
"
      }
C {launcher.sym} -130 90 0 0 {name=h1
descr=xschemrc
tclcommand="source xschemrc"}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/coarse_gain/cg_network.sym} 110 50 0 0 {name=x1}
