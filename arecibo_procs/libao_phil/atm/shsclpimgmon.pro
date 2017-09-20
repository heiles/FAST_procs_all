;
;	dir='/raid/radar/phil/t1193_20120120/'
;	fbase='t1193_20jan2012_'
;    
;--------------------------------------------------------
;Cmd CurVal   function
; c    1      channel to display (1,2)
; f    0   1  fnum,imgInfile to display
;             fnum:  0 has images: 1..11
; h           display .hdr file for this img
; l           list all files
; p           cursor position readout
; r           rescan for new files
; w    1      1 or two windows for display
; d           display image
; q           to quit
; 
;
;

function shsclpimgmon,dir,fbase,cfrAr,fiar=fiar,nhghts=nhghts,zy=zy,$
		fast=fast ,nsig=nsig
;
;  display shsclp images of decoded data
;    
;	scan the directory for decode files
;
	forward_function shsclpmonimgscan

	nsigL=[-6,6]
	if n_elements(nsig) eq 1 then nsigL=[-nsig,nsig]
	if n_elements(nsig) eq 2 then nsigL=[-nsig[0],nsig[1]]
	if n_elements(nhghts) eq 0 then nhghts=-1
	zx1=-4
	zx12=-6
	winsToUse=1						; 1 or 2 simultaneous windows
	if n_elements(zy) eq 0 then  zy=-5
	nfiles=shsclpimgmonscan(dir,fbase,fiar,firsttime=1)
	if nfiles eq 0 then begin
		print,"No files found in ",dir," ",fbase
		return,0
	endif
	chanNum=1
	iiFcur=0
	iiImgCur=0
;
;	see if > 999 files
;
	if ( fiar[iiFCur].fnum lt 1000) then begin
		fnameB=dir + fbase + string(format='(i03,".",i03)',$
				fiar[iiFCur].fnum,fiar[iiFCur].imgNumAr[iiImgCur])
	endif else begin
		fnameB=dir + fbase + string(format='(i04,".",i03)',$
				fiar[iiFCur].fnum,fiar[iiFCur].imgNumAr[iiImgCur])
	endelse
	istat=shsclprdhdr(fnameB+".hdr",hdr)
	dashes='--------------------------------------------------------'
	done=0
	while not done do begin

	print,dashes
    print,'Cmd CurVal      function'


    lab=string(format=$
    '(" c  ",i4,"         channel to display (1,2,12)")',chanNum)
    print,lab


    lab=string(format=$
    '(" f  ",i4,1x,i3,"     fnum,imgInfile to display")' ,fiar[iiFcur].fnum,$
					fiar[iiFcur].imgNumAr[iiImgCur])
    print,lab
	lab=string(format=$ 
	'("                 fnum:",i4," has images: 1..",i2)',$
				fiar[iiFcur].fnum,fiar[iiFcur].nimg)
	print,lab

    print,' h               display .hdr file for this img'
	print,lab
    print,' l               list all files'
    lab=string(format=$
    '(" n  ",f5.1," : ",f4.1," Nsig clipping.. min,max sigmas")',nsigL)
    print,lab
    print,' p               cursor position readout'
    print,' r               rescan for new files'
    lab=string(format=$
    '(" w  ",i4,"          1 or 2 windows for display")',winsToUse)
    print,lab
;
    print,' d               Display image'
    lab=string(format=$
    '(" b  ",f5.1,1x,f5.1,"  Band offsets from 430.(chn1 chn2)")',cfrAr-430)
    print,lab
    print,' z               stop in idl prog (for debugging)'
    print,' q               to quit'
	print,' '
    inpstr=''
    read,inpstr
    toks=strsplit(inpstr,' ,',/extract)
    cmd=toks[0]

    case cmd of 
;
;  band offsets
;
    'b': begin
         if n_elements(toks) ne 3 then begin
            print,'--> Enter b   offsetChan1 offsetChan2'
         endif else begin
            temp1=float(toks[1])
            temp2=float(toks[2])
			cfrAr=[temp1,temp2] + 430.
		endelse
		end
; 
;   channel to display
;
    'c': begin
         if n_elements(toks) ne 2 then begin
            print,'--> Enter c  1,2,12'
         endif else begin
            itemp=long(toks[1])
			if (itemp ne 1) and (itemp ne 2) and (itemp ne 12) then begin
            	print,'-->Enter c  1,2,12'
			endif else begin
			    chanNum=itemp
			endelse
         endelse
         end
