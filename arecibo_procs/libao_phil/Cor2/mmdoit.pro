;+
;NAME:
;mmdoit - input allcal sav files, convert to struct and sav
;
;SYNTAX:
;   mm=mmdoit(dir=dir)
;
;ARGS:  none 
;KEYWORDS:
;   dir : string. path for mmfiles.dat input and .sav outputs 
;         The default is '/proj/x102/cal/'
;RETURNS:
;   mm[npats]:  {mueller} return the array of mueller structs
;               one for each pattern used.
;DESCRPTION:
;   The x102 calibration normally runs mm_muelller0.idl to perform the
;calibration. It writes the output to a number of save files. These
;save files contain the information in arrays. For easier access to
;this data, mmdoit will convert these arrays to an array of structures.
;The typical sequence is:
;1. run mm_mueller0.idl in a particular directory
;   eg. /share/megs/phil/x101/x102/allcal/test
;2. create a directory where you want to store the .sav files as  
;   structures. eg. /share/megs/phil/x101/010104
;3. cp /proj/x102/cal/mmgenfiles.sc to the directory in 2.
;4. edit mmgenfiles.sc 
;   - set dirlist=( ..) list the directories that have outputs from 
;     mm_mueller0.idl (you can do more than 1 directory at a time).
;   - set rcvlist=( "12" "9" ) list of receivers you want to process. 
;5. mmgenfiles.sc in the directory in 2 (in the shell). This will create
;   the files mmfiles.dat
;6. in idl
;   @corinit
;   @mminit
;   mm=mmdoit(dir='/share/megs/phil/x101/010104/')
;      don't forget the trailling /
;7. you can now use mmrestore(dir=dir) to read them back in. 
;   also look at mmrestore documentation for a description of the data
;   structure.
;NOTES:
;   You need write access to the directory in step 2 above.
;-
function mmdoit,dir=dir
    on_error,1
    if not keyword_set(dir) then  dir='/proj/x102/cal/'
    addpath,'~heiles/pro/carls'
    addpath,'~heiles/allcal/idlprocs/xxx'
    mm=mmtostrall(dir+'mmfiles.dat')
    mmprocsav,mm,dir+'mmdata.sav'
    return,mm
end
