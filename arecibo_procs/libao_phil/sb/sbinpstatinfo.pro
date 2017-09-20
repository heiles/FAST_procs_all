;+
;NAME:
;sbinpstatinfo - input a status info datafile
;SYNTAX: n=sbinpstatinfo(filename,stInfo,std=std)
;ARGS:
;filename: string     name of file to input
;KEYWORDS:
;     std:         if set, then ignore filename and read in the standard
;                  file: idl/sb/statInfoStd.dat
;RETURNS:
;n      :  int   1   ok
;               -1   first non comment line not ngroups n
;               -2   trouble parsing grpnames
;               -3   number groupnames doens't match ngroups
;               -4   grouporder keyword not 3rd non comment line
;               -10  trouble reading statinfo file
;                
;stInfo[n]: {}       struct array holding stat info
;                    for each group
;
;DESCRIPTION:
;   Input a status info datafile and return the info
;int the stInfo[] array. This data structure can then
;be passed to sbplotstat() to generate plots.
;	The file format is:
;;  ; in column 1 are comments
;ngroups  n                     .. number of separate groups in file
;groupnames {1,name1} {2,name2} .. name for each group (plot title) 
;grouporder  1 3 2              .. order to output groups
;;wd bit  grp.ord label      
;  0   0    1 000 'BODY I FF'   .. data for the plots
;  0   1    1 010.3 'K1 COLL I FF'
;  ....
;  ...
;
; You can create a new file by copying statInfoAll.dat and editing it
;The allowable edits are:
;1. you can delete any lines you don't want
;2. add more groups: 1.nnn  . 
;   - each group is output ordered by the .nnn within each group
;   - the default file has all the bits in 1 group
;     You can generate multiple groups by changing the 1.  
;3. reorder the output order within a group by changing the .nnn within each group
;   (lower numbers are output first).
;4. edit ngroups to reflect the number of groups in the file
;5. edit groupnames to have a name for each group in file
;   the format is {grpNum1,grpname1}  {grpNum2,grpname2} ... 
;   .. don't include {} in the group name since the parser uses that for the delimitors
;   if you have more than will fit on 1 line, just keep typing (without carriage return).
;6. edit grouporder to be the order that the groups are output.
;   If you want to ignore some bits, but you don't want to delete them,
;   just throw them into a unique group, and then don't add this group 
;   to the grouporder (you still need and entry in group names for each group)
;
;	The return struct array contains:
; grpI.grpnum
; grpI.grpName
; grpI.nbits
; grpI.wdAr[maxentry] 	; used nbits to limit the number to less than maxentry
; grpI.bitAr[maxentry]
; grpI.labAr[maxentry]
;
; stInfo.ngroups
; stinfo.grpOrder[ngroups]; group numbers in order to output
; stinfo.grpI[ngroups]
;-
function sbinpstatinfo,filename,stInfo,std=std
;
;	input file
;
	maxGroups=20
	maxGrpEntry=400
	grpI={grpNum: 0L ,$  ; group number 
	      grpName: "",$  ; group name
	        nbits: 0l,$  ; number of bits in group
	         wdAr:intArr(maxGrpEntry),$; byte offset this bit
	         bitAr:intArr(maxGrpEntry),$; bit within byte
	         labAr:strArr(maxGrpEntry)$; label name each bit
	}
    filenameLoc=aodefdir()+ 'sb/statInfoStd.dat'
	if (not keyword_set(std)) then filenameLoc=filename
	nrecs=readasciifile(filenameLoc,inp,comment=';')
	if nrecs le 0 then begin
		print,"Trouble reading statinfo from file:",filenameLoc
		return,-10
	endif
;
;  get ngroups
;
	a=stregex(inp[0],"ngroups +([0-9]+)",/subexpr,/extract)
	if (a[1] eq '') then begin
		print,"sbinpstatinfo: first line not ngroups n"
		return,-1
	endif
	ngrps=long(a[1])
;
; get group names
;
	a=strsplit(inp[1],"{}",/extract)
	if strtrim(a[0],2) ne "groupnames" then begin
			print,"groupnames keyword not 2nd non comment line"
			return,-2
		endif
	n=n_elements(a) 
	icur=0
	for i=1,n-1 do begin
		if strlen(strtrim(a[i],2)) eq 0 then continue
		aa=stregex(a[i],"([0-9]+) *,(.*)",/subexpr,/extract)
		if (aa[1] eq '') or (aa[2] eq '') then begin
			print,"bad label name:",a[i]
			return,-2
		endif
		gnumAr=(icur eq 0 )? long(aa[1]):[gnumar,long(aa[1])]
		gnamAr=(icur eq 0 )? aa[2]:[gnamAr,aa[2]]
		icur++
	endfor
	if icur eq 0 then  begin
		print,"sbinpstatinfo: no group labels line with valid data found"
		return,-2
	endif
	if icur ne ngrps then begin
		print,"sbinpstatinfo: number groups names doesn't match number groupnames"
		return,-3
	endif
;
; 	get grp order
;
	a=strsplit(inp[2]," ",/extract)
	if a[0] ne "grouporder" then begin
		print,"sbinpstatinfo: grouporder keyword missing"
		return,-4
	endif
	gOrderAr=long(a[1:*])

	stInfo={ ngrps: ngrps,$
		     grpOrder:gOrderAr,$ ; order for group output
			 grpI: replicate(grpI,ngrps)}
	stInfo.grpI.grpNum=gnumAr
	stInfo.grpI.grpName=gnamAr
;
;	now  parse the rest of the file
;                          wd        bit     grp        order          lab
	a=stregex(inp[3:*]," *([0-9]+) *([0-9]) *([0-9]+) +([0-9.]+)[^']*'([^']*)",/extract,/sub)
	grpAr=long(reform(a[3,*]))
	ordAr=float(reform(a[4,*]))
	labAr=reform(a[5,*])
	wdAr=long(reform(a[1,*]))
	bitAr=long(reform(a[2,*]))
	for i=0,ngrps -1 do begin
		ii=where(grpAr eq stInfo.grpI[i].grpnum,cnt)
		jj=sort(ordAr[ii])							; put in order they want
		stInfo.grpI[i].nbits=cnt
		stInfo.grpI[i].wdAr[0:cnt-1]=wdAr[ii[jj]]
		stInfo.grpI[i].bitAr[0:cnt-1]=bitAr[ii[jj]]
		stInfo.grpI[i].labAr[0:cnt-1]=labAr[ii[jj]]
	endfor
	return,1
end
