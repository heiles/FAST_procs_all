;+
;NAME:
;bdwfinit - initialize to use the idl bdwf (brown dwarf routines).
;SYNTAX: @bdwfinit   
;DESCRIPTION:
;   call this routine before using any of the bdwf_ idl routines.
;It sets up the path for the idl bdwf  directory and defines the
;necessary structures.
;-
@geninit
@masinit
addpath,'bdwf'

forward_function  bdwf_hrdoitmock,bdwf_hrmakesavfile,$
			      bdwf_hrsmointerpscan

.compile bdwf_hrdoitmock
.compile bdwf_hrinit
.compile bdwf_hrmakebin
.compile bdwf_hrmakeimage
.compile bdwf_hrmakesavefile
.compile bdwf_hrsmointerpscan

