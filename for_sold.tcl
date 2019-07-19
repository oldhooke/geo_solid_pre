# HWVERSION_2017.1_Apr 12 2017_22:30:32
#################################################################
# File      : hm_tab.tcl
# Date      : June 7, 2007
# Created by: Liu Dongliang
# Purpose   : Creates a GUI to help manage test gauges
#################################################################
package require hwt;
package require hwtk;

catch {namespace delete ::hm::MyTab }

namespace eval ::hm::MyTab {
    variable m_title "MyTab";
	variable m_recess ".m_MyTab";
}

#################################################################
proc ::hm::MyTab::Answer { question type } {
	return [tk_messageBox \
			-title "Question"\
			-icon info \
			-message "$question" \
			-type $type]
}

#################################################################
proc ::hm::MyTab::DialogCreate { args } {
    # Purpose:  Creates the tab and the master frame
    # Args:
    # Returns:  1 for success. 0 if the tab already exists.
    # Notes:

    variable m_recess;
    variable m_title;

    set alltabs [hm_framework getalltabs];

    if {[lsearch $alltabs $m_title] != -1} {
        hm_framework activatetab "$m_title";

        return 0;
    } else {
        catch {destroy $m_recess};

        set m_recess [frame $m_recess -padx 7 -pady 7];

        hm_framework addtab "$m_title" $m_recess ::hm::MyTab::Resize ::hm::MyTab::TearDownWindow;

        ::hwt::AddPadding $m_recess -side top height [hwt::DluHeight 4] width [hwt::DluWidth 0];

        return 1;
    }
}

#################################################################
proc ::hm::MyTab::Resize { args } {
    # Purpose:  Resize the tab
    # Args:
    # Returns:  Size to resize the tab to
    # Notes:

    return 358;
}

#################################################################
proc ::hm::MyTab::TearDownWindow { flag args } {
    # Purpose:  Destroy the tab and frame when the GUI is closed.
    # Args:     flag - hm_framework flag that is passed to tell
    #           the proc when it is being called.
    # Returns:
    # Notes:

    variable m_recess;
    variable m_title;

    if {$flag == "after_deactivate"} {
        catch {::hm::MyTab::UnsetCallbacks};
        catch {destroy $m_recess };
        hm_framework removetab "$m_title";

        focus -force $::HM_Framework::p_hm_container;
    }
}

#################################################################
proc ::hm::MyTab::SetCallbacks { args } {
    # Purpose:  Defines the callbacks
    # Args:
    # Returns:
    # Notes:

    #~ ::hwt::AddCallback *readfile ::hm::MyTab::New;
    #~ ::hwt::AddCallback *deletemodel ::hm::MyTab::New;
	
    #~ ::hwt::AddCallback *deletemark ::hm::MyTab::RemoveSystem before
}

#################################################################
proc ::hm::MyTab::UnsetCallbacks { args } {
    # Purpose:  Undefines the callbacks when the tab is closed
    # Args:
    # Returns:
    # Notes:

    #~ ::hwt::RemoveCallback *readfile ::hm::MyTab::New;
    #~ ::hwt::RemoveCallback *deletemodel ::hm::MyTab::New;
	
    #~ ::hwt::RemoveCallback *deletemark ::hm::MyTab::RemoveSystem;
}

#################################################################

