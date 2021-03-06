#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

    # Provoke name search
    catch {package require bogus-package-name}
    set packageNames [package names]

    package require BWidget
    switch $tcl_platform(platform) {
	windows {
	}
	default {
	    option add *ScrolledWindow.size 14
	}
    }
    
    package require Tk
    switch $tcl_platform(platform) {
	windows {
            option add *Button.padY 0
	}
	default {
            option add *Scrollbar.width 10
            option add *Scrollbar.highlightThickness 0
            option add *Scrollbar.elementBorderWidth 2
            option add *Scrollbar.borderWidth 2
	}
    }
    
}

#############################################################################
# Visual Tcl v1.60 Project
#




#############################################################################
## vTcl Code to Load Stock Images


if {![info exist vTcl(sourcing)]} {
#############################################################################
## Procedure:  vTcl:rename

proc ::vTcl:rename {name} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    regsub -all "\\." $name "_" ret
    regsub -all "\\-" $ret "_" ret
    regsub -all " " $ret "_" ret
    regsub -all "/" $ret "__" ret
    regsub -all "::" $ret "__" ret

    return [string tolower $ret]
}

#############################################################################
## Procedure:  vTcl:image:create_new_image

proc ::vTcl:image:create_new_image {filename {description {no description}} {type {}} {data {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    # Does the image already exist?
    if {[info exists ::vTcl(images,files)]} {
        if {[lsearch -exact $::vTcl(images,files) $filename] > -1} { return }
    }

    if {![info exists ::vTcl(sourcing)] && [string length $data] > 0} {
        set object [image create  [vTcl:image:get_creation_type $filename]  -data $data]
    } else {
        # Wait a minute... Does the file actually exist?
        if {! [file exists $filename] } {
            # Try current directory
            set script [file dirname [info script]]
            set filename [file join $script [file tail $filename] ]
        }

        if {![file exists $filename]} {
            set description "file not found!"
            ## will add 'broken image' again when img is fixed, for now create empty
            set object [image create photo -width 1 -height 1]
        } else {
            set object [image create  [vTcl:image:get_creation_type $filename]  -file $filename]
        }
    }

    set reference [vTcl:rename $filename]
    set ::vTcl(images,$reference,image)       $object
    set ::vTcl(images,$reference,description) $description
    set ::vTcl(images,$reference,type)        $type
    set ::vTcl(images,filename,$object)       $filename

    lappend ::vTcl(images,files) $filename
    lappend ::vTcl(images,$type) $object

    # return image name in case caller might want it
    return $object
}

#############################################################################
## Procedure:  vTcl:image:get_image

proc ::vTcl:image:get_image {filename} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    set reference [vTcl:rename $filename]

    # Let's do some checking first
    if {![info exists ::vTcl(images,$reference,image)]} {
        # Well, the path may be wrong; in that case check
        # only the filename instead, without the path.

        set imageTail [file tail $filename]

        foreach oneFile $::vTcl(images,files) {
            if {[file tail $oneFile] == $imageTail} {
                set reference [vTcl:rename $oneFile]
                break
            }
        }
    }
    return $::vTcl(images,$reference,image)
}

#############################################################################
## Procedure:  vTcl:image:get_creation_type

proc ::vTcl:image:get_creation_type {filename} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    switch [string tolower [file extension $filename]] {
        .ppm -
        .jpg -
        .bmp -
        .gif    {return photo}
        .xbm    {return bitmap}
        default {return photo}
    }
}

foreach img {


            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
}

}
#############################################################################
## vTcl Code to Load User Images

catch {package require Img}

foreach img {

        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}

            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
}

#################################
# VTCL LIBRARY PROCEDURES
#

