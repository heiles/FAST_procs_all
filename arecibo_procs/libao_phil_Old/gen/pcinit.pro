@geninit
addpath,"Cor2
addpath,'pc/gen' 
addpath,'pc/Cor2' 
@hdrCor.h
.compile corhquery
.compile dophquery
.compile pnthquery
.compile iflohquery
addpath,"Cor2/cormap"
forward_function corget,chkcalonoff,corallocstr,coravgint,corcalonoff,$
        corcalonoffm,corfrq,corgethdr,corgetm,corimg,corinpscan,$
        cormedian,corposonoff,corposonoffm,corpwr,corpwrfile,corrms,$
        mmget ,cormapsclk
