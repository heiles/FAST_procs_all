pro fit_z17, delta_x, delta_y, stki, derivs, sigderivs, $
             third=third, gainfit=gainfit, chnls_online=chnls_online, fitted=fitted

;+
;FIT_Z17: fit the 17 positions to derive the angular derivatives. 
;
;CALLING SEQUENCE: 
;fit_z17, delta_x, delta_y, stki, chnlmin, chnlmax, derivs, sigderivs
;
;INPUTS:
;DELTA_X[17], DELTA_Y[17] : the GREAT-CIRCLE angular offsets in whatever units
;                        you wish
;STKI[ nchan, 17], the stokes total intensity spectra for the 17 positins
;
;KEYWORD:
;THIRD, include third derivatives if set.
;GAINFIT. if set, it 'GAIN-corrects; the derivatives using POLYFIT
;CHNLS_ONLINE: must be defined if GAINFIT is set. defines chnls to use for GAINFIT
;if FITTED is defined, it returns the 17 fitted spectra

;OUTPUT:
;DERIVS, the vector of taylor expansion parameters, in the following order:
        ;T
        ;dT/d(delta_x)
        ;dT/(delta_y)
        ;d2T/d(delta_x)2
        ;d2T/d(delta_y)2
        ;d2T/d(delta_x)d(delta_y)
;if THIRD is set, derivs has four more elements:
        ;d3T/d(delta_x)^3
        ;d3T/d(delta_x)^2 d(delta_y)
        ;d3T/d(delta_x) d(delta_y)^2
        ;d3T/d(delta_y)^3
;SIGDERIVS, the vector of errors in taylor expansion parameters
;
;-

; DO THE LEAST-SQUARES FIT FOR EACH CHANNEL...

ndata= 17
nchnls = N_elements(  stki)/ ndata
fitted= fltarr( nchnls, ndata)

;>>>>>>>>> NOTE!!! MATRIX MULTS BELOW ARE OPPOSITE OF HEILES CONVENTION!!! <<<<<<<<
ncoeffs= 6
s = [[fltarr(ndata)+1.],$
     [delta_x],$
     [delta_y],$
     [0.5*(delta_x)^2],$
     [0.5*(delta_y)^2],$
     [delta_x*delta_y]]

if keyword_set( third) then begin
ncoeffs= 10
st= fltarr( ndata, ncoeffs)
st[ *, 0:5]= s
st[ *, 6]= delta_x^3/6.
st[ *, 7]= delta_x^2*delta_y/2.
st[ *, 8]= delta_x*delta_y^2/2.
st[ *, 9]= delta_y^3/6.
s=st
endif

derivs = fltarr(nchnls, ncoeffs)
sigderivs= fltarr(nchnls, ncoeffs)
for chnl = 0, nchnls-1 do begin
    t = stki[ chnl, *]
    ss = s ## transpose(s)
    st = s ## transpose(t)
    ssi = invert(ss)
    a = ssi ## st
    bt = transpose(s) ## a
    resid = t - bt
    fitted[ chnl, *]= bt
    derivs[chnl, *] = a

sigsq = total(resid^2)/( ndata-ncoeffs)
sigarray = sigsq * ssi[ indgen( ncoeffs)* ( ncoeffs+1)]
sigderivs[ chnl, *]= sqrt( abs(sigarray))

endfor

;GAIN-CORRECT THE DERIVITAVES IF REQUESTED...
if keyword_set( gainfit) eq 0 then return

i0= derivs[*,0]/2.

chnl1a= min(chnls_online, max=chnl2a)
i00= i0[ chnl1a:chnl2a]

for nc= 1, ncoeffs-1 do begin
v0= derivs[ *,nc]
polyfit, i00, v0[chnl1a:chnl2a], 1, coeffs, sigcoeffs, yfit
vmodp= coeffs[0]+ coeffs[1]* i0
derivs[ *,nc]= v0- vmodp
;stop
endfor

return

end

