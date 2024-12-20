#Reading lib and hdl files
set_db init_lib_search_path /home/ahmarhabib/TCP/lib
set_db init_hdl_search_path /home/ahmarhabib/TCP/Design
read_libs tcbn12ffcllbwp16p90ssgnp0p9v125c_ccs.lib
read_hdl -sv ALU_MM.sv


set_db tns_opto true  
set_db information_level 3

#elaborate the design
elaborate
check_timing_intent 

#Reading constraint file
read_sdc /home/ahmarhabib/TCP/Constraints/constraints.sdc

#Setting synthesis efforts
set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort high

#Synthesizing,mapping and optimizing the design
syn_generic
syn_map
syn_opt

#retime -min_delay -effort high
#Generating reports
report_timing > reports/timing.rpt
report_power > reports/power.rpt
report_area -detail > reports/area.rpt
report_qor > reports/qor.rpt

#Generating outputs
write_hdl > outputs/netlist.v
write_sdc > outputs/design_sdc.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > outputs/delays.sdf

