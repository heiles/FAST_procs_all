;+
;NAME:
;coroutput - output a cor data structure to disc
;
;SYNTAX: coroutput,lunout,b
;
;ARGS:
;       lunout  :   int lun for file to write to.
;            b[]:   {corget} a corget structure or an array of corget structs.
;RETURNS:
;       nothing
;DESCRIPTION:
;   Output a corget structure to disc. You can then read this back in
;with corget at a later time.
;WARNINGS:
;   1. The {corget} structure has an extra element after the hdr structure. It
;      is stripped off before writing it out so that data can be read in with
;      corget().
;   2. On input corget() will flip the input data order if it is in
;      decreasing frequency order on disc (determined by a bit in h.cor.state).
;      This output routine assumes that the data has already been converted to
;      increasing frequency order and it will set the bit in h.cor.state
;      so that it will not be reflipped when input with corget().
;   3. corget() will scale the data on input using the total power (this is
;      the nine level total power correction(). It is ok to apply the
;      scaling multiple times since it is:
;        scale*(data/Mean).. but if you are outputing data that is the
;        rms/mean rather than spectral data, then be sure you use the /noscale
;        option to corget().
;-
pro coroutput,lunout,b
    nrecs=(size(b))[1]
    nbrds=b[0].b1.h.cor.numbrdsused
    for j=0,nrecs-1 do begin
        for i=0,nbrds-1 do begin
            b[j].(i).h.cor.state=(b[j].(i).h.cor.state and 'ffefffff'XL)
            writeu,lunout,b[j].(i).h
            writeu,lunout,b[j].(i).d
        endfor
    endfor
    return
end
