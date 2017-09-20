; no longer works.. routines in tspro/Old
@tsinit
dir=aodefdir()
prgridio,prgrid07,dir+'tilt/7apr00/prgrid.07apr00',io="read"
tdgridio,tdpos07  ,dir+'tilt/7apr00/tdpos.07apr00' ,io="read"
note3='07apr00, full correction. (za20=...)'
pltdcor,tdpos07,prgrid07,/pitch,/roll,/prq,note3=note3
pltdcor,tdpos07,prgrid07,/focrad,/focrp,/focp,note3=note3
pltdcor,tdpos07,prgrid07,td=12 ,note3=note3
pltdcor,tdpos07,prgrid07,td=4 ,note3=note3
pltdcor,tdpos07,prgrid07,td=8 ,note3=note3
pltdcor,tdpos07,prgrid07,pitp=12 ,note3=note3
pltdcor,tdpos07,prgrid07,pitp=4 ,note3=note3
pltdcor,tdpos07,prgrid07,pitp=8 ,note3=note3
pltdcor,tdpos07,prgrid07,rolp=12 ,note3=note3
pltdcor,tdpos07,prgrid07,rolp=4 ,note3=note3
pltdcor,tdpos07,prgrid07,rolp=8 ,note3=note3
