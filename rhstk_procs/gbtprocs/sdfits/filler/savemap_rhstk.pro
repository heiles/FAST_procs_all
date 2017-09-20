pro SaveMap_rhstk, Data, FileName

;Stg1Path = getenv('GBTPATH')+'/contmap/stg1/sav/'
Stg1Path = ''

NData = N_elements(Data)

; SOMETIMES I MADE MULTIPLE CALON/OFFS IN DURING A SCAN...
; RATHER THAN HAVING EMPTY SPACE IN STRUCTURES WHERE WE TOOK ONLY ONE
; CALON/OFF PAIR, LET'S JUST ARRANGE THE CALS IN AN ARRAY WHERE EACH
; STRUCTURE CONTAINS JUST ONE PAIR...

; ALSO, FOR SOME REASON, SOME CAL PAIRS CONTAIN THE CALSTATE [0,0]
; RATHER THAN [0,1] EVEN THOUGH IT LOOKS LIKE THE CAL FIRED.  USING
; THESE (AND ASSUMING THEY WERE OK) CREATES STRANGE RESULTS IN THE
; MAP.  MAYBE LOOK INTO THIS LATER. FOR NOW, IGNORE THESE SCANS.

; SCOUT THROUGH DATA AND COUNT THE NUMBER OF MAP AND CAL STRUCTURES...
; GET THE FIRST OF EACH...
N_Map = 0
N_Cal = 0
MapIndx = 0
CalIndx = 0
for i = 0, NData-1 do begin

    if strmatch((*Data[i]).ProcName,'*map',/FOLD_CASE) then begin
        if (N_Map eq 0) then Map0 = (*Data[i])
        MapIndx = [MapIndx,i]
        N_Map = N_Map + 1
    endif else begin
        CalIndx = [CalIndx,i]
        N_Cal = N_Cal + 1
    endelse

    print, i, (*Data[i]).NSubScan

endfor
MapIndx = MapIndx[1:*]
CalIndx = CalIndx[1:*]

Map = replicate(Map0,N_Map)

; POPULATE MAP ARRAY...
print, 'Processing MAP...'
for i = 0, N_Map-1 do begin
    print, i+1,'/',N_Map,format='(I3,A,I3)'
    Map[i] = (*Data[MapIndx[i]])
endfor

; POPULATE CAL ARRAY...
print, 'Processing CALs...'
for i = 0, N_Cal-1 do begin 
    print, i+1,'/',N_Cal,format='(I3,A,I3)'

    ; PROCESS ALL SUBSCANS...
    nsubscans = (*Data[CalIndx[i]]).nsubscan
    for j = 0, nsubscans-1 do begin

        ; CHECK THAT A CAL WAS ACTUALLY FIRED...
;        if (total((*Data[CalIndx[i]]).subscan[j].calstate) eq 0) then begin
;            print, "Apparently CAL wasn't fired"
;            continue
;        endif

        ; MAKE STRUCTURE WITH SINGULAR SUBSCAN...
        f = (*Data[CalIndx[i]])
        caltemp = { PROJID:f.(0), $
                    SCANNUM:f.(1), $
                    NSUBSCAN:1, $
                    NCHAN:f.(3), $
                    NSTATE:f.(4), $
                    NPORT:f.(5), $
                    MJDSTART:f.(6), $
                    ACTVSURF:f.(7), $
                    SWSTATE:f.(8), $
                    SNAME:f.(9), $
                    SRA:f.(10), $
                    SDEC:f.(11), $
                    SEPOCH:f.(12), $
                    VELOCITY:f.(13), $
                    VELDEF:f.(14), $
                    PROCNAME:f.(15), $
                    PROCSEQN:f.(16), $
                    PROCSIZE:f.(17), $
                    ANTLONG:f.(18), $
                    ANTLAT:f.(19), $
                    ANTEL:f.(20), $
                    INTTIME:f.(21), $
                    POL:f.(22), $
                    BACKEND:f.(23), $
                    RCVR:f.(24), $
                    HIGHCAL:f.(25), $
                    TCALXX:f.(26), $
                    TCALYY:f.(27), $
                    SUBSCAN:f.subscan[0]}

        if (N_elements(Cal) gt 0) then begin
            ; INITIALIZE BTEMP TO HAVE SAME STRUCTURE NAME AS B1...
            btemp = Cal[0]
            ; ASSIGN THE VALUES OF B2 TO BTEMP...
            struct_assign, caltemp, btemp 
            ; CONCATENATE THE STRUCTURES...
            Cal = [Cal,btemp]
        endif else Cal = caltemp

    endfor
endfor

goto, skip

ra = dblarr(240,202)
dec = ra
ra[0:238,0:6] = ra4
dec[0:238,0:6] = dec4
ra[*,7:106] = ra1
dec[*,7:106] = dec1
ra[*,107:139] = ra2
dec[*,107:139] = dec2
ra[*,140:*] = ra3
dec[*,140:*] = dec3
ra4 = Map.SubScan.CRA2000
dec4 = Map.SubScan.CDEC2000
save, filen='~/map4.sav', ra4, dec4
ra = [[ra1],[ra2],[ra3]]
dec = [[dec1],[dec2],[dec3]]
glactc, ra, dec, 2000, gl, gb, 1, /degree
plot, gl, gb, ps=3, ys=18
plot, gl, gb, ps=3, ys=1, yr=[18.5,35.5], xs=1, xr=[112.5,133.5]
plot, [0,0], xr=9*[-1,1], /xs, yr=[0,8.5], /ys, /NODATA
oplot, Map.SubScan.AZOffSet, Map.SubScan.ZAOffSet, ps=3
plot, Map.SubScan.AZOffSet, Map.SubScan.ZAOffSet, ps=4, syms=0.1, $
xtit='AzOffSet', ytit='ZAOffSet'
plot, Map.SubScan.AZ-360*(Map.SubScan.AZ gt 180), Map.SubScan.ZA, $
ps=4, syms=0.1, xtit='Az', ytit='ZA', ys=18
glactc, Map.SubScan.CRA2000, Map.SubScan.CDEC2000, 2000, gl, gb, 1, /degree
plot, gl, gb, ps=4, syms=0.1, $
xtit='Galactic Longitude', ytit='Galactic Latitude', ys=18
oplot, gl[*,0], gb[*,0], ps=4, syms=0.2, co=!red
oplot, gl[*,1], gb[*,1], ps=4, syms=0.2, co=!blue
oplot, gl[*,2], gb[*,2], ps=4, syms=0.2, co=!green
oplot, gl[*,3], gb[*,3], ps=4, syms=0.2, co=!magenta

skip:

if (N_elements(Map) gt 0) then begin
    help, Map, Cal
    message, 'Saving...', /INFO
    save, filename=Stg1Path+FileName, Map, Cal, /VERB, /COMP
    message, 'Saving Completed.', /INFO
endif

; FREE UP THE POINTER...
ptr_free, data

end; SaveMap
