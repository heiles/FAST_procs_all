;+
;NAME:
;satinptlefile - input an entire tle file
;SYNTAX: nsat=satinptlefile(filenm,tleAr,tledir=tledir)
;ARGS:
;filenm: string name of tle file to input. If no / in filename then
;               prepend default directory.
;KEYWORDS:
;tledir:  string  if supplied then use this directory to  look for tle file
;RETURNS:
;nsat: long  number of satellites found in the file
;satAr[nsat]:{}    array of tle entries found in file
;
;DESCRIPTION:
;   Input all of the satellites from a tle file
; for tle field definitions see:
; http://celestrak.com/columns/v04n03/#FAQ01
;-
function satinptlefile,filenm,tleAr,tledir=tledir
;
;   
; 
    suI=satsetup() 
    tlepath=(keyword_set(tledir))?tledir:suI.tledir
    if strpos(filenm,'/') ne -1 then tlepath=''
    ioerr=0
    lun=-1
    openr,lun,tlepath+filenm,/get_lun,err=ioerr
    if ioerr ne 0 then begin
        print,"unable to open:",tlepath+filenm,' err:',!error_state.msg
        return,-1
    endif
    a={satNm:'',$
        satNum:0,$
       satClass:'',$
       launchYr:0L,$
       launchNum:0,$
       launchPiece:'',$
       epochYr: 0L,$
       epochDay:0d,$
       tmDer1  :0d,$
       tmDer2  :'',$
       drag    :0d,$
       ephType :'',$
       elmNum  :0 ,$
       inclination:0d,$
       raAscNode:0d,$
       eccentricity:'',$
       argOfPerigee:0d,$
       meanAnomaly :0d,$ ; degrees 
       meanMotion :0d,$ ; revs/day
       revNum     :0L,$
       lines      :strarr(3) }   ; revolution number
;
;   define datatypes for read
;
    nm=''
    line1=''
    line2=''
    line3=''
    lineN1=0&satNum=0&launchYr=0&epochYr=0L&elmNum=0&chkSum=0
    class=''&launchPiece=''&der2motion=''&drag=''&ephType=''
    epochDay=0D&der1motion=0d
;
    lineN2=0&satNum2=0&revNum=0L&chksum2=0
    incl=0D&raAscNode=0d&argOfPerigee=0d&meanAnomaly=0d&meanMotion=0d&
    eccentricity='' 
    fmt1="(i1,1x,i5,a1,1x,i2,i3,a3,1x,i2,f12.8,1x,f10.8,1x,a8,1x,a8,1x,a1,1x,i4,i1)"
fmt2="(i1,1x,i5,1x,f8.4,1x,f8.4,1x,a7,1x,f8.4,1x,f8.4,1x,f11.8,i5,i1)"

    maxNum=500
    tleAr=replicate(a,maxNum)
    on_ioerror,done
    icnt=0
    while (1) do begin
        readf,lun,line1
        readf,lun,line2
        readf,lun,line3
        reads,line2,format=fmt1,$
        lineN1,satNum,class,launchYr,launchNum,launchPiece,epochYr,epochDay,$
            der1motion,der2motion,drag,ephType,elmNum,chkSum
        reads,line3,format=fmt2,$
        lineN2,satNum2,incl,raAscNode,eccentricity,argOfPerigee,meanAnomaly,$
            meanMotion,revNum,chksum2
        tleAr[icnt].SATNm =line1
        tleAr[icnt].SATNUM =satNum
        tleAr[icnt].SATCLASS =class
        tleAr[icnt].LAUNCHYR =(launchYr gt 50)?launchYr +1900L:launchYr+2000L
        tleAr[icnt].LAUNCHNUM =launchNum
        tleAr[icnt].LAUNCHPIECE = launchPiece
        tleAr[icnt].EPOCHYR =(epochYr gt 50)?epochYr+1900:epochYr+2000L
        tleAr[icnt].EPOCHDAY =epochDay
        tleAr[icnt].TMDER1 =der1motion
        tleAr[icnt].TMDER2 =der2motion
        tleAr[icnt].DRAG = drag
        tleAr[icnt].EPHTYPE =ephType
        tleAr[icnt].ELMNUM =elmNum
        tleAr[icnt].INCLINATION =incl
        tleAr[icnt].RAASCNODE =  raAscNode
        tleAr[icnt].ECCENTRICITY = eccentricity
        tleAr[icnt].ARGOFPERIGEE = argOfPerigee
        tleAr[icnt].MEANANOMALY =  meanAnomaly
        tleAr[icnt].MEANMOTION =   meanMotion
        tleAr[icnt].REVNUM =       revNum
        tleAr[icnt].lines =[line1,line2,line3]
        icnt++
    endwhile
done:
        if lun ne -1 then free_lun,lun
        lun=-1
        if icnt lt maxNum then begin
            if icnt eq 0 then begin
                tleAr=''
            endif else begin
                tleAr=tleAr[0:icnt-1]
            endelse
        endif
        return,icnt
end