#################################################################
proc ::hm::MyTab::Main { args } {
    # Purpose:  Creates the GUI and calls the routine to populate
    #           the table.
    # Args:
    # Returns:
    # Notes:
	
    variable m_recess;
	variable m_width 12;
	
	variable m_mass_unit "ton";
	variable m_mass_factor 1;
	variable m_length_unit "mm";
	variable m_length_factor 1;
	variable m_time_unit "s";
	variable m_time_factor 1;
    
    # Create the GUI
    if [::hm::MyTab::DialogCreate] {
        # Create the frame1
		set frame1 [labelframe $m_recess.frame1 -text "Units and scale factor" ];
		# state : normal disabled readonly
		set comb_state normal
        pack $frame1 -side top -anchor nw -fill x ;
			::hwtk::label $frame1.l1 -text "Mass:"
			hwtk::entry $frame1.e11 -textvariable [namespace current]::m_mass_factor -inputtype double 
			hwtk::combobox $frame1.e12 -textvariable [namespace current]::m_mass_unit -state $comb_state -values {ton kg}
			grid $frame1.l1 $frame1.e11 $frame1.e12 -sticky w -pady 2 -padx 5
			grid configure $frame1.e11 -sticky ew
			grid configure $frame1.e12 -sticky ew
			
			::hwtk::label $frame1.l2 -text "Length:"
			hwtk::entry $frame1.e21 -textvariable [namespace current]::m_length_factor -inputtype double
			hwtk::combobox $frame1.e22 -textvariable [namespace current]::m_length_unit -state $comb_state -values {mm m}
			grid $frame1.l2 $frame1.e21 $frame1.e22 -sticky w -pady 2 -padx 5
			grid configure $frame1.e21 -sticky ew
			grid configure $frame1.e22 -sticky ew
			
			::hwtk::label $frame1.l3 -text "Time:"
			hwtk::entry $frame1.e31 -textvariable [namespace current]::m_time_factor -inputtype double
			hwtk::combobox $frame1.e32 -textvariable [namespace current]::m_time_unit -state $comb_state -values {s ms}
			grid $frame1.l3 $frame1.e31 $frame1.e32 -sticky w -pady 2 -padx 5
			grid configure $frame1.e31 -sticky ew
			grid configure $frame1.e32 -sticky ew
			
			grid columnconfigure $frame1 1  -weight 1
			grid columnconfigure $frame1 2  -weight 1
			
		# Create the frame2
		set frame2 [labelframe $m_recess.frame2 -text "Command" ];
        pack $frame2 -side top -anchor nw -fill x ;
			::hwtk::button $frame2.trim_comps -text "trim cross comps" -help "trim cross comps" -command { ::hm::MyTab::trim_comps }
			::hwtk::button $frame2.find_face_elem -text "find face elem" -help "find face elem" -command { ::hm::MyTab::find_face_elem }
			::hwtk::button $frame2.rigid_master_mass -text "rigid master mass" -help "rigid master mass" -command { ::hm::MyTab::rigid_master_mass }
			grid $frame2.trim_comps $frame2.find_face_elem -sticky ew
			grid $frame2.rigid_master_mass -sticky ew
			
			grid columnconfigure $frame2 "all" -weight 1
		
		# Create the frame3
		set frame3 [labelframe $m_recess.frame3 -text "tools" ];
		pack $frame3 -side top -anchor nw -fill x ;
			::hwtk::button $frame3.fe_to_geo -text "fe to geo" -help "fe to geo" -command { ::hm::MyTab::fe_to_geo }
			grid $frame3.fe_to_geo -sticky ew
			
			grid columnconfigure $frame3 "all" -weight 1
		
		# Create the frame4
        set frame4 [frame $m_recess.frame4];
        pack $frame4 -side bottom -anchor nw -fill x;
			button $frame4.close -text "Close" -width $m_width -command ::hm::MyTab::Close 
			pack $frame4.close -side right
		::hm::MyTab::SetCallbacks;
    }
}

#################################################################
proc ::hm::MyTab::Close { args } {
	variable m_title;
	
	set ans [ Answer "Are you sure you want to leave?" okcancel ]
	if { $ans == "cancel" } { return }
	
	hm_framework removetab "$m_title";
	TearDownWindow after_deactivate;
}

proc ::hm::MyTab::Error { msg } {
	variable m_title;
	
	set ans [ Answer "Error : $msg" ok ]
	
	hm_framework removetab "$m_title";
	TearDownWindow after_deactivate;
}

#################################################################
# rename
proc ::hm::MyTab::do_change_name { proptype pre } {
	*createmark $proptype 1 all
	set myprop [ hm_getmark $proptype 1 ]
	*clearmark $proptype 1
	
	foreach propid $myprop {
		set propname [ hm_getcollectorname $proptype $propid ]
		puts "$proptype : ( $propid , $propname )"
		#~ [ regexp {[a-zA-Z]+[0-9a-zA-Z_-]*} $input name ]
		set newpropname [ string map {. p " " "" "\n" "" "\t" "" "\r" "" * "" ^ "" % "" "\$" "" "#" "" ! "" ~ "" "`" "" "@" "" & "" , "" < "" > "" "(" "" ")" "" "{" "" "}" "" "|" "" "\\" "" / "" ? "" "'" "" "\"" "" ";" "" "[" "" "]" ""} $propname ]
		if { [ string match {[0-9]*} $newpropname ] } {
			set newpropname "${pre}_${newpropname}"
		}
		if {[string equal $propname $newpropname]} {
			continue
		}
		if { [ hm_entityinfo exist $proptype $newpropname ] } {
			set newpropname [ hm_getincrementalname $proptype $newpropname 1 ] 
		}
		*renamecollector $proptype $propname $newpropname
		puts "rename $proptype : $propname  --> $newpropname"
	}
}

proc ::hm::MyTab::change_name { args } {
	##
	set state [ hm_commandfilestate 0]
	hm_blockmessages 1
	##
	
	do_change_name components T
	#~ do_change_name properties pr
	#~ do_change_name materials mat
	do_change_name sets s
	#~ do_change_name loadsteps ls
	#~ do_change_name loadcols l
	#~ do_change_name assemblies a
	#~ do_change_name beamsects sec
	
	##
	hm_commandfilestate $state
	hm_blockmessages 0
	##
}

#################################################################
### some basic tools
proc ::hm::MyTab::CreateNode { pos } {
	eval *createnode $pos 0 0 0
	set ans [TheLast nodes];
	set ans;
}

