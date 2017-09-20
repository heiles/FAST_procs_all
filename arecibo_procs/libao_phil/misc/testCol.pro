;
; test color..
;
; default order of requesting visual
;
;1. DirectColor, 24-bit
;2. TrueColor, 24-bit
;3. PseudoColor, 8-bit, then 4-bit
;4. StaticColor, 8-bit, then 4-bit
;5. GrayScale, any depth
;6. StaticGray, any depth
;
; commands to request a visual
; device,pseudo=8
; device,direct=bitsPerPix
; device,true=bitsPerPix
;                                           decomp vdepth  vname 
; default 								    1      24      true color
;device,direct=8                           unsupported
;device,direct=16                          unsupported
;device,direct=24                           1     24       true color
;
;device,true=8                           1        24       truecolor
;device,true=16                          1        24       truecolor
;device,true=24                          1        24       true color
;
; looks like decomposed works with direct or true. can call it before or
; after visual request
;device,decomposed=0
;device,direct=24                        0     24       true color
;
; beware some of these will make a connection and force a default visual..
;
device,direct=24
device,decomposed=1
device,get_decomposed=decol
device,get_visual_name=vname
device,get_visual_depth=vdepth
print,'decol:',decol,' vname:',vname,' vdepth:',vdepth
device,retain=2
;
;
;decol:           0 vname:TrueColor vdepth:          24
;  ldcolph, plot ok 
;  corplot,plot .. ok
;  imgdisp .. nope
;decol:           1 vname:TrueColor vdepth:          24
;  ldcolph, plot color red doesn't work
;  corplot,plot .. ok
;  imgdisp .. nope
; need to have the backing store done by ..
addpath,'h'
@hdrGen.h
@hdrCor.h
@hdrMueller.h
addpath,'Cor2'
; @procfileinit
.compile corhquery
.compile dophquery
.compile pnthquery
.compile iflohquery
file='/share/olcor/corfile.12jul03.x113.1'
openr,lun,file,/get_lun
rew,lun
print,corinpscan(lun,b)
;
ldcolph
plot,findgen(100)
oplot,findgen(100)+2,color=2

corplot,b
img=corimgdisp(b)
