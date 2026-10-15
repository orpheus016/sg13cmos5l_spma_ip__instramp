v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
L 4 -430 -200 -430 460 {}
L 4 -430 460 -430 520 {}
L 4 -430 520 490 520 {}
L 4 490 -700 490 520 {}
L 4 -430 -700 490 -700 {}
L 4 -430 -700 -430 -190 {}
L 4 -430 -200 490 -200 {}
L 4 -80 -200 -80 520 {}
L 4 -80 200 490 200 {}
N -250 330 -250 340 {lab=VDD}
N -170 330 -170 350 {lab=VDD}
N -170 410 -170 430 {lab=I_B}
N -250 400 -250 420 {lab=0}
N -340 400 -340 420 {lab=0}
N -340 330 -340 340 {lab=VSS}
N 190 -160 190 -140 {lab=I_B}
N 220 -160 220 -140 {lab=VDD}
N 360 10 360 30 {lab=VSS}
N 360 30 370 30 {lab=VSS}
N -340 210 -340 230 {lab=VSS
}
N -340 120 -330 120 {lab=VCM
}
N -340 120 -340 150 {lab=VCM
}
N -10 -60 10 -60 {lab=VCM}
N -10 -80 10 -80 {lab=IN2}
N 390 -70 410 -70 {lab=OUT2}
N -250 230 -250 240 {lab=VSS
}
N -250 150 -250 170 {lab=OUT2
}
N 190 10 190 40 {lab=D7}
N 80 10 80 40 {lab=D4}
N 120 10 120 40 {lab=D5}
N 160 10 160 40 {lab=D6}
N 230 10 230 40 {lab=D8}
N 260 10 260 40 {lab=D9}
N -350 70 -350 80 {lab=VSS}
N -290 80 -150 80 {lab=VSS}
N -290 70 -290 80 {lab=VSS}
N -350 80 -290 80 {lab=VSS}
N -350 -30 -350 -20 {lab=VSS}
N -230 -20 -170 -20 {lab=VSS}
N -170 -30 -170 -20 {lab=VSS}
N -290 -30 -290 -20 {lab=VSS}
N -350 -20 -290 -20 {lab=VSS}
N -230 -30 -230 -20 {lab=VSS}
N -290 -20 -230 -20 {lab=VSS}
N -170 -20 -150 -20 {lab=VSS}
N -350 -110 -350 -90 {lab=D4}
N -290 -110 -290 -90 {lab=D5}
N -230 -110 -230 -90 {lab=D6}
N -170 -110 -170 -90 {lab=D7}
N -350 -10 -350 10 {lab=D8}
N -290 -10 -290 10 {lab=D9}
N -170 220 -170 240 {lab=VSS
}
N -170 130 -160 130 {lab=IN2
}
N -170 130 -170 160 {lab=IN2
}
N 170 -160 190 -160 {lab=I_B}
C {isource.sym} -170 380 0 0 {name=I0 value=\{ib\}}
C {vsource.sym} -250 370 0 0 {name=V2 value=\{vdd\} savecurrent=false}
C {gnd.sym} -250 420 0 0 {name=l1 lab=0}
C {vdd.sym} -250 330 0 0 {name=l3 lab=VDD}
C {vdd.sym} -170 330 0 0 {name=l4 lab=VDD}
C {lab_pin.sym} -170 430 3 0 {name=p7 sig_type=std_logic lab=I_B}
C {vsource.sym} -340 370 0 0 {name=V3 value=0 savecurrent=false}
C {gnd.sym} -340 420 0 0 {name=l7 lab=0}
C {lab_pin.sym} -340 330 1 0 {name=p3 sig_type=std_logic lab=VSS
}
C {simulator_commands_shown.sym} -380 -310 0 0 {name=General_Params
simulator=ngspice
only_toplevel=false
value=".param temp=27
.param cl=2p
.param ib=10u
.param vdd=1.2
.param vicm=vdd/2
"
      }
C {simulator_commands_shown.sym} -390 -520 0 0 {name=Libs_Ngspice_Typ
simulator=ngspice
only_toplevel=false
value="tcleval(
.lib /foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models/cornerMOSlv.lib mos_tt
.lib /foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models/cornerMOShv.lib mos_tt
.lib /foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models/cornerRES.lib res_typ
.lib /foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models/cornerDIO.lib dio_tt
.lib /foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models/cornerCAP.lib cap_typ
.lib /foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models/cornerMOSCAP.lib moscap_tt
)"
      }
