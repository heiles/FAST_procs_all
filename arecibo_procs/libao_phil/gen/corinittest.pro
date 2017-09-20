;
;   corinit test version
addpath,"/home/phil/idl/Cor2
addpath,"/home/phil/idl/test/gen"
addpath,"/home/phil/idl/test/Cor2
@/home/phil/idl/test/h/hdrCor.h
p8
ldcolph
.compile corhquery
.compile dophquery
.compile pnthquery
.compile iflohquery
addpath,"/home/phil/idl/Cor2/bmapazc"
addpath,"/home/phil/idl/Cor2/cormap"
;.compile corgethdr
;.compile corget
;.compile corwaitgrp
;.compile corlist
;.compile corfrq
;.compile corpwr
;.compile corhan
;.compile corplot
;.compile cornext
;.compile corloopinit
;.compile corloop
;.compile corwaitgrp
;.compile cormon
forward_function corget
