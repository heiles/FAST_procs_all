;+
;NAME:
;mm0ninitwas -  initialize for the new mueller 0 processing
;SYNTAX: @corinit   
;DESCRIPTION:
;   call this routine before doing the new mueller 0 processing
;-
dir1=aodefdir()
cd,dir1,current=cwd
@./spider/pro/was/start_cross3.idl.pro
cd,cwd