C {lab_pin.sym} 170 -160 0 0 {name=p1 sig_type=std_logic lab=I_B}
C {vdd.sym} 220 -160 0 0 {name=l2 lab=VDD}
C {lab_pin.sym} 370 30 2 0 {name=p2 sig_type=std_logic lab=VSS
}
C {vsource.sym} -340 180 0 0 {name=V1 value=\{vicm\} savecurrent=false
}
C {lab_pin.sym} -330 120 2 0 {name=p10 sig_type=std_logic lab=VCM
}
C {lab_pin.sym} -340 230 3 0 {name=p8 sig_type=std_logic lab=VSS
}
C {lab_pin.sym} -10 -60 0 0 {name=p4 sig_type=std_logic lab=VCM
}
C {lab_pin.sym} -10 -80 0 0 {name=p5 sig_type=std_logic lab=IN2}
C {lab_pin.sym} 410 -70 2 0 {name=p6 sig_type=std_logic lab=OUT2}
C {simulator_commands.sym} -20 330 0 0 {name=16_LEVELS_SWEEP
simulator=ngspice
only_toplevel=false 
value=".control
* ==============================================================================
* FINE-GAIN NETWORK 64-TAP BINARY AUTOMATED CHARACTERIZATION
* ==============================================================================
destroy all
save all
shell mkdir -p result
shell rm -f ./result/tb_fg_network_summary.txt

echo "===========================================================================================================" >> ./result/tb_fg_network_summary.txt
echo " Tap    Target(dB)    Meas(dB)    Err(dB)    -3dB BW(Hz)    Vos_out(mV)    P_dc(uW)" >> ./result/tb_fg_network_summary.txt
echo "===========================================================================================================" >> ./result/tb_fg_network_summary.txt

echo "STARTING 64-TAP BINARY SWEEP..."

let tap = 0
while tap < 64
  * Convert decimal tap to 6-bit binary for D4(LSB) to D9(MSB)
  let bit0 = tap % 2
  let temp1 = floor(tap / 2)
  let bit1 = temp1 % 2
  let temp2 = floor(temp1 / 2)
  let bit2 = temp2 % 2
  let temp3 = floor(temp2 / 2)
  let bit3 = temp3 % 2
  let temp4 = floor(temp3 / 2)
  let bit4 = temp4 % 2
  let temp5 = floor(temp4 / 2)
  let bit5 = temp5 % 2

  * Apply logic voltages (1.2V or 0V) to VS1-VS6
  alter @vs1[dc] = bit0 * 1.2
  alter @vs2[dc] = bit1 * 1.2
  alter @vs3[dc] = bit2 * 1.2
  alter @vs4[dc] = bit3 * 1.2
  alter @vs5[dc] = bit4 * 1.2
  alter @vs6[dc] = bit5 * 1.2

  * 1. Run DC Operating Point
  op
  let cur_pdc_uw = -i(v2) * 1.2 * 1e6
  let cur_vos_mv = (v(out2) - 0.6) * 1e3

  * 2. Run AC Analysis
  ac dec 30 10 100MEG
  let gain_db = db(v(out2))
  
  * Measure midband gain at 1 kHz
  meas ac g_meas_db find gain_db at=1k
  
  * Measure -3 dB bandwidth
  let target_3db = g_meas_db - 3
  meas ac f_3db when gain_db=target_3db

  * 3. Calculate Error (0.0581 dB per step)
  let ideal_db = tap * 0.0581
  let err_db = g_meas_db - ideal_db

  * 4. Log to Terminal and File
  echo "Tap $&tap | Tgt: $&ideal_db dB | Meas: $&g_meas_db dB | Err: $&err_db dB | BW: $&f_3db Hz | P_dc: $&cur_pdc_uw uW"
  echo " $&tap      $&ideal_db      $&g_meas_db      $&err_db      $&f_3db      $&cur_vos_mv      $&cur_pdc_uw" >> ./result/tb_fg_network_summary.txt

  let tap = tap + 1
end

echo "CHARACTERIZATION COMPLETED! Log exported to ./result/tb_fg_network_summary.txt"
.endc"}
C {capa.sym} -250 200 0 0 {name=C1
m=1
value=\{cl\}
footprint=1206
device="ceramic capacitor"
}
C {lab_pin.sym} -250 240 3 0 {name=p12 sig_type=std_logic lab=VSS
}
C {lab_pin.sym} -250 150 1 0 {name=p13 sig_type=std_logic lab=OUT2
}
C {lab_pin.sym} 260 40 3 0 {name=p23 sig_type=std_logic lab=D9

}
C {vsource.sym} -350 -60 0 0 {name=VS1 value=0 savecurrent=false}
C {vsource.sym} -290 -60 0 0 {name=VS2 value=0 savecurrent=false}
C {vsource.sym} -230 -60 0 0 {name=VS3 value=0 savecurrent=false}
C {vsource.sym} -170 -60 0 0 {name=VS4 value=0 savecurrent=false}
C {vsource.sym} -350 40 0 0 {name=VS5 value=0 savecurrent=false}
C {vsource.sym} -290 40 0 0 {name=VS6 value=0 savecurrent=false}
C {lab_pin.sym} -150 -20 2 0 {name=p28 sig_type=std_logic lab=VSS
}
C {lab_pin.sym} -150 80 2 0 {name=p29 sig_type=std_logic lab=VSS
}
C {lab_pin.sym} -350 -110 1 0 {name=p32 sig_type=std_logic lab=D4
}
C {lab_pin.sym} -290 -110 1 0 {name=p33 sig_type=std_logic lab=D5
}
C {lab_pin.sym} -230 -110 1 0 {name=p34 sig_type=std_logic lab=D6
}
C {lab_pin.sym} -170 -110 1 0 {name=p35 sig_type=std_logic lab=D7

}
C {lab_pin.sym} -350 -10 0 0 {name=p36 sig_type=std_logic lab=D8
}
C {lab_pin.sym} -290 -10 0 0 {name=p37 sig_type=std_logic lab=D9
}
C {vsource.sym} -170 190 0 0 {name=V4 value="DC 0.6 AC 1" savecurrent=false
}
C {lab_pin.sym} -160 130 2 0 {name=p48 sig_type=std_logic lab=IN2
}
C {lab_pin.sym} -170 240 3 0 {name=p49 sig_type=std_logic lab=VSS
}
C {launcher.sym} 230 400 0 0 {name=h5
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
C {simulator_commands_shown.sym} -390 -630 0 0 {name=Include_STDCELLS
simulator=ngspice
only_toplevel=false
value=".include $PDK_ROOT/$PDK/libs.ref/sg13cmos5l_stdcell/spice/sg13cmos5l_stdcell.spice
"
      }
C {launcher.sym} 230 360 0 0 {name=h1
descr=xschemrc
tclcommand="source xschemrc"}
C {fine_gain.sym} 200 -70 0 0 {name=x1}
C {lab_pin.sym} 80 40 3 0 {name=p9 sig_type=std_logic lab=D4

}
C {lab_pin.sym} 120 40 3 0 {name=p11 sig_type=std_logic lab=D5

}
C {lab_pin.sym} 160 40 3 0 {name=p14 sig_type=std_logic lab=D6

}
C {lab_pin.sym} 190 40 3 0 {name=p15 sig_type=std_logic lab=D7


}
C {lab_pin.sym} 230 40 3 0 {name=p16 sig_type=std_logic lab=D8


}
C {simulator_commands_shown.sym} -200 -310 0 0 {name=Fine_Gain Params
simulator=ngspice
only_toplevel=false
value=".param W_RES=1u L_R=35.18u L_2R=70.475u
.param W_TG_N=10u L_TG_N=0.13u NG_TG_N=2
.param W_TG_P=30u L_TG_P=0.13u NG_TG_P=6
.param W_INV_N=2u L_INV_N=0.13u NG_INV_N=1
.param W_INV_P=6u L_INV_P=0.13u NG_INV_P=1
"
      }
C {title.sym} -360 570 0 0 {name=l5 author="Ibrahim Hanif M"}
