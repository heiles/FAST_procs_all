;+
;NAME:
;intm_pdevalfa_pr - print out intm_pdevalfa intermod info
;SYNTAX:intm_pdevalfa_pr,retI,html=html
;ARGS:
; retI[n]: {}     structure from intm_pdevalfa to print info.
;KEYWORDS:
;html        :   if set then output html code to make a table.
;RETURNS:
;DESCRIPTION:
;	Print out the info returned from intm_pdevalfa.
;
;-
pro intm_pdevalfa_pr,retI,html=html,lunout=lunout
;
; loop processing each radar
;
	if n_elements(lunout) eq 0 then lunout=-1
	nl=string(10b)
	q ='"'
	if keyword_set(html) then begin
	tds="<td>" &$
	tdsa='<td style="vertical-align: top; text-align: center;">' &$
	tdsb='<td style="font-weight: bold;">' &$
	tde="</td>" &$
	tdes=tde+tds &$
	tdse=tds+tde &$
	trs="<tr>" &$
	tre="</tr>" &$
	algnV="vertical-align: top; "
	bold="font-weight: bold; "
	algnVB=algnV+bold
	sp="   "
	tblE="</body>" + nl + "</table>"
	tblS1='<br>' + nl + $
		 '<table style="text-align: left; width: 550px;" border="1" ' + nl + $
         '       cellpadding="2" cellspacing="2">'                    + nl + $
         '  <caption style="font-weight: bold;">ALFA CFR=' + $
				 string(format='(i4)',long(retI[0].lo1 - retI[0].if1 + .5))    + $
             ' Radar Intermods with 1st mixer</caption>' + nl + $
    	'<tbody>' + nl + $
     '<tr>' + nl + $
     '<td style="'+algnVB + '">Radar<br> </td>' + nl + $
     '<td style="'+algnVB + '">Radar<br> Freq<br> </td>' + nl + $
     '<td style="'+algnVB + 'text-align: center;">' + 'order<br> 1st Lo<br></td>' + nl + $
      '<td style="'+algnVB+ 'text-align: center;">' + 'order<br> RdrFreq<br> </td>' + nl + $
      '<td style="'+algnVB+ 'text-align: center;">' + 'IF <br> Freq<br> </td>' + nl + $
      '<td style="'+algnVB+ 'text-align: center;">' + 'Sky<br> Freq<br> </td>'

	tblS2='<br>' + nl + $
         '<table style="text-align: left; width: 650px;" border="1" ' + nl + $
         '       cellpadding="2" cellspacing="2">'                    + nl + $
         '  <caption style="font-weight: bold;">ALFA CFR=' + $
				 string(format='(i4)',long(retI[0].lo1 - retI[0].if1)) + $
             ' Radar Intermods 2ndmixer. Band=' + $
			 string(format='(f6.1," (",i3," IF)")',$
			(retI[0].lo1-2*retI[0].if1 + retI[0].lo2),long(retI[0].lo2 + .5)) + $
				'</caption>' + nl + $
    	'<tbody>' + nl + $
     '<tr>' + nl + $
     '<td style="'+algnVB + '">Radar<br> </td>' + nl + $
     '<td style="'+algnVB + '">Radar<br> Freq<br> </td>' + nl + $
     '<td style="'+algnVB + '">IF<br> Freq<br> </td>' + nl + $
     '<td style="'+algnVB + 'text-align: center;">' + 'order<br> 2ndLo</td>' + nl + $
      '<td style="'+algnVB+ 'text-align: center;">' + 'order<br> Radar</td>' + nl + $
      '<td style="'+algnVB+ 'text-align: center;">' + 'baseband<br>Freq</td>' + nl + $
      '<td style="'+algnVB+ 'text-align: center;">' + 'skyFreq<br>+<br> </td>' + nl + $
      '<td style="'+algnVB+ 'text-align: center;">' + 'skyFreq<br>-<br>'  +  '</td>'
	endif
	nrdr=n_elements(retI)
	for ifrq=0,nrdr-1 do begin
		n=retI[ifrq].numEntry 
		if retI[ifrq].mixerused eq 1 then begin
			if keyword_set(html) then begin
	            if ifrq eq 0 then  printf,lunout,tblS1
            	for i=0,n-1 do begin &$
					if i eq 0 then begin
				  		l1=trs + tdse + "<td rowspan=" $
							+ string(format='(a,i0,a," style=font-weight:bold;>",f6.1,a)',$
							   q,n,q,retI[ifrq].rdrsky,tde) + nl
					endif else begin
				  		l1=trs + tdse  + nl
					endelse
					l2=$
               sp + tdsa + string(format='(i0)',retI[ifrq].mix1[i].nlo) + tde    + nl + $
               sp + tdsa + string(format='(i0)',retI[ifrq].mix1[i].nrfi) + tde   + nl +  $
			   sp + tdsa + string(format='(f5.1)',retI[ifrq].mix1[i].if1V) + tde + nl +  $
			   sp + tdsa + string(format='(f6.1)',retI[ifrq].mix1[i].skyF) + tde
				    printf,lunout,l1 + l2 + tre
				endfor
		  	endif else begin
				lab=string(format='(f7.2,1x,i2)',retI[ifrq].rdrSky,n)
            	printf,lunout,lab
				for i=0,n-1 do begin
                	lab=string(format='(i2,1x,i2,1x,f5.1,1x,f6.1)',$
                   	 retI[ifrq].mix1[i].nlo,retI[ifrq].mix1[i].nrfi,$
                   	 retI[ifrq].mix1[i].if1V,retI[ifrq].mix1[i].skyF)
               		 printf,lunout,'---> ',lab &$
             	endfor &$
		  	endelse
		endif else begin

