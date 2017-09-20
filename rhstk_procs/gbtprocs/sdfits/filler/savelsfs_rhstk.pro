pro SaveLSFSrhstk, Data, FileName
; SAVE OUR LSFS OBSERVATIONS...

; WE OBSERVED OH MEGAMASERS USING THE LSFS METHOD; WE USED THE GBT
; SPECTROMETER, NOT THE SPECTRAL PROCESSOR.
; WE HAD TO OBSERVE 8 FREQUENCIES, RATHER THAN CARL'S STANDARD 7
; THE OFFSETS WERE HARDWIRED...
; [-19.0, -11.0, -1.0, 0.0, +3.0, +5.0, +12.0, +20.0]

; AND WE WEREN'T ABLE TO SWITCH THROUGH ALL 8 IN A SINGLE SCAN...
; INSTEAD, EACH SCAN HAS 8 INTEGRATIONS, EACH HAVING A DIFFERENT LO SETTING
; SCANS LASTED 80 SECONDS...

;Stg1Path = getenv('GBTPATH')+'/lsfs/stg1/sav/'
Stg1Path = ''

stop

; FREQUENCY SWITCHED PROCEDURE TAKES CAL SCAN THEN FREQUENCY SWITCHED
; ON-SOURCE SCAN WITH MULTIPLE SUBSCANS...

; GET THE MAXIMUM NUMBER OF SUBSCANS...
MaxSubScans = (*data[0]).NSubScan
for i = 1, N_elements(Data)-1L do $
    MaxSubScans = MaxSubScans > (*data[i]).NSubScan

; IF THE FIRST DATA STRUCTURE IS FOR A CAL SCAN, THEN JUST COPY THE
; CAL FOLLOWING TO PRECEDE THIS...
if ((*data[0]).NSubScan gt 1) $
  then data = [data[1],data]

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; HERE WE NEED TO CORRECT FOR THE EXTRA 6TH USELESS SUBSCAN BEING
; DUMPED IN 17-POSITION MODE FOR EACH ON-SOURCE SCAN. (HAS TWO
; REFERENCE SPECTRA, EVEN THOUGH LABELLED AS SIGNAL AND REFERENCE).
; CAL FIRES BEFORE AND AFTER PATTERN.  SO END UP WITH 19 SCANS PER
; PATTERN.
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

if ((*data[0]).PROCSize ne 19) AND $
    (strpos((*data[0]).sname,'NCP-') eq -1L)  then begin

   queue = 0
   while (queue lt N_elements(Data)-1) do begin
      
      ; ONLY GO ON IF THIS SCAN IS A CAL AND THE NEXT IS NOT...
      if not(((*data[queue]).NSubScan eq 1) AND $
             ((*data[queue+1]).NSubScan eq MaxSubScans)) then begin
         queue = queue + 1
         continue
      endif
      
      if (N_elements(Cal) eq 0) then begin
         Cal = (*data[queue])
         Src = (*data[queue+1])
      endif else begin
         Cal = [Cal, (*data[queue])]
         Src = [Src, (*data[queue+1])]
      endelse
      
      queue = queue + 2
      
   endwhile
   
   ; KLUDGE TO FIX BRENDA'S DATA WHEN LO1A GOOFED UP...
   if strmatch(filename,'omc-3s*04nov14*',/FOLD) then begin
      cal.subscan.calstate = [0,1]
      cal.subscan.sigref   = [0,0]
      ; what about the freqs... they've been switched...
      cal.subscan.freq[1,*] = cal.subscan.freq[0,*]
   endif
   
endif else begin

   ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ; THIS IS NOW BROKEN FOR NCP-xx SOURCES!!!
   
   Cal = [(*data[0]),(*data[18])]
   for i = 1, 17 do begin
      
      if (i gt 1) then begin
         ; INITIALIZE BTEMP TO HAVE SAME STRUCTURE NAME AS B1...
         btemp = src[0]
         
         ; ASSIGN THE VALUES OF B2 TO BTEMP...
         struct_assign, (*data[i]), btemp
         
         ; CONCATENATE THE STRUCTURES...
         src = [src,btemp]
      endif else src = (*data[i])
      
   endfor
   
   ;!!!!!!!!!!!
   ; THIS USED TO WORK!!! AND IT STILL DOES FOR EVERYTHING EXCEPT THE 
   ; Z17 PATTERN ON THE NCP... SO LET'S JUST USE THE HEAVY-HANDED
   ; APPROACH ABOVE...
   ;      Src = (i gt 1) ? [Src,(*data[i])] : (*data[i])
   
endelse

; DID WE GET IT RIGHT...
help, Src, Cal

message, 'Saving...', /INFO
save, filename=Stg1Path+FileName, Src, Cal, /VERB, /COMP
message, 'Saving Completed.', /INFO

; FREE UP THE POINTER...
ptr_free, data

end
