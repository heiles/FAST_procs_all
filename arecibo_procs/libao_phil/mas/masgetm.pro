;+
;NAME:
;masgetm - read multiple rows from a mas fits file
;SYNTAX: istat=masgetm(desc,nrows,b,row=row,avg=avg,ravg=ravg,tp=tp,$
;                      blankcor=blankcor,float=float,double=double, $
;                      azavg=azavg,zaavg=zaavg)

;ARGS:
;    desc: {} returned by masopen
;   nrows: long rows to read
;KEYWORDS: 
;     row: long row to position to before reading (cnt from 1)
;               if row=0 then ignore row keyword
;     avg:      if keyword set then return the averaged data
;               It will average over nrows and ndumps per row.
;               the returned data structure will store the averaged
;               spectra as a float. use /double to get a double returned
;   ravg:      if set then average within a row
; hdronly:      if set then only headers (row) will be returned.no data,stat.
;blankcor:      if set then rescale any a/d blanking spectra to have the same
;               number of  accumulations as the unblanked data. This
;               implies /float. /avg or /ravg will also turn on blankcor
; float  :      if set then return spectra as  floats instead of
;               default type (int,long).
;RETURNS:
;  istat: 1 got all the requested records
;       : 0 returned no rows
;       : -1 returned some but not all of the rows
;   b[n]: {}   array of structs holding the data
; tp[n*m,2]: float array holding the total power for each spectra/sbc
;              m depends on the number of spectra per row
; azavg   :  float If /avg then the average azimuth
; zaavg   :  float If /avg then the average zenith angle
;
;DESCRIPTION:
;	Read in multiple rows from the requested data file. Return the 
;data in b[m]. 
;	If /blankcor is set then rescale any a/d blanked spectra to have the
;same number of accumulations as the unblanked data. This will return
;the data as floats.
;	If /avg is set, then  average all of the rows into a
;single spectra. If /ravg is set then average the dumps in each row
;returning a single spectra for each row. Both of these averages
;will do the blankcor before averaging.
;
; If tp= is specified, also return the total power for each spectra. 
;The /float keyword will force the returned data to be floating point
; (instead of the native datatype read from the file).
;  Any type of averaging (or /blankcor)  will automatically return
;float data. 
;
;NOTES:
; - The last row of the file could have fewer dumps than the rest of the file.
;   If last row is read and it has different dumps than the previous rows
;   in the request, then it will be ignored.
;
;-
function masgetm,desc,nrows,bb,row=row ,avg=avg,ravg=ravg,tp=tp,$
			float=float,double=double,blankcor=blankcor,$
			azavg=azavg,zaavg=zaavg,_extra=e

;
;   optionally position to start of row
;
	forward_function masmkstruct
    lrow=n_elements(row) eq 0 ? 0L:row
    usetp=arg_present(tp)
	azavg=0.
	zaavg=0.
;
;	blank correct if requested, or any type of averaging
;
	blankcorL=(keyword_set(blankcor) || keyword_set(avg) || keyword_set(ravg))
;
;   loop reading the data
;
    ngot=0L
    naccum=0L
    ntp=0L
	avgAll=keyword_set(avg)
	ravg=keyword_set(ravg)
	totRows=desc.totrows
	rowsAvail=(lrow eq 0)? (totRows-desc.currow):totRows-lrow + 1
	nrowsL=nrows
	if rowsAvail lt nrows then begin
		lab=string(format='("only ",i," rows available")',rowsAvail)
		print,lab
		nrowsL=rowsAvail
	endif
	floatl =keyword_set(float)?1:0
	doublel=0
;   if averaging, keep track of  fftaccum. return averaged value
	fftaccumSum=0L
	if keyword_set(double) then begin
		floatl=0
		doublel=1
	endif
		
;;    if usetp then tp=fltarr(nrecs,desc.nsbc<2)
    for i=0L,nrowsL-1 do begin
        istat=masget(desc,b,row=lrow,_extra=e,float=floatL,double=doubleL,blankcor=blankcorL)
        lrow=0L
        if istat ne 1 then break
        ndump=b.ndump
        case 1 of 
		   avgAll: begin
            	if i eq 0 then begin
              		npol=b.npol
			  		bb=masmkstruct(b,double=doublel,float=floatl,ndump=1,nelm=1)
			  		bb.d=0d
            	endif
            	if (ndump gt 1 ) then begin
                	bb.d=(npol eq 1)?bb.d  + total(b.d,2,double=doubleL):bb.d+$
							total(b.d,3,double=doubleL)
            	endif else begin
               		bb.d+=b.d
            	endelse
				fftaccumSum+=total(b.st.fftaccum)
				azAvg+=b.h.azimuth
				zaAvg+=90. - b.h.elevatio
            	naccum+=ndump
				end
		   ravg: begin
            	 if i eq 0 then  begin
				    npol=b.npol
                    bb=masmkstruct(b,float=floatl,double=doublel,ndump=1,nelm=nrowsL)
                    bb.d=0d
				 endif
				 bb[i].st.fftaccum=round(total(b.st.fftaccum)/(ndump*1.))
				 bb[i]=masmath(b,/avg,double=doubleL)
				 end
		  else: begin
            	if i eq 0 then begin
					 bb=replicate(b,nrowsL)
				endif else begin
;;				    if last rec not same number of dumps,ignore it.
					if (bb[0].ndump ne b.ndump) then goto,done
				endelse
             	bb[i]=b
			    end
		endcase 
        if usetp then begin
            if i eq 0 then begin
                npol=b.npol < 2
                tp=(doubleL)?dblarr(ndump*nrowsL,npol)$
                            :fltarr(ndump*nrowsL,npol)
            endif
            case 1 of 
                ndump eq 1: begin 
                    tp[ntp,*]=reform(total(b.d[*,0:npol-1],1,double=doublel),npol)
                            end
                else : begin
                     tp[ntp:ntp+ndump-1,*]=transpose(total(b.d[*,0:npol-1,*],1,double=doublel))
                     end
            endcase
            ntp+=ndump
        endif
        ngot++
    endfor
done:
    if usetp then tp=tp[0:ntp-1,*]
	if ngot gt 0 then begin
		azAvg/=ngot
		zaAvg/=ngot
	endif
    case 1 of
    ngot eq  0: begin
            bb=''
            tp=''
            return,0
         end
   nrowsL eq ngot: begin
             if keyword_set(avg) then begin
				bb.d/=naccum
				bb.st.fftaccum=round(fftaccumSum/(naccum*1.))
				bb.accum=-naccum
			endif
             if usetp  and ( (size(tp))[1] ne ntp) then tp=tp[0:ntp-1,*]
             return,1
             end
   else: begin
            if keyword_set(avg) then begin
                bb.d/=naccum
				bb.st.fftaccum=round(fftaccumSum/(naccum*1.))
				bb.accum=-naccum
            endif else begin
                bb=bb[0:ngot-1]
            endelse
            if usetp  and ( (size(tp))[1] ne ntp) then tp=tp[0:ntp-1,*]
            return,-1
         end
    endcase
end
