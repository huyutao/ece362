
########## Tcl recorder starts at 10/05/16 18:07:12 ##########

set version "1.7"
set proj_dir "U:/Personal/ece362lab7"
cd $proj_dir

# Get directory paths
set pver $version
regsub -all {\.} $pver {_} pver
set lscfile "lsc_"
append lscfile $pver ".ini"
set lsvini_dir [lindex [array get env LSC_INI_PATH] 1]
set lsvini_path [file join $lsvini_dir $lscfile]
if {[catch {set fid [open $lsvini_path]} msg]} {
	 puts "File Open Error: $lsvini_path"
	 return false
} else {set data [read $fid]; close $fid }
foreach line [split $data '\n'] { 
	set lline [string tolower $line]
	set lline [string trim $lline]
	if {[string compare $lline "\[paths\]"] == 0} { set path 1; continue}
	if {$path && [regexp {^\[} $lline]} {set path 0; break}
	if {$path && [regexp {^bin} $lline]} {set cpld_bin $line; continue}
	if {$path && [regexp {^fpgapath} $lline]} {set fpga_dir $line; continue}
	if {$path && [regexp {^fpgabinpath} $lline]} {set fpga_bin $line}}

set cpld_bin [string range $cpld_bin [expr [string first "=" $cpld_bin]+1] end]
regsub -all "\"" $cpld_bin "" cpld_bin
set cpld_bin [file join $cpld_bin]
set install_dir [string range $cpld_bin 0 [expr [string first "ispcpld" $cpld_bin]-2]]
regsub -all "\"" $install_dir "" install_dir
set install_dir [file join $install_dir]
set fpga_dir [string range $fpga_dir [expr [string first "=" $fpga_dir]+1] end]
regsub -all "\"" $fpga_dir "" fpga_dir
set fpga_dir [file join $fpga_dir]
set fpga_bin [string range $fpga_bin [expr [string first "=" $fpga_bin]+1] end]
regsub -all "\"" $fpga_bin "" fpga_bin
set fpga_bin [file join $fpga_bin]

if {[string match "*$fpga_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$fpga_bin;$env(PATH)" }

if {[string match "*$cpld_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$cpld_bin;$env(PATH)" }

lappend auto_path [file join $install_dir "ispcpld" "tcltk" "lib" "ispwidget" "runproc"]
package require runcmd

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -ojhd only -def _PLSI_ _LATTICE_ -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 18:07:12 ###########


########## Tcl recorder starts at 10/05/16 18:17:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -ojhd only -def _PLSI_ _LATTICE_ -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 18:17:45 ###########


########## Tcl recorder starts at 10/05/16 18:17:50 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -mod lab6 -ojhd compile -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"lab6.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"lab6.bl1\" -o \"untitled.bl2\" -omod lab6 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 18:17:50 ###########


########## Tcl recorder starts at 10/05/16 18:17:57 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" untitled.tt3 -dev p22v10g -o untitled.jed -ivec NoInput.tmv -rep untitled.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj untitled -if untitled.jed -j2s -log untitled.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 18:17:57 ###########


########## Tcl recorder starts at 10/05/16 19:24:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -ojhd only -def _PLSI_ _LATTICE_ -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:24:18 ###########


########## Tcl recorder starts at 10/05/16 19:24:27 ##########

# Commands to make the Process: 
# Compile Logic
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -mod lab6 -ojhd compile -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:24:27 ###########


########## Tcl recorder starts at 10/05/16 19:25:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -ojhd only -def _PLSI_ _LATTICE_ -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:25:06 ###########


########## Tcl recorder starts at 10/05/16 19:25:18 ##########

# Commands to make the Process: 
# Compile Logic
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -mod lab6 -ojhd compile -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:25:18 ###########


########## Tcl recorder starts at 10/05/16 19:25:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -ojhd only -def _PLSI_ _LATTICE_ -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:25:31 ###########


########## Tcl recorder starts at 10/05/16 19:25:34 ##########

# Commands to make the Process: 
# Compile Logic
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -mod lab6 -ojhd compile -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:25:34 ###########


########## Tcl recorder starts at 10/05/16 19:25:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -ojhd only -def _PLSI_ _LATTICE_ -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:25:59 ###########


########## Tcl recorder starts at 10/05/16 19:26:01 ##########

# Commands to make the Process: 
# Compile Logic
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -mod lab6 -ojhd compile -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:26:01 ###########


########## Tcl recorder starts at 10/05/16 19:34:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -ojhd only -def _PLSI_ _LATTICE_ -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:34:09 ###########


########## Tcl recorder starts at 10/05/16 19:34:15 ##########

# Commands to make the Process: 
# Compile Logic
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -mod lab6 -ojhd compile -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:34:15 ###########


########## Tcl recorder starts at 10/05/16 19:34:22 ##########

# Commands to make the Process: 
# Compile Logic
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -mod lab6 -ojhd compile -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:34:22 ###########


########## Tcl recorder starts at 10/05/16 19:34:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -ojhd only -def _PLSI_ _LATTICE_ -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:34:25 ###########


########## Tcl recorder starts at 10/05/16 19:34:28 ##########

# Commands to make the Process: 
# Compile Logic
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -mod lab6 -ojhd compile -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:34:28 ###########


########## Tcl recorder starts at 10/05/16 19:35:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -ojhd only -def _PLSI_ _LATTICE_ -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:35:34 ###########


########## Tcl recorder starts at 10/05/16 19:35:37 ##########

# Commands to make the Process: 
# Compile Logic
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -mod lab6 -ojhd compile -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:35:37 ###########


########## Tcl recorder starts at 10/05/16 19:36:01 ##########

# Commands to make the Process: 
# Reduce Logic
if [runCmd "\"$cpld_bin/iblifopt\" \"lab6.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:36:01 ###########


########## Tcl recorder starts at 10/05/16 19:36:11 ##########

# Commands to make the Process: 
# Compiled Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"lab6.bl0\" -o \"lab6.eq0\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:36:11 ###########


########## Tcl recorder starts at 10/05/16 19:36:13 ##########

# Commands to make the Process: 
# Compiler Listing
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -mod lab6 -syn -list -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:36:13 ###########


########## Tcl recorder starts at 10/05/16 19:36:23 ##########

# Commands to make the Process: 
# Check Syntax
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -mod lab6 -syn -prj untitled -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:36:23 ###########


########## Tcl recorder starts at 10/05/16 19:36:43 ##########

# Commands to make the Process: 
# Check Syntax
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -mod lab6 -syn -prj untitled -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:36:43 ###########


########## Tcl recorder starts at 10/05/16 19:36:53 ##########

# Commands to make the Process: 
# Reduced Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"lab6.bl1\" -o \"lab6.eq1\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:36:53 ###########


########## Tcl recorder starts at 10/05/16 19:36:58 ##########

# Commands to make the Process: 
# VHDL Test Bench Template
if [runCmd "\"$cpld_bin/blif2eqn\" \"lab6.bl0\" -testfixture -template \"$install_dir/ispcpld/generic/vhdl/testbnch.tft\" -bus rebuild -o \"lab6.vht\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:36:58 ###########


########## Tcl recorder starts at 10/05/16 19:37:00 ##########

# Commands to make the Process: 
# Verilog Test Fixture Template
if [runCmd "\"$cpld_bin/blif2eqn\" \"lab6.bl0\" -o \"lab6.tft\" -template \"$install_dir/ispcpld/generic/verilog/tft.tft\" -testfix -bus rebuild -prj untitled -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:37:00 ###########


########## Tcl recorder starts at 10/05/16 19:37:02 ##########

# Commands to make the Process: 
# Verilog Test Fixture Declarations
if [runCmd "\"$cpld_bin/blif2eqn\" \"lab6.bl0\" -o \"lab6.tfi\" -template \"$install_dir/ispcpld/generic/verilog/tfi.tft\" -testfix -bus rebuild -prj untitled -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:37:02 ###########


########## Tcl recorder starts at 10/05/16 19:37:04 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"lab6\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:37:04 ###########


########## Tcl recorder starts at 10/05/16 19:37:07 ##########

# Commands to make the Process: 
# ABEL Test Vector Template
if [runCmd "\"$cpld_bin/blif2eqn\" \"lab6.bl0\" -o \"lab6.abt\" -testfix -template \"$install_dir/ispcpld/plsi/abel/plsiabt.tft\" -prj untitled -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:37:07 ###########


########## Tcl recorder starts at 10/05/16 19:37:16 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblflink\" \"lab6.bl1\" -o \"untitled.bl2\" -omod lab6 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:37:16 ###########


########## Tcl recorder starts at 10/05/16 19:37:19 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" untitled.tt3 -dev p22v10g -o untitled.jed -ivec NoInput.tmv -rep untitled.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj untitled -if untitled.jed -j2s -log untitled.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:37:19 ###########


########## Tcl recorder starts at 10/05/16 19:41:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -ojhd only -def _PLSI_ _LATTICE_ -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:41:48 ###########


########## Tcl recorder starts at 10/05/16 19:41:53 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/ahdl2blf\" \"lab6.abl\" -mod lab6 -ojhd compile -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"lab6.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"lab6.bl1\" -o \"untitled.bl2\" -omod lab6 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:41:53 ###########


########## Tcl recorder starts at 10/05/16 19:41:57 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" untitled.tt3 -dev p22v10g -o untitled.jed -ivec NoInput.tmv -rep untitled.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj untitled -if untitled.jed -j2s -log untitled.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 10/05/16 19:41:57 ###########

