;+
;NAME:
;a1963checktimes - example script to check a1963 times.
;SYNTAX: .run a1963checktimes.
;ARGS:  none
;DESCRIPTION:
;   An example file to process a set of a1963 src files and compute
;the amount of time available between source positions. You should
;copy this file to a local directory and edit it to do what you
;want..
;
;After copying the file to a local directory:
;
; compute the times available given the az and ra (taken from the files)
;
; 1. update todo array to include dates and files you want.
;    to add to the end, just copy the last line, increment the index
;    and fill in the two fields yymmdd and fname
; 2. set makehardcopy=1 if you want hardcopy. You then need to
;    define psfilename..
; 
; The routine will :
; 1. compute the info for each day using cmptimes
; 2. plot all of the days 1 per page using plottimes
; 3. print a list of the results to the screen.
;
; A simplified version of this file could be:
;
;   srcfile='/usr/obs4/usr/a1963/n2903_nov30.dat'
;
;   a1963cmptimes,041130,srcfile,datI       ; do the computatinos
;   a1963plottimes,datI                     ; make the plots
;   a1963printtimes,datI                    ; print the table
;
;NOTE:
;   Do @usrprojinit to include the path to this routine.
;-
;
makehardcopy=0                      ; make hardcopy
psfilename='a1963tms.ps'            ; name for postscript file
;
junk={a,yymmdd: 0l, fname:''}
todo=replicate({a},100)
;
; list the days to process;
; You edit these..
;
todo[0]={a,yymmdd:041128,fname:'n2903_nov28.cat'}
todo[1]={a,yymmdd:041129,fname:'n2903_nov29.cat'}
todo[2]={a,yymmdd:041130,fname:'n2903_nov30.cat'}
todo[3]={a,yymmdd:041201,fname:'n2903_dec01.cat'}
todo[4]={a,yymmdd:041202,fname:'n2903_dec02.cat'}
;
; no editing from here on down is needed..
;
ind=where(todo.yymmdd eq 0)     
ndays=ind[0]
todo=todo[0:ndays-1]                    ; truncate to number in specified
;
dirSrcList='/share/obs4/usr/a1963/'    ; input directorye
th=2                                   ; line thickness
;
; loop computing the times/positions.
;
for i=0,ndays-1 do begin &$
    a1963cmptimes,todo[i].yymmdd,dirSrcList+todo[i].fname,dat &$
    naz=n_elements(dat) &$
    if i eq 0 then datI=replicate(dat[0],naz,ndays) &$
    datI[*,i]=dat &$
endfor
;
; plot the data
;
if makehardcopy then pscol,'a1963tms.ps',/full
for i=0,ndays-1 do a1963plottimes,datI[*,i],thick=th
if makehardcopy then hardcopy
x
;
; print out a listing to terminal
;
for i=0,ndays-1 do a1963printtimes,datI[*,i]
;
end
