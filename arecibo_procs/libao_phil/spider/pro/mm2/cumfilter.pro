pro cumfilter, data, range, limit, indxgood, indxbad, countbad, $
	correct=correct, median=median

;+
;PURPOSE: filter spikes from a distribution.
;
;CALLING SEQUENCE:
;
;	CUMFILTER, data, range, limit, indxgood, indxbad, countbad, $
;	correct=correct, median=median
;
;INPUTS:
;
;	DATA, the vector of data to filter; can be output, too, if
;CORRECT is set..
;
;	RANGE, the number of elements to use for defining the non-noise
;distribution. For now, set this equal to n_elements(data)/4
;
;	LIMIT, the limit above which to define points as bad. For now,
;set equal to 3. Phil tested this--the number should be bigger, but this
;works reasonably well.
;
;KEYWORDS:
;
;	CORRECT: returns the corrected version of the data in place as
;DATA. 
;
;	MEDIAN: does running median filter before doing the
;distribution. Set median when there are systematic departures from
;flatness. In fact, you might as well ALWAYS set it.
;
;OUTPUTS:
;
;	INDXGOOD, the indx numbers of the good points.
;
;	INDXBAD, the indx numbers of the bad points.
;
;	COUNTBAD, the number of bad points found
;
;METHOD:
;
;	Loosely based on looking at the central portion of the
;cumulative distribution, which is unaffeced by outliers. Use this to
;define the sigma above which you discard points.
;
;-



;common plotcolors

;filters on basis of 'cumulative distribution'
;suggest using range=n_elements( data)/4. and limit=3. 

data_orig= data
nrdata= n_elements( data)
n16=16

;IF MEDIAN IS SET, WE CUMFILTER THE MEDIAN FILTERED VERSION...
IF KEYWORD_SET( MEDIAN) THEN BEGIN
tst1= median( data_orig, n16)
tst1[ 0:n16/2]= (tst1)[ n16/2+ 1]
tst1[ nrdata- n16/2- 1: nrdata- 1]= $
	(tst1)[ nrdata- n16/2- 2]
data= data_orig- tst1
ENDIF

;WSET,0
;PLOT, data, xra=[4,123]

;SORT THE DATA WITH INCREASING VALUE...
indx= sort( data)
datasort= data[ indx]

;FIND THE RANGE OF DATA IN THE CENTRAL NUMBER OF 'RANGE' CHANNELS...
takerange= datasort[ (nrdata+range)/2]- datasort[ (nrdata-range)/2]

;MULTIPLY THIS RANGE BY 'LIMIT'; OUTSIDE THIS MULTIPLIED RANGE, DISCARD...
tkmin= datasort[ nrdata/2]- limit* takerange
tkmax= datasort[ nrdata/2]+ limit* takerange

;DEFINE THE INDICES OF GOOD AND BAD DATA...
indxgood= where( (data le tkmax) and (data ge tkmin), countgood)
indxbad= where(  (data gt tkmax) or (data lt tkmin), countbad)

;OPLOT, indxgood, data[ indxgood], color=red

;IF YOU ARE SUPPPOSED TO CORRECT THE DATA, THEN DO IT!
IF KEYWORD_SET( CORRECT) THEN BEGIN

;FOR MEDIAN OPTION, ADD THE ORIGINAL SHAPE BACK IN, and 
;	OTHERWISE JUST ADD THE MEDIAN OF THE WHOLE DATASET BACK IN.

IF KEYWORD_SET( MEDIAN) THEN BEGIN
if (countgood ne 0) then data[ indxgood]= data_orig[ indxgood]
if (countbad ne 0) then data[ indxbad]= tst1[indxbad]
ENDIF ELSE if (countbad ne 0) then data[ indxbad]= datasort[ nrdata/2]

ENDIF ELSE data= data_orig
;stop

return
end
