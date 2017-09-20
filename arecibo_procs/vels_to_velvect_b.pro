pro vels_to_velvect_b, velvectref, bin, bout, inplace=inplace

;Calling sequence:
;  vels_to_velvectref_b, velvectref, bin, bout

;INPUTS
;  BIN, the b structure from grabfits
;  VELVECTREF, the velocity array to interpolalte to
;
;OUTPUTS
;  BOUT, the new velocity-interpolated data
;    NOTE: if inplace is set, then then bin has the contents of bout.
;KEYWORD:
;  INPLACE: save memory by changing BIN and not creating a new
;  structure BOUT.;-

;sz= size( bin.d)
;nrchnls= sz[1]
;nrobs= sz[3]
nrobs= n_elements( bin)

if n_params() eq 3 then bout=bin
for nobs= 0l, nrobs-1l do begin
   vels= masfreq(bin[nobs].h, retvel=1, velcrdsys='B')
   for nsp=0,3 do begin
      spin= bin[ nobs].d[ *, nsp]
;      spout= interpol( spin, vels, velvectref)
;      if n_params() eq 3 then begin
         if keyword_set(inplace) eq 0 then $
         bout[ nobs].d[ *, nsp]= interpol( spin, vels, velvectref) $
         else bin[ nobs].d[ *, nsp]= interpol( spin, vels, velvectref) 
   endfor
endfor


end
