;+
;NAME:
;acorexample2 - Looking at calibration data by month.
;   
;       At the end of each month, all of the calibration scans for the
;   month are processesed and stored in an idl archive file. This includes 
;   x102, x101,x113,gui calibrate button runs, etc.. . The processing includes 
;   the standard mm_mueller0 processing (which applies the current mueller
;   matrix to correct the data). It does not run mueller2_5 (these routines
;   would recompute the mueller matrix elements).
;       The output of the processing is an array mm[] of {mueller} 
;   structures (one for each pattern done). See mmrestore() for a 
;   description of this structure. 
;
;   The data is stored in the directory:
;   /share/megs/phil/x101/x102/runs
;
;   The files are:
;
;   cyymmdd1_yymmdd2.dat - these are ascii files with a list of the files
;           and scans within each file for the month.
;           yymmdd1 is the first date of the file, 
;           yymmdd2 is the last date of the file
;
;   cyymmdd1_yymmdd2.sav - these are the idl save files that contain the
;           processed data.
;
;   rcvrN.dat - An ascii file containing a list of all of the scans for 
;           receiver N for all of the data files.
;
;   As of 15apr02 the list of save files was:
;
;c010101_010131.sav  c010501_010531.sav  c010901_010930.sav  c020101_020131.sav
;c010201_010228.sav  c010601_010630.sav  c011001_011031.sav  c020201_020228.sav
;c010301_010331.sav  c010701_010731.sav  c011101_011130.sav  c020301_020331.sav
;c010401_010430.sav  c010801_010831.sav  c011201_011231.sav  c020401_020415.sav
;
;   Use the routine mmgetarchive to retrieve all or a subset of this data.
;   eg:
;
;   nrecs=mmgetarchive(010501,020501,mm,rcvnum=5)
;
;   You can then create a subset of the data with mmget.
;   You can plot the data with:
;   mmplotgtsb .. gain,tsys,sefd, beamwidth
;   mmplotcsme .. coma, sidelobes,mainbeam efficiency
;   mmplotpnterr .. pointing error
;
;-
