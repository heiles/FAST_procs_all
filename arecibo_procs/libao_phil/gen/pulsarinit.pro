; initialize to use some idl pulsar routines
@geninit
addpath,'pulsar'
; get updated version
@sp_dedisp.h

forward_function sp_dedisp1,sp_dmdelay,sp_dmshift,$
				 tempo_comp,tempo_getdata