proc ::hm::MyTab::TheLast { type } {
	*createmark $type 1 -1
	set id [ hm_getmark $type 1]
	*clearmark $type 1
	set id;
}

proc ::hm::MyTab::delete_all { type } {
	puts "removing all $type"
	*createmark $type 1 "all"
	catch { *deletemark $type 1 }
}

proc ::hm::MyTab::is_template { name } {
	return [ string equal -nocase $name [ hm_info templatecodename]]
}

proc ::hm::MyTab::ValidateName { name } {
	return [ regexp {^[a-zA-Z]+[0-9a-zA-Z_-]*$} $name ] 
}

proc ::hm::MyTab::select_panal { type msg } {
	*createmarkpanel $type 1 $msg
	set ans	[ hm_getmark $type 1 ]
	*clearmark $type 1
	set ans
}
##########################################################################
### solid
proc ::hm::MyTab::trim_comps { args } {
	
	##
	set state [ hm_commandfilestate 0]
	hm_blockmessages 1
	##
	*createmarkpanel components 1 "select components.."
	set mycomp [ hm_getmark components 1 ]
	*clearmark components 1
	
	do_trim_comps $mycomp
	
	##
	hm_commandfilestate $state
	hm_blockmessages 0
	##
}

proc ::hm::MyTab::find_face_elem { args } {
	
	##
	set state [ hm_commandfilestate 0]
	hm_blockmessages 1
	##
	
	*clearmarkall 1
	*clearmarkall 2
	*facesdelete 

	*createmark materials 1 all
	set mymat [ hm_getmark materials 1 ]
	*clearmark materials 1

	foreach matid $mymat {
		set matname [ hm_getcollectorname materials $matid ]
		
		*createmark materials 1 $matname
		*createstringarray 2 "elements_on" "geometry_off"
		*isolateonlyentitybymark 1 1 2
		*clearmark materials 1
		
		*createmark components 1 "displayed"
		set mycomp [ hm_getmark components 1 ]
		*clearmark components 1
		
		set surf_comp "surface_"
		append surf_comp $matname	
		*createentity comps name=$surf_comp
		
		foreach compid $mycomp {
			set compname [ hm_getcollectorname components $compid ]
			*createmark components 1 $compname
			set status [ catch { *findfaces components 1 } res ]
			*clearmark components 1
			if { $status } {
				continue
			}
			*createmark elements 1 "by comp name" "^faces"
			*movemark elements 1 $surf_comp
			*clearmark elements 1
			*facesdelete 
		}
	}

	##
	hm_commandfilestate $state
	hm_blockmessages 0
	##
}

##########################################################################
## real done
proc ::hm::MyTab::do_trim_comps { mycomp } {	
	if { [llength $mycomp] > 1 } {
		set comp_flag {}
		foreach i $mycomp {
			dict set comp_flag $i 1
		}
		
		foreach i $mycomp {
			dict unset comp_flag $i
			dict for { k v } $comp_flag {
				*createmark surfaces 1 "by comp" $i
				*createmark surfaces 2 "by comp" $k
				catch {*surfmark_trim_by_surfmark 1 2 1}
			}
		}
	}
}
##########################################################################
## add mass on rigid master node
proc ::hm::MyTab::rigid_master_mass { args } {
	
	##
	set state [ hm_commandfilestate 0]
	hm_blockmessages 1
	##
	*createmarkpanel elements 1 "select rigid elements.."
	set rigids [ hm_getmark elements 1 ]
	*clearmark elements 1
	set master_nodes []
	foreach i $rigids {
		set config [ hm_getvalue elems id=$i dataname=config ]
		if { $config==55 || $config==5 } {
			lappend master_nodes [ hm_getvalue elems id=$i dataname=independentnode]
		} elseif { $config==56 } {
			lappend master_nodes [ hm_getvalue elems id=$i dataname=dependentnode]
		}
	}
	catch {
		eval *createmark nodes 1 $master_nodes
		*masselement 1 0 "" 0
	}
	##
	hm_commandfilestate $state
	hm_blockmessages 0
	##
}
##########################################################################
## fe to geometry
proc ::hm::MyTab::fe_to_geo { args } {
	##
	set state [ hm_commandfilestate 0]
	hm_blockmessages 1
	##
	set comps [ select_panal components "select components.." ]
	
	foreach i $comps {
		catch {
			*facesdelete 
			*createmark components 1 $i 
			*findfaces components 1 
			*currentcollector components  "^faces"
			*createmark elements 1 "by component" "^faces"
			*createmark elements 2
			*fetosurfs 1 2 91 1200 0.1 0
			*createmark surfaces 1 "by component" "^faces"
			*movemark surfaces 1 [ hm_getvalue comps id=$i dataname=name]
		}
	}
	##
	hm_commandfilestate $state
	hm_blockmessages 0
	##
}
##########################################################################
if [ catch {::hm::MyTab::Main} err] {
	::hm::MyTab::Error $err
}
