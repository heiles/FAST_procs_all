pro nryes, exclude_list, full_list, include_list, full_list_rev, nopair=nopair

;+
;CALLING SEQUENCE: 
;       NRYES, exclude_list, full_list, include_list, full_list_rev
;
;FOR EDITING DATA. you have a set of float data with ndata elements. you will
;examine the data and discard certain ranges. the array full_list
;contains the DATA, except for those elements you are discarding, which
;contain NaN 
;
;At the beginning, FULL_LIST is an array of data. It need not be
;sequential; for example,:
;
;        full_list= [65., 2., 47., 777., 48.]
;
;TO DISCARD A SINGLE ELEMENT, e.g. array element number 1, enter 
;exclude_list=[1,1] or exclude_list=1, /nopair:
;
;       NRYES, 1, full_list, include_list, full_list_rev, /nopair
;or
;       NRYES, [1,1], full_list, include_list, full_list_rev
;
;the outputs are:
;       full_list= [65., NaN., 47., 777., 48.]
;       include_list= [0, 2, 3, 4]
;       full_list_rev[ [65., 47., 777., 48.]
;
;TO DISCARD a single sequence of elements, e.g. full_list elements 2 to
;3, enter the pair, i.e. exclude_list=[3,4]]:
;
;       NRYES, [3,4], full_list, include_list, full_list_rev
;
;the outputs are:
;       full_list= [65., NaN., 47., NaN., NaN.]
;       include_list= [0, 2]
;       full_list_rev[ [65., 47.]
;
;you can discard multiple sequences by repeated calls, as above, or 
;you can make a series of pairs. For example, to accomplish the above
;two [1,1] and [3,4] in one call you can write:
;        exclude_list[ 1,1, 3,4]
;
;       NRYES, [1,1, 3,4], full_list, include_list, full_list_rev
;
;INPUTS: 
;EXCLUDE_LIST, the list of INDICES that you want to exclude. it is
;       paired, meaning excluded from first to second entry of each
;       pair, unless /nopair is set. If you don't want to exclude
;       anything, but simply to generate the output arraya, then set
;       nryes=[-1,-1] or nryes=-1, /nopair
;
;       FULL_LIST, the updated data array (previously deleted ones = NaN)
;
;KEYWORD:
;       NOPAIR. if set, exclude_list is treated as individual entries.
;
;OUTPUTS
;       FULL_LIST, the incrementally updated input FULL_LIST. Note that
;       the number of elements in FULL_LIST never
;       changes. 
;       ***IMPORTANT***: if full_list not float on input, it is
;       converted to float on output.
;
;       INCLUDE_LIST, the set of INDICES in FULL_LIST whose data values
;       have not been set to NaN (that you are not discarding). The nr of
;       elements is equal to the nr of datapoints you want to retain.
;
;       FULL_LIST_REV, the set of VALUES in FULL_LIST that you want to
;       retain. Note that FULL_LIST_REV= FULL_LIST[ INCLUDE_LIST])
;
;ANOTHER EXAMPLE
;	full_list = [0.,1.,2.,3.,4.,5.,41.,42.]
;	exclude_list= [2,4]
;       NRYES, exclude_list, full_list, include_list, full_list_rev
;then wwe have the outputs...
;	print, full_list: FULL_LIST= [0.,1.,NaN.,NaN.,NaN.,5.,41.,42.]
;	print, include_list: INCLUDE_LIST= [0,1,5,6,7] 
;	print, full_list_rev: FULL_LIST_REV= [0.,1.,5.,41.,42.]
;
;-

full_list= float( full_list)

if exclude_list[0] eq -1 then goto, skipexclude_list

IF KEYWORD_SET( NOPAIR) THEN BEGIN
if n_elements( exclude_list) ne 1 then $
        exclude_list_loc= rebin(transpose(exclude_list),2, n_elements( exclude_list)) $
        else exclude_list_loc= [ exclude_list, exclude_list] 
ENDIF ELSE exclude_list_loc= exclude_list

npairs= n_elements( exclude_list_loc)/2l
noolist= reform( exclude_list_loc, 2, npairs)

;indxyes= where( full_list ne -1)
;indxyes= lindgen( full_list)

for np=0, npairs-1l do begin
lo= noolist[ 0, np] 
hi= noolist[ 1,np]
;full_list[ indxyes[ lo:hi]]= !values.f_nan
full_list[ lo:hi]= !values.f_nan
endfor

skipexclude_list:
indxyes= where( finite( full_list) eq 1, count)

if count ne 0 then include_list= indxyes

full_list_rev= full_list[ include_list]

;stop
end