if {![info exists vTcl(sourcing)]} {
#############################################################################
## Library Procedure:  Window

proc ::Window {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global vTcl
    foreach {cmd name newname} [lrange $args 0 2] {}
    set rest    [lrange $args 3 end]
    if {$name == "" || $cmd == ""} { return }
    if {$newname == ""} { set newname $name }
    if {$name == "."} { wm withdraw $name; return }
    set exists [winfo exists $newname]
    switch $cmd {
        show {
            if {$exists} {
                wm deiconify $newname
            } elseif {[info procs vTclWindow$name] != ""} {
                eval "vTclWindow$name $newname $rest"
            }
            if {[winfo exists $newname] && [wm state $newname] == "normal"} {
                vTcl:FireEvent $newname <<Show>>
            }
        }
        hide    {
            if {$exists} {
                wm withdraw $newname
                vTcl:FireEvent $newname <<Hide>>
                return}
        }
        iconify { if $exists {wm iconify $newname; return} }
        destroy { if $exists {destroy $newname; return} }
    }
}
#############################################################################
## Library Procedure:  vTcl:DefineAlias

proc ::vTcl:DefineAlias {target alias widgetProc top_or_alias cmdalias} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global widget
    set widget($alias) $target
    set widget(rev,$target) $alias
    if {$cmdalias} {
        interp alias {} $alias {} $widgetProc $target
    }
    if {$top_or_alias != ""} {
        set widget($top_or_alias,$alias) $target
        if {$cmdalias} {
            interp alias {} $top_or_alias.$alias {} $widgetProc $target
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:DoCmdOption

proc ::vTcl:DoCmdOption {target cmd} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## menus are considered toplevel windows
    set parent $target
    while {[winfo class $parent] == "Menu"} {
        set parent [winfo parent $parent]
    }

    regsub -all {\%widget} $cmd $target cmd
    regsub -all {\%top} $cmd [winfo toplevel $parent] cmd

    uplevel #0 [list eval $cmd]
}
#############################################################################
## Library Procedure:  vTcl:FireEvent

proc ::vTcl:FireEvent {target event {params {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## The window may have disappeared
    if {![winfo exists $target]} return
    ## Process each binding tag, looking for the event
    foreach bindtag [bindtags $target] {
        set tag_events [bind $bindtag]
        set stop_processing 0
        foreach tag_event $tag_events {
            if {$tag_event == $event} {
                set bind_code [bind $bindtag $tag_event]
                foreach rep "\{%W $target\} $params" {
                    regsub -all [lindex $rep 0] $bind_code [lindex $rep 1] bind_code
                }
                set result [catch {uplevel #0 $bind_code} errortext]
                if {$result == 3} {
                    ## break exception, stop processing
                    set stop_processing 1
                } elseif {$result != 0} {
                    bgerror $errortext
                }
                break
            }
        }
        if {$stop_processing} {break}
    }
}
#############################################################################
## Library Procedure:  vTcl:Toplevel:WidgetProc

proc ::vTcl:Toplevel:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }
    set command [lindex $args 0]
    set args [lrange $args 1 end]
    switch -- [string tolower $command] {
        "setvar" {
            foreach {varname value} $args {}
            if {$value == ""} {
                return [set ::${w}::${varname}]
            } else {
                return [set ::${w}::${varname} $value]
            }
        }
        "hide" - "show" {
            Window [string tolower $command] $w
        }
        "showmodal" {
            ## modal dialog ends when window is destroyed
            Window show $w; raise $w
            grab $w; tkwait window $w; grab release $w
        }
        "startmodal" {
            ## ends when endmodal called
            Window show $w; raise $w
            set ::${w}::_modal 1
            grab $w; tkwait variable ::${w}::_modal; grab release $w
        }
        "endmodal" {
            ## ends modal dialog started with startmodal, argument is var name
            set ::${w}::_modal 0
            Window hide $w
        }
        default {
            uplevel $w $command $args
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:WidgetProc

proc ::vTcl:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }

    set command [lindex $args 0]
    set args [lrange $args 1 end]
    uplevel $w $command $args
}
#############################################################################
## Library Procedure:  vTcl:toplevel

proc ::vTcl:toplevel {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    uplevel #0 eval toplevel $args
    set target [lindex $args 0]
    namespace eval ::$target {set _modal 0}
}
}


if {[info exists vTcl(sourcing)]} {

proc vTcl:project:info {} {
    set base .top370
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.tit71 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.but75 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd83 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd83 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.but75 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd72 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.but75 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.fra74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra74
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd68
    namespace eval ::widgets::$site_5_0.fra73 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra73
    namespace eval ::widgets::$site_6_0.rad75 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd66 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd67 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd67 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.cpd67 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd71
    namespace eval ::widgets::$site_8_0.lab72 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd74
    namespace eval ::widgets::$site_8_0.lab72 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd75
    namespace eval ::widgets::$site_8_0.lab72 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.lab72 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.but69 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit77 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit77 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra78 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra78
    namespace eval ::widgets::$site_5_0.che81 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd83 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd79 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.fra73 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra73
    namespace eval ::widgets::$site_7_0.rad75 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd77 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra83 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra83
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top370
        }
        set compounds {
        }
        set projectType single
    }
}
}

#################################
# USER DEFINED PROCEDURES
#
#############################################################################
## Procedure:  main

proc ::main {argc argv} {
## This will clean up and call exit properly on Windows.
#vTcl:WindowsCleanup
}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {
global tk_strictMotif MouseInitX MouseInitY MouseEndX MouseEndY BMPMouseX BMPMouseY

catch {package require unsafe}
set tk_strictMotif 1
global TrainingAreaTool; 
global x;
global y;

set TrainingAreaTool rect
}

init $argc $argv

#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    wm focusmodel $top passive
    wm geometry $top 200x200+66+66; update
    wm maxsize $top 1284 785
    wm minsize $top 104 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm withdraw $top
    wm title $top "vtcl"
    bindtags $top "$top Vtcl all"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    ###################
    # SETTING GEOMETRY
    ###################

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top370 {base} {
    if {$base == ""} {
        set base .top370
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x430+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "POLinSAR Baseline Estimation"
    vTcl:DefineAlias "$top" "Toplevel370" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.tit71 \
        -text {Input Master Directory} 
    vTcl:DefineAlias "$top.tit71" "TitleFrame1" vTcl:WidgetProc "Toplevel370" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FlatEarthMasterDirInput 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry370_149" vTcl:WidgetProc "Toplevel370" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame1" vTcl:WidgetProc "Toplevel370" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button1" vTcl:WidgetProc "Toplevel370" 1
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.cpd83 \
        -text {Input Slave Directory} 
    vTcl:DefineAlias "$top.cpd83" "TitleFrame7" vTcl:WidgetProc "Toplevel370" 1
    bind $top.cpd83 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd83 getframe]
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FlatEarthSlaveDirInput 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry234" vTcl:WidgetProc "Toplevel370" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame26" vTcl:WidgetProc "Toplevel370" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button5" vTcl:WidgetProc "Toplevel370" 1
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.cpd72 \
        -text {Output Slave Directory} 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame8" vTcl:WidgetProc "Toplevel370" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable FlatEarthSlaveDirOutput 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry235" vTcl:WidgetProc "Toplevel370" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame27" vTcl:WidgetProc "Toplevel370" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button6" vTcl:WidgetProc "Toplevel370" 1
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame9" vTcl:WidgetProc "Toplevel370" 1
    set site_3_0 $top.fra74
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label370_01" vTcl:WidgetProc "Toplevel370" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry370_01" vTcl:WidgetProc "Toplevel370" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label370_02" vTcl:WidgetProc "Toplevel370" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry370_02" vTcl:WidgetProc "Toplevel370" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label370_03" vTcl:WidgetProc "Toplevel370" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry370_03" vTcl:WidgetProc "Toplevel370" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label370_04" vTcl:WidgetProc "Toplevel370" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry370_04" vTcl:WidgetProc "Toplevel370" 1
    pack $site_3_0.lab57 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent58 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab59 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent60 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab61 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent62 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab63 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 10 \
        -side left 
    pack $site_3_0.ent64 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd66 \
        -text {Baseline Estimation} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame4" vTcl:WidgetProc "Toplevel370" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    frame $site_4_0.cpd68
    set site_5_0 $site_4_0.cpd68
    frame $site_5_0.fra73 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra73" "Frame7" vTcl:WidgetProc "Toplevel370" 1
    set site_6_0 $site_5_0.fra73
    radiobutton $site_6_0.rad75 \
        -text {ALOS ( JAXA )} -value alosjaxa -variable FlatEarthSensor 
    vTcl:DefineAlias "$site_6_0.rad75" "Radiobutton8" vTcl:WidgetProc "Toplevel370" 1
    radiobutton $site_6_0.cpd66 \
        \
        -command {Window show .top35; TextEditorRunTrace "Open Window Under Construction" "b"} \
        -text {ALOS ( ERSDAC )} -value alosersdac -variable FlatEarthSensor 
    vTcl:DefineAlias "$site_6_0.cpd66" "Radiobutton11" vTcl:WidgetProc "Toplevel370" 1
    radiobutton $site_6_0.cpd76 \
        \
        -command {Window show .top35; TextEditorRunTrace "Open Window Under Construction" "b"} \
        -text RADARSAT-2 -value radarsat2 -variable FlatEarthSensor 
    vTcl:DefineAlias "$site_6_0.cpd76" "Radiobutton9" vTcl:WidgetProc "Toplevel370" 1
    radiobutton $site_6_0.cpd67 \
        \
        -command {Window show .top35; TextEditorRunTrace "Open Window Under Construction" "b"} \
        -text TerraSAR-X -value terrasarx -variable FlatEarthSensor 
    vTcl:DefineAlias "$site_6_0.cpd67" "Radiobutton10" vTcl:WidgetProc "Toplevel370" 1
    pack $site_6_0.rad75 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd66 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd67 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_5_0.cpd67 \
        -text {Averaged Estimated Baseline Values} 
    vTcl:DefineAlias "$site_5_0.cpd67" "TitleFrame370" vTcl:WidgetProc "Toplevel370" 1
    bind $site_5_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd67 getframe]
    frame $site_7_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd71" "Frame5" vTcl:WidgetProc "Toplevel370" 1
    set site_8_0 $site_7_0.cpd71
    label $site_8_0.lab72 \
        -text {Parallel  } 
    vTcl:DefineAlias "$site_8_0.lab72" "Label370_1" vTcl:WidgetProc "Toplevel370" 1
    entry $site_8_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable FlatEarthBasePara -width 5 
    vTcl:DefineAlias "$site_8_0.ent73" "Entry370_1" vTcl:WidgetProc "Toplevel370" 1
    pack $site_8_0.lab72 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent73 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd74" "Frame8" vTcl:WidgetProc "Toplevel370" 1
    set site_8_0 $site_7_0.cpd74
    label $site_8_0.lab72 \
        -text {Perpendicular  } 
    vTcl:DefineAlias "$site_8_0.lab72" "Label370_2" vTcl:WidgetProc "Toplevel370" 1
    entry $site_8_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable FlatEarthBasePerp -width 5 
    vTcl:DefineAlias "$site_8_0.ent73" "Entry370_2" vTcl:WidgetProc "Toplevel370" 1
    pack $site_8_0.lab72 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent73 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame10" vTcl:WidgetProc "Toplevel370" 1
    set site_8_0 $site_7_0.cpd75
    label $site_8_0.lab72 \
        -text {Horizontal  } 
    vTcl:DefineAlias "$site_8_0.lab72" "Label5" vTcl:WidgetProc "Toplevel370" 1
    entry $site_8_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable FlatEarthBaseHori -width 5 
    vTcl:DefineAlias "$site_8_0.ent73" "Entry5" vTcl:WidgetProc "Toplevel370" 1
    pack $site_8_0.lab72 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent73 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame11" vTcl:WidgetProc "Toplevel370" 1
    set site_8_0 $site_7_0.cpd76
    label $site_8_0.lab72 \
        -text {Vertical  } 
    vTcl:DefineAlias "$site_8_0.lab72" "Label6" vTcl:WidgetProc "Toplevel370" 1
    entry $site_8_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable FlatEarthBaseVert -width 5 
    vTcl:DefineAlias "$site_8_0.ent73" "Entry6" vTcl:WidgetProc "Toplevel370" 1
    pack $site_8_0.lab72 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_8_0.ent73 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd71 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd74 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.fra73 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd67 \
        -in $site_5_0 -anchor center -expand 1 -fill both -pady 5 -side top 
    button $site_4_0.but69 \
        -background #ffff00 \
        -command {global DataDirChannel1 DataDirChannel2
global FlatEarthFormat FlatEarthFlagFE FlatEarthFlagKZ FlatEarthFlagIA
global FlatEarthMasterDirInput FlatEarthSlaveDirInput
global FlatEarthSlaveDirOutput FlatEarthSensor TMPBaselineTxt
global FlatEarthBasePara FlatEarthBasePerp FlatEarthBaseHori FlatEarthBaseVert
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global ConfigFile FinalNlig FinalNcol PolarCase PolarType OpenDirFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

    #####################################################################
    #Create Directory
    set FlatEarthSlaveDirOutput [PSPCreateDirectoryMask $FlatEarthSlaveDirOutput $FlatEarthSlaveDirOutput $FlatEarthSlaveDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    TestVar 4
    if {$TestVarError == "ok"} {

        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
        DeleteFile $TMPBaselineTxt

        set Fonction "Baseline Estimation"
        set Fonction2 ""
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        if {$FlatEarthSensor == "alosjaxa"} {
            TextEditorRunTrace "Process The Function Soft/data_import/alos_calc_baseline.exe" "k"
            TextEditorRunTrace "Arguments: -idm \x22$FlatEarthMasterDirInput\x22 -ids \x22$FlatEarthSlaveDirInput\x22 -od \x22$FlatEarthSlaveDirOutput\x22 -otf \x22$TMPBaselineTxt\x22 -fkz 0 -fia 0 -ffe 0" "k"
            set f [ open "| Soft/data_import/alos_calc_baseline.exe -idm \x22$FlatEarthMasterDirInput\x22 -ids \x22$FlatEarthSlaveDirInput\x22 -od \x22$FlatEarthSlaveDirOutput\x22 -otf \x22$TMPBaselineTxt\x22 -fkz 0 -fia 0 -ffe 0" r]
            PsPprogressBar $f
            }
        if {$FlatEarthSensor == "alosersdac"} {
            }
        if {$FlatEarthSensor == "radarsat2"} {
            }
        if {$FlatEarthSensor == "terrasarx"} {
            }
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        WaitUntilCreated $TMPBaselineTxt
        if [file exists $TMPBaselineTxt] {
            set f [open $TMPBaselineTxt r]
            gets $f FlatEarthBasePara
            gets $f FlatEarthBasePerp
            gets $f FlatEarthBaseHori
            gets $f FlatEarthBaseVert
            close $f
            $widget(Button370_1) configure -state normal
      
            $widget(TitleFrame370_0) configure -state normal
            $widget(Checkbutton370_1) configure -state normal
            $widget(Checkbutton370_2) configure -state normal
            $widget(Checkbutton370_3) configure -state normal 
            }
        }
        #TestVar
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel370); TextEditorRunTrace "Close Window POLinSAR Baseline Estimation" "b"}
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_4_0.but69" "Button2" vTcl:WidgetProc "Toplevel370" 1
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side left 
    pack $site_4_0.but69 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 10 \
        -side right 
    TitleFrame $top.tit77 \
        -text {Auxilliary Parameter Estimation} 
    vTcl:DefineAlias "$top.tit77" "TitleFrame370_0" vTcl:WidgetProc "Toplevel370" 1
    bind $top.tit77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit77 getframe]
    frame $site_4_0.fra78 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra78" "Frame2" vTcl:WidgetProc "Toplevel370" 1
    set site_5_0 $site_4_0.fra78
    checkbutton $site_5_0.che81 \
        \
        -command {global FlatEarthFlagFE FlatEarthFormat

if {$FlatEarthFlagFE == 1} {
    set FlatEarthFormat 2
    $widget(TitleFrame370_1) configure -state normal
    $widget(Radiobutton370_1) configure -state normal
    $widget(Radiobutton370_2) configure -state normal
    $widget(Radiobutton370_3) configure -state normal
    } else {
    set FlatEarthFormat 0
    $widget(TitleFrame370_1) configure -state disable
    $widget(Radiobutton370_1) configure -state disable
    $widget(Radiobutton370_2) configure -state disable
    $widget(Radiobutton370_3) configure -state disable
    }} \
        -text {Flat Earth} -variable FlatEarthFlagFE 
    vTcl:DefineAlias "$site_5_0.che81" "Checkbutton370_1" vTcl:WidgetProc "Toplevel370" 1
    checkbutton $site_5_0.cpd82 \
        -text kz -variable FlatEarthFlagKZ 
    vTcl:DefineAlias "$site_5_0.cpd82" "Checkbutton370_2" vTcl:WidgetProc "Toplevel370" 1
    checkbutton $site_5_0.cpd83 \
        -text {Incidence Angle (deg)} -variable FlatEarthFlagIA 
    vTcl:DefineAlias "$site_5_0.cpd83" "Checkbutton370_3" vTcl:WidgetProc "Toplevel370" 1
    pack $site_5_0.che81 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd83 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd79 \
        -ipad 0 -text {Output Format} 
    vTcl:DefineAlias "$site_4_0.cpd79" "TitleFrame370_1" vTcl:WidgetProc "Toplevel370" 1
    bind $site_4_0.cpd79 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd79 getframe]
    frame $site_6_0.fra73 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra73" "Frame6" vTcl:WidgetProc "Toplevel370" 1
    set site_7_0 $site_6_0.fra73
    radiobutton $site_7_0.rad75 \
        -text {real ( deg )} -value 2 -variable FlatEarthFormat 
    vTcl:DefineAlias "$site_7_0.rad75" "Radiobutton370_1" vTcl:WidgetProc "Toplevel370" 1
    radiobutton $site_7_0.cpd76 \
        -text {real ( rad )} -value 3 -variable FlatEarthFormat 
    vTcl:DefineAlias "$site_7_0.cpd76" "Radiobutton370_2" vTcl:WidgetProc "Toplevel370" 1
    radiobutton $site_7_0.cpd77 \
        -text {cmplx ( cos, sin )} -value 1 -variable FlatEarthFormat 
    vTcl:DefineAlias "$site_7_0.cpd77" "Radiobutton370_3" vTcl:WidgetProc "Toplevel370" 1
    pack $site_7_0.rad75 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd77 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.fra73 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.fra78 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill x -pady 5 -side top 
    frame $top.fra83 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame20" vTcl:WidgetProc "Toplevel370" 1
    set site_3_0 $top.fra83
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDirChannel1 DataDirChannel2
global FlatEarthFormat FlatEarthFlagFE FlatEarthFlagKZ FlatEarthFlagIA
global FlatEarthMasterDirInput FlatEarthSlaveDirInput
global FlatEarthSlaveDirOutput FlatEarthSensor TMPBaselineTxt
global FlatEarthBasePara FlatEarthBasePerp FlatEarthBaseHori FlatEarthBaseVert
global Fonction2 ProgressLine VarFunction VarWarning WarningMessage WarningMessage2
global ConfigFile FinalNlig FinalNcol PolarCase PolarType OpenDirFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

    #####################################################################
    #Create Directory
    set config2 "ok"
    set DirNameCreate $FlatEarthSlaveDirOutput
    set VarWarning ""
    if [file isdirectory $DirNameCreate] {
        set VarWarning "ok"
        } else {
        set WarningMessage "CREATE THE DIRECTORY ?"
        set WarningMessage2 $DirNameCreate
        set VarWarning ""
        Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
        tkwait variable VarWarning
        if {"$VarWarning"=="ok"} {
            TextEditorRunTrace "Create Directory" "k"
            if { [catch {file mkdir $DirNameCreate} ErrorCreateDir] } {
                set ErrorMessage $ErrorCreateDir
                set VarError ""
                Window show $widget(Toplevel44)
                set VarWarning ""
                }
            }
        }
    #####################################################################       

