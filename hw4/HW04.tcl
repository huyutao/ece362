
########## Tcl recorder starts at 09/29/16 22:01:30 ##########

set version "1.7"
set proj_dir "U:/Personal/hw4"
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
if [runCmd "\"$cpld_bin/ahdl2blf\" hw04.abl -ojhd only -def _AMDMACH_ _MACH_ _LSI5K_ _LATTICE_ _PLSI_ _MACH4ZE_  -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 09/29/16 22:01:30 ###########


########## Tcl recorder starts at 09/29/16 22:01:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/ahdl2blf\" hw04.abl -ojhd only -def _AMDMACH_ _MACH_ _LSI5K_ _LATTICE_ _PLSI_ _MACH4ZE_  -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 09/29/16 22:01:33 ###########


########## Tcl recorder starts at 09/29/16 22:01:38 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/ahdl2blf\" hw04.abl -mod MemExpPri2 -ojhd compile -ret -def _AMDMACH_ _MACH_ _LSI5K_ _LATTICE_ _PLSI_ _MACH4ZE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" MemExpPri2.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"MemExpPri2.bl1\" -o \"hw04.bl2\" -omod \"hw04\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj hw04 -lci hw04.lct -log hw04.imp -err automake.err -tti hw04.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci hw04.lct -blifopt hw04.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" hw04.bl2 -sweep -mergefb -err automake.err -o hw04.bl3 @hw04.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci hw04.lct -dev lc4k -diofft hw04.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" hw04.bl3 -family AMDMACH -idev van -o hw04.bl4 -oxrf hw04.xrf -err automake.err @hw04.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci hw04.lct -dev lc4k -prefit hw04.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp hw04.bl4 -out hw04.bl5 -err automake.err -log hw04.log -mod MemExpPri2 @hw04.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open hw04.rs1 w} rspFile] {
	puts stderr "Cannot create response file hw04.rs1: $rspFile"
} else {
	puts $rspFile "-i hw04.bl5 -lci hw04.lct -d m4s_32_32 -lco hw04.lco -html_rpt -fti hw04.fti -fmt PLA -tto hw04.tt4 -nojed -eqn hw04.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open hw04.rs2 w} rspFile] {
	puts stderr "Cannot create response file hw04.rs2: $rspFile"
} else {
	puts $rspFile "-i hw04.bl5 -lci hw04.lct -d m4s_32_32 -lco hw04.lco -html_rpt -fti hw04.fti -fmt PLA -tto hw04.tt4 -eqn hw04.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@hw04.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete hw04.rs1
file delete hw04.rs2
if [runCmd "\"$cpld_bin/tda\" -i hw04.bl5 -o hw04.tda -lci hw04.lct -dev m4s_32_32 -family lc4k -mod MemExpPri2 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj hw04 -if hw04.jed -j2s -log hw04.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 09/29/16 22:01:38 ###########


########## Tcl recorder starts at 09/29/16 22:02:15 ##########

# Commands to make the Process: 
# Timing Analysis
if [runCmd "\"$cpld_bin/impsrc\"  -prj hw04 -lci hw04.lct -log hw04.imp -err automake.err -tti hw04.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci hw04.lct -blifopt hw04.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" hw04.bl2 -sweep -mergefb -err automake.err -o hw04.bl3 @hw04.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci hw04.lct -dev lc4k -diofft hw04.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" hw04.bl3 -family AMDMACH -idev van -o hw04.bl4 -oxrf hw04.xrf -err automake.err @hw04.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci hw04.lct -dev lc4k -prefit hw04.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp hw04.bl4 -out hw04.bl5 -err automake.err -log hw04.log -mod MemExpPri2 @hw04.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open hw04.rs1 w} rspFile] {
	puts stderr "Cannot create response file hw04.rs1: $rspFile"
} else {
	puts $rspFile "-i hw04.bl5 -lci hw04.lct -d m4s_32_30 -lco hw04.lco -html_rpt -fti hw04.fti -fmt PLA -tto hw04.tt4 -nojed -eqn hw04.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open hw04.rs2 w} rspFile] {
	puts stderr "Cannot create response file hw04.rs2: $rspFile"
} else {
	puts $rspFile "-i hw04.bl5 -lci hw04.lct -d m4s_32_30 -lco hw04.lco -html_rpt -fti hw04.fti -fmt PLA -tto hw04.tt4 -eqn hw04.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@hw04.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete hw04.rs1
file delete hw04.rs2
if [runCmd "\"$cpld_bin/tda\" -i hw04.bl5 -o hw04.tda -lci hw04.lct -dev m4s_32_30 -family lc4k -mod MemExpPri2 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj hw04 -if hw04.jed -j2s -log hw04.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Timing Analysis
if [runCmd "\"$cpld_bin/timing\" -prj \"hw04\" -tti \"hw04.tt4\" -gui -dir \"$proj_dir\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 09/29/16 22:02:15 ###########


########## Tcl recorder starts at 09/29/16 23:09:17 ##########

# Commands to make the Process: 
# Timing Analysis
if [runCmd "\"$cpld_bin/impsrc\"  -prj hw04 -lci hw04.lct -log hw04.imp -err automake.err -tti hw04.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci hw04.lct -blifopt hw04.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" hw04.bl2 -sweep -mergefb -err automake.err -o hw04.bl3 @hw04.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci hw04.lct -dev lc4k -diofft hw04.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" hw04.bl3 -family AMDMACH -idev van -o hw04.bl4 -oxrf hw04.xrf -err automake.err @hw04.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci hw04.lct -dev lc4k -prefit hw04.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp hw04.bl4 -out hw04.bl5 -err automake.err -log hw04.log -mod MemExpPri2 @hw04.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open hw04.rs1 w} rspFile] {
	puts stderr "Cannot create response file hw04.rs1: $rspFile"
} else {
	puts $rspFile "-i hw04.bl5 -lci hw04.lct -d m4s_32_30 -lco hw04.lco -html_rpt -fti hw04.fti -fmt PLA -tto hw04.tt4 -nojed -eqn hw04.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open hw04.rs2 w} rspFile] {
	puts stderr "Cannot create response file hw04.rs2: $rspFile"
} else {
	puts $rspFile "-i hw04.bl5 -lci hw04.lct -d m4s_32_30 -lco hw04.lco -html_rpt -fti hw04.fti -fmt PLA -tto hw04.tt4 -eqn hw04.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@hw04.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete hw04.rs1
file delete hw04.rs2
if [runCmd "\"$cpld_bin/tda\" -i hw04.bl5 -o hw04.tda -lci hw04.lct -dev m4s_32_30 -family lc4k -mod MemExpPri2 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj hw04 -if hw04.jed -j2s -log hw04.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Timing Analysis
if [runCmd "\"$cpld_bin/timing\" -prj \"hw04\" -tti \"hw04.tt4\" -gui -dir \"$proj_dir\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 09/29/16 23:09:17 ###########


########## Tcl recorder starts at 09/29/16 23:09:32 ##########

# Commands to make the Process: 
# Timing Analysis
# - none -
# Application to view the Process: 
# Timing Analysis
if [runCmd "\"$cpld_bin/timing\" -prj \"hw04\" -tti \"hw04.tt4\" -gui -dir \"$proj_dir\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 09/29/16 23:09:32 ###########

