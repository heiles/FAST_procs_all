;NAME:
;pdevlevelshtml - create html table entry for pdevlevels struct
;SYNTAX: pdevlevelshtml,pdevlevel,row ,title=title
;ARGS:
;pdevlevel:{}        structure returned from pdevlevels()
;KEYWORDS:
; RETURNS:
; istat : int     0 ok, -1 error (time domain spectra).
; row   : string  html code for 1 row of table
;title  : string  row with column labels in html row format
;DESCRIPTION:
;   Create an html table row entry for the values in the 
;pdevlevels structure. This structure is returned from the
;pdevlevels() function. The columns are:
; fftlen:  length of fft
; spcOutP: average value of spectra that is output
;1accumP : average values of spectra from single dump
;fftOutV : rms voltage of output of fft butterflys.
;BflyMax/Min: max, min values in the butterfly stages.
;            this depends on pshift.
;fftinpV:  rms input value to fft. It has already been 
;            placed in the upper bits of the 18 bit register.
;dlpfOutV:  output level of digital low pass filter.
;dlpfInV:   input value to digital low pass filter.
;a/dSigV:   compute sigma for A/D converter
;a/dSigCorV: corrected value for A/D sigma. The computed
;           values (a/dsigV) is low by sqrt(2.).
;ashift:    upshift in bits going from 40 bit accum to output.
;dshift:     downshift in bits 1accumP before accumulating in 40 bit 
;           accumulator
;pshift:    bitmask for which stages of the butterfly should downshift.
;
;EXAMPLE:
; istat=pdevopen(filename,desc) &$
; istat=pdevget(desc,b) &$
; istat=pdevlevels(desc.hsp,tp,pdevl,b=b)
; pdevlevelshtml,pdevl,row,title=title
;
;;  output the data to a file
;
;    htmlfile='pdevlevels.html'
;    openw,lunout,htmlfile,/get_lun
;    caption='pdev levels for different a/d sigma inputs'
;    printf,lunout,'<table BORDER WIDTH="100%" >'
;    printf,lunout,"<caption><b>"+CAPTION +"</b></caption>"
;    printf,lunout,tit
;    printf,lunout,row
;    printf,lunout,"</table >
;    free_lun,lunout
;-
pro  pdevlevelshtml,pdevlvl,row,title=title


    labAr= $
        ['fftlen','spcOutP','1accumP','fftOutV','BflyMax/Min','fftinpV','dlpfOutV','dlpfInV',$
         'a/dSigV','a/dsigCorV','ashift','dshift','pshift']
    if arg_present(title) then begin
        title="<tr>"
        for i=0,n_elements(labar)-1 do title+=("<td>" + labAr[i] + "</td>")
        title+="</tr>"
    endif
        
    row='<tr>'
    row+=string(format='(" <td>",i4,"</td>")',pdevlvl._fftlen) 
    row+=string(format='(" <td>",g8.3,"</td>")',pdevlvl.spcavg) 
    row+=string(format='(" <td>",g8.3,"</td>")',pdevlvl.acc1) 
    row+=string(format='(" <td>",f8.1,"</td>")',pdevlvl.fftout) 
    a=pdevlvl.fftinp
    row+=string(format='(" <td>",f8.1,"/",f8.1,"</td>")',a*pdevlvl._SCLPSHIFTMAX,$
                        a*pdevlvl._SCLPSHIFTMIN) 
    row+=string(format='(" <td>",f8.1,"</td>")',pdevlvl.fftinp) 
    row+=string(format='(" <td>",f8.1,"</td>")',pdevlvl.dlpfout) 
    row+=string(format='(" <td>",f8.1,"</td>")',pdevlvl._dlpfinp) 
    row+=string(format='(" <td>",f8.1,"</td>")',pdevlvl.atodsigma) 
    row+=string(format='(" <td>",f8.1,"</td>")',pdevlvl.atodsigmacor) 
    row+=string(format='(" <td>",i5,"</td>")',pdevlvl._ashift) 
    row+=string(format='(" <td>",i5,"</td>")',pdevlvl._dshift) 
    row+=string(format='(" <td>",a,"</td>")',pdevlvl._pshift) 
    row+="</tr>"
    return
end
