; 
;NAME:
;lbnperf - return lband narrow performance vs za curves (at 1400Mhz)
;SYNTAX: lbnper(za,gain,tsys)
;ARGS:  za[]:   float requested za
;RETURNS:
;       gain[]: float relative gain performance
;       tsys[]: float relative tsys.
;DESCRIPTION:
;   Return relative gain and tsys vs za. Taken from lband source 
;1998.
; gain  - Tsys/Jy
; Tsys  - 1= tsys about 4 deg ??
; 
pro lbnperf,za,gain,tsys
    gain=.31079595 + $
        za*(.00744506 + za*(-.00174542 + za*(.1498039e-3 -.44974e-5*za)))

    tsys=1.01372322 + $
       za*(-.01085344 + za*(.00250253 + za*(-.00019188 +za*.00000562)))
    return
end
