;+
;PURPOSE:
;SETUP_initialize_mm2.IDL.PRO.

;	Set up and initialize parameters that need it done only at the
;very beginning of using this program.

;OUTPUTS:
;	SCNDATA, a structure containing various info about the scan pattern.
;
;	AND some other variables that determine whether things are
;displayed/printed as the program runs or not. 
;-

;DEFINE THE NR OF CHNLS YOU EXPECT...
nchnls = 128

