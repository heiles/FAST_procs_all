;+
;NAME:
;tdparms - return parameters used for tiedown computations.
;SYNTAX: tdparms,reftdpos=reftdpos,limits=limits,slimits=slimits,$
;               reftemp=reftemp,$
;               plInperDegF=plInperDegF,tdRadiusHor= tdRadiusHor$
;               RotScale=rotScale,trScale =trScale,Sscale=S,date=date
;               inchPerEncCnt=inchPerEncCnt,encCntPerInch=encCntPerInch,$
;                cntsToKips=cntsToKips
;ARGS: none
;KEYWORDS:
;   reftdpos[3]: float reference position focus at ref temp. td inches
;   limits[2,3]: float (min/max,td12/4/8) min (extended), max tiedown limits.
;   slimits[2,3]: float (min/max,td12/4/8) min (extended), max tiedown limits.
;                      these are the soft limits .2 inches inside the others.
;   refTemp    : float reference temperature for refpos. deg F
;   plInPerDegF: float platform motion(inches) per deg F. (-.205)
;   tdRadiusHor: float center triangel to tiedown cable
;   rotScale   : float ratio absolute value( tdin/platformin) when rotating
;    trScale   : float ratio absolute value( tdin/platformin) when pulling down
;        Sscale: float (1deg*pi/180*192*12*rotScale)
;   date       : long  yymmdd date to use. default is most recenter data
; inchPerEncCnt: float inches per encoder count
; encCntPerInch: float encoder counts/inch (1./inchPerEncCnt)
; cntsToKips   : float to convert loadcell counts to kips
;-
pro tdparms ,reftdpos=reftdpos,limits=limits,slimits=slimits,reftemp=reftemp,$
            plInperDegF=plInperDegF,tdRadiusHor= tdRadiusHor,$
            RotScale=rotScale,trScale =trScale,SScale=S,date=date,$
            inchPerEncCnt=inchPerEncCnt,encCntPerInch=encCntPerInch,$
			cntsToKips=cntsToKips
 
    datel=keyword_set(date) ? (date) : 999999L
        
	cntsToKips=.02
    inchPerEncCnt=2.29024976e-5
    encCntPerInch=43663.36
;    reftdpos=[14.697,14.438,13.065]
;    refplHght=1256.35
;    refTemp=72.
;    reftdpos=[15.072,15.320,15.093]  ; 12dec07
     reftdpos=[14.133,15.530,15.822]  ; 22may12 after beam repair
    refplHght=1256.22
    refTemp=70.
    limits=[[1.43,22.29],$
            [1.93,22.87 ],$
           [1.19,22.20 ]]
    slimits=limits
    slimits[0,*]=slimits[0,*]+.2
    slimits[1,*]=slimits[1,*]-.2
    plInPerDegF=-.205   ; platform inches per def F
    tdRadiusHor=192.    ; center triangle to td cable
    rotScale   =1.31    ; tdInch/platform inch when rotatins (abs value)
;    trScale    =1.66    ; tdInch/platform inch when pullin   (abs value)
    trScale    =1.73    ; tdInch/platform inch when pullin   (abs value)
    S=40.212*rotScale  ; 1deg*pi/180*192*12*rotScale
    case 1 of
       (datel ge 030217) and (datel lt 030301) : begin
;
;       values of temp, platform hght, tdpos for 17feb03 survey
;
            refTemp=69.5
            refplHght=1256.35
            reftdpos=[12.6343,12.3753,11.0022] ; td position 17feb03 survye
        end
       ((datel ge 030301)  and (datel lt 071212 )): begin
            refTemp=70. 
            refplHght=1256.22
            reftdpos=[ 14.8751,14.6161,13.2431]; after dome move 
        end
       ((datel ge 071212)  and (datel lt 120522 )): begin
            refTemp=70. 
            refplHght=1256.22
            reftdpos=[15.072,15.320,15.093]  ; 12dec07
		end
    else: a=0
    endcase
    return
end
