;+
;NAME:
;masfreq - return freq (or vel) array for a spectra
;SYNTAX: retData=masfreq(hdr,retvel=retvel,restFreq=restFreq,velCrdSys=velCrdSys)
;ARGS:
;    hdr  : {}     fits header b.h returned from masget();
;  retvel :        if set then return the velocity array in the velocity coordinate system
; restFreq:float   if retvel is set, use this for the rest freq rather than the
;                  value in the header. Units are MHz.
;velCrdSys: string:user can specify a different velocity coordinate system from
;                  that in the header.
;                  Values are: 'T': topocentric,'G':geocentric,'B':barycenter,
;                              'L;: lsr
;RETURNS:
;     retDat[]:  frequency array in Mhz for the points in the spectra
;                or the velocity array in km/sec
;DESCRIPTION:
;	For returning velocity:
;1. compute topocentric frequencies:freqTop
;2. compute antenna velocity in velocity coord sys projected in ra,dec direction.
;3. compute freq in velCrdSys   :freqVcs=freqTopo*(1-antVelProj/c)
;4. vel=c*(restFrq/freqVcs -1)
;   - user can specify a different restFreq from what is in the header
;     using the keyword restFreq
;
; - currenly returns vel optical
; - also assumes velocity << c.
; - Uses the topocentric freq and the projected antenna velocity
;    for the reqested ra,dec. This comes from the jpl ephm every sec from pointing.
;   It does not use the velocity in the header
; history:
;25oct11: switched to used dindgen instead of findgen. 
;         was always double anyway (from the constants).
;
;-
function masfreq,hdr,retvel=retvel,restFreq=restFreq,velCrdSys=velCrdSys
;
;   optionally position to start of rec
;
    mastdim,hdr,nchan=nchan
    freqTopo=(dindgen(nchan) - (hdr[0].crpix1 -1))*hdr[0].cdelt1*1d-6 +$
             hdr[0].crval1*1d-6
	if (not keyword_set(retvel)) then return,freqTopo

	velC_Ms=299792458D			; vel light meters/sec since that's what hdr has
	velC_KmS=299792.458D		; vel light meters/sec since that's what hdr has
;
; 	compute the antennas in the velocity coord sys projected
;   to the ra,dec direction.
;   computed velocites below are in fractions of C
;
	
	if not keyword_set(velCrdSys) then velCrdSys=strmid(hdr.req_sys,0,1)
	case  velCrdSys of 
    'T': antVelProj=0D 						; topo centric
    'G': antVelProj=hdr.vel_geo/velC_Ms     ; geocentric &$
    'B': antVelProj=hdr.vel_bary/velC_Ms    ; barycentric &$
    'L': begin &$
;       get 3D direction j2000
        radec3=anglestovec3(hdr.crval2*!dtor,hdr.crval3*!dtor) &$
        antVelProj=vellsrproj(radec3,hdr.vel_bary/velC_Ms) &$
        end &$
    else: begin
		print,"unknown velocity coord system:"
		return,0
 		end
	endcase
;
;	compute freq in vel coord sys.
;
	freqVelCs=freqTopo*(1d - antVelProj) 
	restFreqMhz=(keyword_set(restFreq))?restFreq:hdr.restfrq*1e-6
    return,velC_KmS*(restFreqMhz/freqVelCs - 1D)
end
