;
function metmonkey,lun,numLoc,fbase,useCh,singleStep,nsig,$
            dohc,dirhcl,$
            currec=curRec,recPerImg=recPerImg,profile=profile
;
;   istat:
;   1 - continue
;   2 - newfile,nextfile,  or rewind current file
;   3 - exit
;   4 - position .. currec
;   5 - debug    .. stop in metmon
;   6 - profile  .. turn on ..
;    

    ant=(useCh)?'ch':'dome'
    retstat=1

    print,'Cmd CurVal   function'
    lab=string(format=$
    '(" a ",a4,"      antenna ch, dome")',ant)
    print,lab
    lab=string(format=$
    '(" f  ",i3,"      move to new fileNum")',numLoc)
    print,lab
    lab=string(format=$
    '(" h  ",i3,"      hardcopy on (1) off (0)")',dohc)
    print,lab
    lab=string(format=$
    '(" hd ",a,"      dir for hardcopy")',dirhcl)
    print,lab
    print,' l           list all files'
    print,' n           next file (or quit if 1 file)'
    print,' q           to quit'
    lab=string(format='(" p ",i6,4x," position to rec (",i3," recs/img)")',$
                                currec,recPerImg)
    print,lab
    lab=string(format='(" pr ",i1,9x," profiles (0,1)")',$
                                profile)
    print,lab 
    print,' r           rewind current file'
;    print,lab
    lab=string(format=$
    '(" s  ",i3,"      single step 0,1")',singleStep)
    print,lab
   lab=string(format=$
    '(" sc ",f6.2,"    sigmas for scaling img")',nsig)
    print,lab

    print,' d           debugging. stop in metmon (.contine to contine)'
    print,' cur         track cursor position'
    print,' otherkey    continue'
    inpstr=''
    read,inpstr
    toks=strsplit(inpstr,' ,',/extract)
    cmd=toks[0]

    case cmd of
;
;   new antenna
;
    'a': begin
         if n_elements(toks) ne 2 then begin
            print,'Enter a  ch/dome'
         endif else begin
            ch=strlowcase(strmid(toks[1],0,1))
            case ch of
                'd': useCh=0
                'c': useCh=1
               else: print,'enter a  ch or dome'
            endcase
         endelse
         end
;
;   debug stop
;
    'd': begin
            retStat=5
         end
;
;   new file num 
;
    'f': begin
         if n_elements(toks) ne 2 then begin
            print,'Enter f  fileNum..'
         endif else begin
            numLoc=long(toks[1])
            retStat=2
         endelse
         end
;
;   turn hardcopy on,off
;
    'h': begin
         if n_elements(toks) ne 2 then begin
            print,'Enter h  0,1.'
         endif else begin
            hLoc=long(toks[1])
	 		if (hloc lt 0) or (hloc gt  1) then begin
                print,'Enter h  0,1.'
			endif else begin
				if (hloc eq 1) then begin
				; check that we have write access to directory
					if (file_test(dirhcl,/directory,/write) eq 0) then begin
						print,"You don't have write access to directory:",dirhcl
					endif else begin
						dohc=1
					endelse
				endif else begin
					dohc=0
				endelse
			endelse
         endelse
		 end
;
;   new hardcopy directory
;
    'hd': begin
         if n_elements(toks) ne 2 then begin
            print,'Enter hd directory name..'
         endif else begin
            tmpdir=(toks[1])
			if (strmid(tmpdir,0,1,/reverse_offset) ne "/") then $
						tmpdir=tmpdir + "/"

			if file_test(tmpdir,/directory) eq 0 then begin
				print,'hardcopy directory does not exist:',tmpdir
			endif else begin
				if file_test(tmpdir,/write) eq 0 then begin
				  print,'You donot have write acccess to :',tmpdir
				endif else begin
					dirhcl=tmpdir
				endelse
			endelse
            retStat=1
         endelse
         end

;
;       list filenums
;
    'l': begin
            fileSpec=fbase + '.*'
            a=findfile(filespec,count=count)
            if count gt 1 then print,a[0:count-1]
            if count gt 0 then begin
                istat=file_exists(a[count-1],size=size)
                lab=string(format='(a," size:",i10)',a[count-1],size)
                print,lab
            endif else begin
                print,'no files match:',fbase
            endelse
          end
    'n': begin
            numLoc=numLoc+1
            retStat=2
         end
;
;   position to new rec
;
    'p': begin
         if n_elements(toks) ne 2 then begin
            print,'Enter p  recNumber..'
         endif else begin
            currec=long(toks[1])
            retStat=4
         endelse
         end
    'pr': begin
         if n_elements(toks) ne 2 then begin
            print,'Enter pr 0 or 1'
         endif else begin
            profile=(long(toks[1]) ne 0)?1:0
            retStat=6
         endelse
         end
    'q': begin
            retstat=3
         end
    'r': begin
            retStat=2
         end
;
;       single step
;
    's': begin
         if n_elements(toks) ne 2 then begin
            print,'Enter s  0,1.. to turn single step off,on'
         endif else begin
            singleStep=(long(toks[1]) eq 0) ? 0 : 1
         endelse
         end
;
;       scale
;
    'sc': begin
         if n_elements(toks) ne 2 then begin
            print,'Enter sc  nsig    sigmas for scaling'
         endif else begin
            temp=(float(toks[1]))
            if temp le 0. then begin
                print, 'nsig for scaling must be > 0.'
            endif else begin
                retStat=7
                nsig=temp
            endelse
         endelse
          end
   'cur':begin
          print,"track cursor. LeftMouseButton:MarkPosition, RightMouseButton:done"
            i=rdcur(icur)
          end


    else: begin
          end
    endcase
done:
    print,''
    return,retstat
end
