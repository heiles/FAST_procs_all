;+
;NAME:
;recombsearch - search  for recombination lines within a freq range.
;SYNTAX: n=recombsearch(freqMin,freqMax,match,lineStepR=lineStepR,$
;                        lineNumR=lineNumR,atoms=atoms
;ARGS:
;     freqMin: float  min frequency in Mhz to use.
;     freqMax: float  max frequency in Mhz to use.
;KEYWORDS:
;lineStepR[2]: int    min,max step for line transitions to use. The
;                     Default is 1 (alfa) to  10 (??)
; lineNumR[2]: int    min,max  line numbers to use. The default is 75 to
;                     500.
;     atoms[]: string An array of atoms to search. The default is:
;                     'H','He','C'. See recombfreq keyword pertbl for
;                     a list of the names.
;RETURNS:
;          n : long   number of transitions found.
;    match[n]: {}     an array of structures holding the recomb lines that
;                     were found.
;
;DESCRIPTION:
;   Look for all of the atomic transitions between frequencies freqMin and
;freqmax. Return the number of transitions found and an array (match) holding
;the information of each transform. The match structure contains:
;
;** Structure <82c1a1c>, 4 tags, length=24, data length=24, refs=1:
;   ATOM            STRING    'H'            .. name of the atom
;   LINENUM         LONG               157   .. line number
;   LINESTEP        LONG                 1   .. transition 1=alpha,2=beta..
;   FREQ            FLOAT           1683.20  .. rest frequency of transition.
;
;   By default the routine searches the atoms H, He,C for line steps of 1..10,
;and linenumbers 75 through 500.
;
;EXAMPLES:
;   Suppose you have data between 1664 and 1686Mhz and you want to find 
;all transitions that satify: step size 1 thru 5  in atoms H,He, and C. 
;   n=recombsearch(1664,1685,match,lineStepR=[1,5],atoms=['H','He','C'])
;
;   plot your data flagging these transitions
;   corplotrl,b,match 
;
;SEE ALSO: recombfreq,corplotrl
;-
;
function recombsearch,freqMin,freqMax,match,lineStepR=lineStepR,$
                     lineNumR=lineNumR,atoms=atoms
;
; 15Gh to 259Mhz for step 1 to 5
lineNumRloc=[75,500]
lineStepRloc=[1,10]
atomAr=['H','He','C']
;
if n_elements(linestepR) eq 2 then lineStepRloc=lineStepR
if n_elements(lineNumR) eq 2 then  lineNumRloc =lineNumR
if n_elements(atoms) gt 0    then  atomAr=atoms
;
numLineNum=lineNumRLoc[1]-lineNumRloc[0] + 1L
numLineStep=lineStepRLoc[1]-lineStepRloc[0] + 1L
lineNumAr =lindgen(numLineNum)  + lineNumRLoc[0]
lineStepAr=lindgen(numLineStep) + lineStepRLoc[0]
;
a={    atom: '' ,$
       linenum: 0L,$
       linestep   : 0L,$
       freq       : 0.}
match=replicate(a,5000)
num=0
for ia=0,n_elements(atomAr)-1 do begin
    for i=0,numLineStep-1 do begin
        freq=recombfreq(atomAr[ia],lineNumAr,linestepAr[i])
        ind=where((freq ge freqMin) and (freq le freqMax),count)
        if count gt 0 then begin 
            match[num:num+count-1].atom   =atomAr[ia]   
            match[num:num+count-1].linenum=lineNumAr[ind]
            match[num:num+count-1].lineStep=lineStepAr[i]
            match[num:num+count-1].freq    =freq[ind] 
            num=num+count
        endif
    endfor 
endfor
if num gt 0 then begin 
    match=match[0:num-1]
endif else begin
    match='' 
endelse
return,num
end
