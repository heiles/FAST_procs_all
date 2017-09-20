pro SaveFreqPosSwitch_rhstk_mc, Data, FileName
; 05 JUN 2012...
; WE'VE DECIDED TO SAVE THE FSWITCH AND PSWITCH DATA IN EXACTLY THE
; SAME WAY...
; (1) ANY SCAN WITH A SINGLE SUBSCAN AND A CAL FIRED WILL BE ADDED TO A
; VARIABLE CALLED CAL.
; (2) ANY SCAN WITH MORE THAN 1 SUBSCAN IS CONSIDERED AN ON-SOURCE
; OBSERVATION AND WILL BE ADDED TO A VARIABLE CALLED SRC.
; (3) THIS WILL CHOKE IF THE NUMBER OF SUBSCANS (OR INTEGRATIONS) VARIES
; FOR ON-SOURCE OBSERVATIONS OR IF THERE IS MORE THAN ONE INTEGRATION FOR A
; CAL SCAN. YOU'LL HAVE TO EDIT THIS FILE ACCORDINGLY TO SUIT YOUR
; OBSERVATIONS IF EITHER OF THESE IS TRUE.

;!!!!!!!!!!!!!!!!!!!!!!!!!
; THIS ASSUMES THAT ALL THE SRC SCANS HAVE THE SAME NUMBER OF SUBSCANS AND
; THAT THE CAL SCANS ONLY HAVE ONE SUBSCAN!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!

; GET THE MAXIMUM NUMBER OF SUBSCANS...
;
; THIS DIDN'T QUITE WORK FOR DLA OBSERVATIONS BECAUSE EVERY NOW AND THEN
; WE'D GET A SCAN THAT SAVED 214 OBSERVATIONS INSTEAD OF 213, SO WE
; SHOULD DO A MEDIAN AND CUT OFF ANY EXTRA DATA...
NSubScans = lonarr(N_elements(Data))
for i = 0, N_elements(Data)-1L do $
    NSubScans[i] = (*data[i]).NSubScan
MaxSubScans = median(NSubScans)

for i = 0, N_elements(Data)-1L do begin
   
   scan = (*Data[i])

   ; CALS ARE ASSUMED TO HAVE A SINGLE SUBSCAN AND MUST HAVE HAD THE CAL GO
   ; OFF...

   nsubscan = 15
   if (Scan.NSubScan eq nsubscan) AND (total(Scan.Subscan.CalState) gt 0) $
          then begin
      Cal = (N_elements(Cal) eq 0) ? Scan : [Cal,Scan]
      continue
   endif

   if (Scan.NSubScan eq MaxSubScans) $
      then Src = (N_elements(Src) eq 0) ? Scan : [Src,Scan] $
      else message, 'Scan '+strtrim(Scan.ScanNum,2)+' has a strange number of subscans.'
      
endfor
   
; DID WE GET IT RIGHT...
help, Src, Cal

message, 'Saving...', /INFO
save, filename=FileName, Src, Cal, /VERB, /COMP
message, 'Saving Completed.', /INFO

; FREE UP THE POINTER...
ptr_free, data

end