;
; 	2nd mixer intermods
;
			if keyword_set(html) then begin
	            if ifrq eq 0 then  printf,lunout,tblS2
		    	for i=0,n-1 do begin &$
                	if i eq 0 then begin
                        l1=trs + tdse + "<td rowspan=" $
                            + string(format='(a,i0,a," style=font-weight:bold;>",f7.2,a)',$
                               q,n,q,retI[ifrq].rdrsky,tde) + nl + $
                              "<td rowspan=" $ 
						    + string(format='(a,i0,a," style=font-weight:bold;>",f6.2,a)',$
                               q,n,q,retI[ifrq].mix2[0].if1V,tde) + nl
                    endif else begin
                        l1=trs + tdse  + nl
                    endelse
                    l2=$
               sp + tdsa + string(format='(i0)',retI[ifrq].mix2[i].nlo) + tde    + nl + $
               sp + tdsa + string(format='(i0)',retI[ifrq].mix2[i].nrfi) + tde   + nl +  $
               sp + tdsa + string(format='(f5.1)',retI[ifrq].mix2[i].basebnd) + tde   + nl +  $
               sp + tdsa + string(format='(f6.1)',retI[ifrq].mix2[i].skyF[0]) + tde + nl + $
               sp + tdsa + string(format='(f6.1)',retI[ifrq].mix2[i].skyF[1]) + tde
                    printf,lunout,l1 + l2 + tre
                endfor
			endif else begin
	    		lab=string(format='(f6.1,1x,f6.1,1x,f6.1)',$
					retI[ifrq].lo2,retI[ifrq].mix2[0].if1V, retI[ifrq].rdrSky)
            	printf,lunout,lab 
            	for i=0,n-1 do begin &$
            		lab=string(format='(i2,1x,i2,1x,f5.1,1x,f6.1,1x,f6.1)',$
                	retI[ifrq].mix2[i].nlo,retI[ifrq].mix2[i].nrfi,retI[ifrq].mix2[i].basebnd,$
                    retI[ifrq].mix2[i].skyF)
                	printf,lunout,'---> ',lab 
             	endfor 
			endelse
		endelse
	endfor
	if keyword_set(html) then printf,lunout,tblE
	return
end