if {"$VarWarning"=="ok"} {
    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    TestVar 4
    if {$TestVarError == "ok"} {

        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]
    
        set Fonction "Baseline Estimation"
        set Fonction2 ""
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        if {$FlatEarthSensor == "alosjaxa"} {
            TextEditorRunTrace "Process The Function Soft/data_import/alos_calc_baseline.exe" "k"
            TextEditorRunTrace "Arguments: \x22$FlatEarthMasterDirInput\x22 \x22$FlatEarthSlaveDirInput\x22 \x22$FlatEarthSlaveDirOutput\x22 \x22$TMPBaselineTxt\x22 $FlatEarthFlagKZ $FlatEarthFlagIA $FlatEarthFormat" "k"
            set f [ open "| Soft/data_import/alos_calc_baseline.exe \x22$FlatEarthMasterDirInput\x22 \x22$FlatEarthSlaveDirInput\x22 \x22$FlatEarthSlaveDirOutput\x22 \x22$TMPBaselineTxt\x22 $FlatEarthFlagKZ $FlatEarthFlagIA $FlatEarthFormat" r]
            PsPprogressBar $f
            }
        if {$FlatEarthSensor == "alosersdac"} {
            }
        if {$FlatEarthSensor == "radarsat2"} {
            }
        if {$FlatEarthSensor == "terrasarx"} {
            }
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        if {$FlatEarthFormat != ""} {
            set BaselineFile $FlatEarthSlaveDirOutput; append BaselineFile "/flat_earth"
            if [file exists "$BaselineFile.bin"] {
                set BMPDirInput $FlatEarthSlaveDirOutput
                set BMPFileInput "$BaselineFile.bin"
                set BMPFileOutput "$BaselineFile.bmp"
                if {$FlatEarthFormat == "1"} {
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput cmplx pha jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -180.0 +180.0
                    }
                if {$FlatEarthFormat == "2"} {
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -180.0 +180.0
                    }
                if {$FlatEarthFormat == "3"} {
                    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 0 -3.1416 +3.1416
                    }
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE $Baseline.bin DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {$FlatEarthFlagIA == 1} {
            set BaselineFile $FlatEarthSlaveDirOutput; append BaselineFile "/inc_angle"
            if [file exists "$BaselineFile.bin"] {
                set BMPDirInput $FlatEarthSlaveDirOutput
                set BMPFileInput "$BaselineFile.bin"
                set BMPFileOutput "$BaselineFile.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 3 -9999.9 +9999.9
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE $Baseline.bin DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {$FlatEarthFlagKZ == 1} {
            set BaselineFile $FlatEarthSlaveDirOutput; append BaselineFile "/kz"
            if [file exists "$BaselineFile.bin"] {
                set BMPDirInput $FlatEarthSlaveDirOutput
                set BMPFileInput "$BaselineFile.bin"
                set BMPFileOutput "$BaselineFile.bmp"
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol 0 0 $FinalNlig $FinalNcol 3 -9999.9 +9999.9
                } else {
                set config "false"
                set VarError ""
                set ErrorMessage "THE FILE $Baseline.bin DOES NOT EXIST" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        }
        #TestVar
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel370); TextEditorRunTrace "Close Window POLinSAR Baseline Estimation" "b"}
    }
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button370_1" vTcl:WidgetProc "Toplevel370" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command { HelpPdfEdit "Help/BaselineEstimation.pdf" } \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text {} -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel370" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel370); TextEditorRunTrace "Close Window POLinSAR Baseline Estimation" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel370" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.tit71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd83 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra83 \
        -in $top -anchor center -expand 1 -fill x -side top 

    vTcl:FireEvent $base <<Ready>>
}

#############################################################################
## Binding tag:  _TopLevel

bind "_TopLevel" <<Create>> {
    if {![info exists _topcount]} {set _topcount 0}; incr _topcount
}
bind "_TopLevel" <<DeleteWindow>> {
    if {[set ::%W::_modal]} {
                vTcl:Toplevel:WidgetProc %W endmodal
            } else {
                destroy %W; if {$_topcount == 0} {exit}
            }
}
bind "_TopLevel" <Destroy> {
    if {[winfo toplevel %W] == "%W"} {incr _topcount -1}
}
#############################################################################
## Binding tag:  _vTclBalloon


if {![info exists vTcl(sourcing)]} {
}

Window show .
Window show .top370

main $argc $argv
