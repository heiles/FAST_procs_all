;+
;NAME:
;cumfilter - cumfilter routine from carl heiles.
;SYNTAX: cumfilter,data,range,limit,indxgood,indxbad,countbad,
;                  median=median,correct=correct
;ARGS:
;   data[n]:        data to filter
;   range  : long   number of channels in center of distribution to use
;                   to compute limits.
;   limit  : float  used to compute the min, max values to keep.see below
;KEYWORDS:
;   median :        if set then remove a median filtered version of data
;                   before cumfiltering.
;   correct:        if set then replace the bad data. If median not set then
;                   replace bad data with the median of the entire dataset. If
;                   median set then replace bad data with the median filtered 
;                   version of the original data (filter len=16).
;RETURNS:
;indxgood[]: long  indices into data for ok data .
;indxbad[] : long  indices into data for data that should be filtered out.
;countbad  : long  number of elements in indxbad.          
;
;DESCRIPTION:
;   This is carl heiles' cumfilter routine. The basic idea is how to 
;define reasonable limits for clipping bad data when there may be
;large outliers and you don't know the distribution. The algorithm sorts
;the data and then uses a range about the center to define the limits:
;
;original data:
;   data[n]
;sorted data:
;   sdata=sort(data)
;find the hi , low value of the data set "range" elements about the
;center.
;   low =sdata[n/2-range/2]
;   high=sdata[n/2+range/2]
;set the limits of "ok" DATA to be "limit" times this low,high.
;   min=limit*low 
;   max=limit*high
;all points with values  between min,max are ok..
;
;If the median keyword is set, we median filter (filter length=16) the
;data set and remove this filtered version from the original data before
;cumfiltering ( eg: data=data - median(data,16)).
;
;If the correct keyword is set, then the bad data points are replaced by
;the median of the data set (no median keyword) or by the median filtered
;value for that point (if median keyword is set).
;
;EXAMPLE:
;   Compute the total power of a spectrum using cumfiltering.
;d[1024] are the spectral channels.
;range=1024/4
;limit=3
; cumfilter,d,range,limit,indxgood,indxbad,countbad
; tp=mean(d[indxgood])
;-
pro cumfilter, data, range, limit, indxgood, indxbad, countbad, $
        correct=correct, median=median

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
;PLOT, data

;SORT THE DATA WITH INCREASING VALUE...
indx= sort( data)
datasort= data[ indx]
;;WSET,0
;;PLOT, datasort

;FIND THE RANGE OF DATA IN THE CENTRAL NUMBER OF 'RANGE' CHANNELS...
takerange= datasort[ (nrdata+range)/2]- datasort[ (nrdata-range)/2]

;MULTIPLY THIS RANGE BY 'LIMIT'; OUTSIDE THIS MULTIPLIED RANGE, DISCARD...
tkmin= datasort[ nrdata/2]- limit* takerange
tkmax= datasort[ nrdata/2]+ limit* takerange

;DEFINE THE INDICES OF GOOD AND BAD DATA...
indxgood= where( (data le tkmax) and (data ge tkmin), countgood)
indxbad= where(  (data gt tkmax) or (data lt tkmin), countbad)


;IF YOU ARE SUPPPOSED TO CORRECT THE DATA, THEN DO IT!
IF KEYWORD_SET( CORRECT) THEN BEGIN

;   FOR MEDIAN OPTION, ADD THE ORIGINAL SHAPE BACK IN, and 
;       OTHERWISE JUST ADD THE MEDIAN OF THE WHOLE DATASET BACK IN.

    IF KEYWORD_SET( MEDIAN) THEN BEGIN
        if (countgood ne 0) then data[ indxgood]= data_orig[ indxgood]
        if (countbad ne 0) then data[ indxbad]= tst1[indxbad]
    ENDIF ELSE if (countbad ne 0) then data[ indxbad]= datasort[ nrdata/2]
ENDIF ELSE data= data_orig

return
end