;
;   f    fnum imgnum   to display
;
    'f': begin
         if n_elements(toks) ne 3 then begin
            print,'--> Enter f  fileNum,imgnum(1..)'
         endif else begin
            itempf=long(toks[1])
            itempI=long(toks[2])
;
;			make sure file, imgnum exist
;
			ok=1
			iifile=where(fiar.fnum eq itempf,cnt)
			if cnt eq 0 then begin
				print,"--> filenum:",itempf," doesn't exist"
				ok=0
			endif else begin
				fi=fiar[iifile]
				nimg=fi.nimg
				iiImg=where(fi.imgNumAr[0:nimg-1] eq itempI,cnt)
				if cnt eq 0 then begin
				    lab=string(format=$
					'("--> fileNum:",i4," does not have imgNum:",i4)',$
					itempf,itempI)
					print,lab
				    lab=string(format=$
					'("--> Valid imgNums are:",i4," to ",i4)',$
					fi.imgNumAr[0],fi.imgNumAr[nimg-1])
					print,lab
					ok=0
				endif
			endelse
			if ok then begin
				iiFcur=iifile
				iiImgCur=iiImg
				if ( fiar[iiFCur].fnum lt 1000) then begin
        			fnameB=dir + fbase + string(format='(i03,".",i03)',$
                    	fiar[iiFCur].fnum,fiar[iiFCur].imgNumAr[iiImgCur])
    			endif else begin
        		 	fnameB=dir + fbase + string(format='(i04,".",i03)',$
                		fiar[iiFCur].fnum,fiar[iiFCur].imgNumAr[iiImgCur])
    			endelse
 				istat=shsclprdhdr(fnameB+".hdr",hdr)
			endif
		endelse
        end
;
;	display header
;
    'h': begin
			help,hdr,/st
			print,' '
			help,hdr.tmI,/st
		end
;
;   list all files
;
    'l': begin
;
; now list the files with times
;
		for i=0,nfiles-1 do begin &$
    		ltm=fisecmidhms3(fiar[i].hdr.secMid,hr,min,sec) &$
    		lab=string(format='(" fnum:",i4," nimg:",i2," startTm: ")',$
                    fiar[i].fnum,fiar[i].nimg) + ltm &$
			print,lab
		endfor
		end
	'n': begin
         if n_elements(toks) ne 3 then begin
            print,'--> Enter n  minsig maxsig  for clipping'
         endif else begin
            nsigL=[float(toks[1]),float(toks[2])]
		 endelse
        end

    'p': begin
			 print,"Left cursor button to print, right button to quit cursor readout"
			 istat=rdcur(icur)
		end
;
; 	rescan for new files
;   firsttime=0 would speed things up but it screws up when the
;   files don't become available in ascending order
;   if while processing it finishes a short file sooner
;
    'r': begin
	 	nfiles=shsclpimgmonscan(dir,fbase,fiar,firsttime=1)
		print,nfiles," files found"
		end
; 
;   windows to display
;
    'w': begin
         if n_elements(toks) ne 2 then begin
            print,'--> Enter w  1,2'
         endif else begin
            itemp=long(toks[1])
            if (itemp ne 1) and (itemp ne 2) then begin
                print,'-->Enter w  1,2'
            endif else begin
                winsToUse=itemp
            endelse
         endelse
         end

;
;   display image
;
    'd': begin
;
		if channum eq 12 then begin
			cfr=cfrAr
			zx=zx12
		endif else begin
			cfr=cfrAr[chanNum-1]
			zx=zx1
		endelse
		useimg=0
        bw=1./hdr.smpTmUsec
		print,".. generating image.. please wait"
   		ltm=fisecmidhms3(hdr.secMid,hr,min,sec) &$
		title=string(format='("date:",i08," tm:",a)',hdr.date,ltm)
		win=(winsToUse eq 1)?1:chanNum
 		istat=shsclpimg(fnameB+".dcd",chanNum,img=img,cfr=cfr,useimg=useimg,$
        bw=bw,zx=zx,zy=zy,title=title,nhghts=nhghts,wintouse=win,fast=fast,nsig=nsigL)
		end
; stop in idl
    'z': begin
			print,"stopping in clpshsmonimg"
			stop
		 end
    'q': begin
            done=1
         end
    else: begin
		  print,"--> Invalid cmd.. try again"
          end
    endcase
	endwhile
    return,0
end
