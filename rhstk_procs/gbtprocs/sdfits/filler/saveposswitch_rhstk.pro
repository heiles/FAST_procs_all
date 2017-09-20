pro SavePosSwitch_rhstk, Data, FileName
; SAVE OUR POSITION SWITCHED OBSERVATIONS...

;Stg1Path = getenv('GBTPATH')+'/pswitch/stg1/sav/'
Stg1Path = ''

;!!!!!!!!!!!!!!!!!!!!!!!!!
; THIS ASSUMES THAT ALL THE SRC SCANS HAVE THE SAME NUMBER OF SUBSCANS AND
; THAT THE CAL SCANS ONLY HAVE ONE SUBSCAN!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!

; GET THE MAXIMUM NUMBER OF SUBSCANS...
;MaxSubScans = (*data[0]).NSubScan
;for i = 1, N_elements(Data)-1L do $
;    MaxSubScans = MaxSubScans > (*data[i]).NSubScan

; THIS DIDN'T QUITE WORK FOR DLA OBSERVATIONS BECAUSE EVERY NOW AND THEN
; WE'D GET A SCAN THAT SAVED 214 OBSERVATIONS INSTEAD OF 213, SO WE
; SHOULD DO A MEDIAN AND CUT OFF ANY EXTRA DATA...
NSubScans = lonarr(N_elements(Data))
for i = 0, N_elements(Data)-1L do $
    NSubScans[i] = (*data[i]).NSubScan
MaxSubScans = median(NSubScans)

; IF THE FIRST DATA STRUCTURE IS FOR A CAL SCAN, THEN JUST COPY THE
; CAL FOLLOWING TO PRECEDE THIS...
;if ((*data[0]).NSubScan gt 1) $
;   then data = [data[1],data]

for i = 0, N_elements(Data)-1L do begin
   case 1 of
      ((*Data[i]).NSubScan eq 1) OR $
      ; KLUDGE FOR REGINA'S 0458 GOOFUP...
      (((*Data[i]).SName eq '0458-02') AND (*Data[i]).NSubScan eq 2): $
         Cal = (N_elements(Cal) eq 0) ? (*data[i]) : [Cal,(*data[i])]
      (*Data[i]).NSubScan eq MaxSubScans : $
         Src = (N_elements(Src) eq 0) ? (*data[i]) : [Src,(*data[i])]
      ; FORGET IT, THIS WAS WAY TOO HARD...
      ;(*Data[i]).NSubScan gt MaxSubScans : begin
         ; CUT OUT EXTRA INTEGRATIONS AND TELL US WE'RE DOING THIS...
         ;message, /INFO, 'Scan '+strtrim((*Data[i]).ScanNum,2)+' has '+$
         ;         strtrim((*Data[i]).NSubScan,2)+' subscans, which is '+$
         ;         'greater than the median number ('+strtrim(MaxSubScans,2)+$
         ;         ') so we chopped off the last bunch of integrations.'
         ;(*data[i]).nsubscan = MaxSubScans
         ;(*data[i]).subscan = (*data[i]).subscan[0:MaxSubScans-1]
   ;end
      else : message,  /INFO, "Don't know what to do with Scan "+$
                      strtrim((*Data[i]).ScanNum,2)
      
   endcase
endfor

;; queue = 0
;; ;while (queue lt N_elements(Data)-1) do begin
;; while (1 eq 0) do begin
   
;;    ; ONLY GO ON IF THIS SCAN IS A CAL AND THE NEXT IS NOT...
;;    if not(((*data[queue]).NSubScan eq 1) AND $
;;           ((*data[queue+1]).NSubScan eq MaxSubScans)) then begin
;;       queue = queue + 1
;;       continue
;;    endif
   
;;    if (N_elements(Cal) eq 0) then begin
;;       Cal = (*data[queue])
;;       Src = (*data[queue+1])
;;       stop
;;    endif else begin
;;       Cal = [Cal, (*data[queue])]
;;       Src = [Src, (*data[queue+1])]
;;    endelse
   
;;    queue = queue + 2
   
;; endwhile
   
; DID WE GET IT RIGHT...
help, Src, Cal

message, 'Saving...', /INFO
save, filename=Stg1Path+FileName, Src, Cal, /VERB, /COMP
message, 'Saving Completed.', /INFO

; FREE UP THE POINTER...
ptr_free, data

end
