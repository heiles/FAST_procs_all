; 
pro galplottp,filename,b=b,nops=nops,prompt=prompt,inc=inc,nover=nover,$
                tp=tp,tpn=tpn

    hardcopy=not keyword_set(nops)

    ii=strpos(filename,'/',/reverse_search)
    bname=strmid(filename,ii+1)
    ii=strpos(bname,'.fits')
    psname=strmid(bname,0,ii)+'.tp.ps'
    print,galopen(filename,desc)
;    print,'fnum,recs,rows:',bname,desc.totrecs,desc.totrows
    recreq=desc.totrecs
    rew,desc
    print,corgetm(desc,recreq,b)
    nrecs=n_elements(b)
    tp=fltarr(nrecs,7,2)
    tpn=fltarr(nrecs,7,2)
    nchn=desc.nbchan
    medpwr=fltarr(2,7)
    for ipix=0,6 do begin &$
        for ipol=0,1 do begin
            tp[*,ipix,ipol]=total(b.(ipix).d[*,ipol],1)/nchn &$
            medpwr[ipol,ipix]=median(tp[*,ipix,ipol]) &$
            tpn[*,ipix,ipol]=tp[*,ipix,ipol]/medpwr[ipol,ipix] &$
        endfor
    endfor
    x=b.b1.hf[0].sec1970 - b[0].b1.hf[0].sec1970
    x=round(x)
    if keyword_set(prompt) then begin
        key=checkkey()
        print,'Read for new plot, c to continue'
        done=0
        while ( not done) do begin
            key=checkkey(/wait)
            done=key eq 'c'
            if key eq 's' then stop
            if not done then wait,1
        endwhile
        print,'continuing'
    endif
    if hardcopy then pscol,psname,/full
    !p.multi=[0,1,2]
    if not keyword_set(nover) then ver,.9,1.3
    if n_elements(inc) eq 0 then inc=.03
    title=string(format='("galfa TotPwr. file:",a)',bname)
    stripsxy,x,tpn[*,*,0],0,inc,/step,$
        xtitle='time [secs]',ytitle='total Pwr [Tsys]',$
        title=title+' PolA'

    stripsxy,x,tpn[*,*,1],0,inc,/step,$
        xtitle='time [secs]',ytitle='total Pwr [Tsys]',$
        title=title+' PolB'
    ln=2
    scl=.6
    xp=.1
    xpinc=.1
    for i=0,6 do $
        note,ln,string(format='("pix:",i1)',i),xp=xp+xpinc*i,col=i+1 
    tmlab=fisecmidhms3(b[0].b1.h.std.time)
    note,ln+scl,'ScanStart: '+tmlab+" AST",xp=xp
;
    xp=-.2 
    ln=10.5

    note,ln-scl,'medianPwr',xp=xp
    for i=0,6 do $
        note,ln+i*scl,string(format='(f8.0)',medpwr[0,i]),xp=xp,col=i+1 

    ln=16.
    note,ln-scl,'medianPwr',xp=xp
    for i=0,6 do $
        note,ln+i*scl,string(format='(f8.0)',medpwr[1,i]),xp=xp,col=i+1 
    !p.multi=0

    if hardcopy then begin
        hardcopy
        x
    endif
    galclose,desc
    return
end
