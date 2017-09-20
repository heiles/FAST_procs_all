;+
;NAME:
;xvisualquery - query x visual information
;SYNTAX: vis=xvisualquery()
;ARGS:
;   none
;RETURNS:
;   vis: {}     structure containing x visual info found
;
;   vis.retain          0/1   ; 1--> server provides backing store
;
;   vis.pseudoCol.numvis      ; number of pseudo color visuals found
;   vis.pseudoCol.numplanes[f]; number of planes in each of these
;   vis.directCol.numvis      ; number of direct color visuals found   
;   vis.directCol.numplanes[f]; number of planes in each of these
;   vis.trueCol.numvis        ; number of true color visuals found
;   vis.trueCol.numplanes[f]  ; number of planes in each of these
;
;DESCRIPTION:
;   In idl you would like to know what kind of x visuals are available on
;the x display before requesting one. The routines to query the visuals
;have the unfortunate drawback that if no visual is selected, they will
;select one. 
;
;   This routine executes xdpyinfo and then parses the output. It keeps
;track of how many pseudocolor, directcolor, and truecolor visuals were 
;found. For this routine, the visuals are differentiated only by the
;class (pseudo, true, direct) and the number of planes (it does not
;differentiate between visuals with the same class and number of planes.
;
;   The routine also returns whether the xserver can supply backing
;store (vis.retain eq 1) or not (vis.retain eq 0). You could then
;use this value to determine if idl should provide backing store or not.    
;-
;
function xvisualquery
;
;
maxvis=5
a={   numvis:  0L ,$
      planes: intarr(maxvis)}

config={$
        retain: 0,$   ; 1--> server can retain, 0==> server cant' retain
        pseudoCol: a,$
        directCol: a,$
          trueCol: a}
        

cmd='xdpyinfo'
spawn,cmd,list

;
;grab the visuals
;
vis=stregex(list,"(class: +([a-zA-Z]+))|(depth: *([0-9]+))",/extract,/sub)
retain=stregex(list,"options:.*backing-store ([a-zA-Z]*)",/extract,/sub)
ind=where(retain[1,*] ne '',cnt)
if cnt gt 0 then begin
    ch=strmid(retain[1,ind[0]],0,1)
    config.retain= (( ch eq 'y') or (ch eq 'Y')) ?1:0
endif
ind=where(strmid(vis[0,*],0,6) eq 'class:',cnt)
;
;  code same order as order in structure
;
; 0-pseudo 
; 1-direct
; 2-true
;
codepseudo =1
codedir    =2
codetrue   =3
codeunknown=-1
j=0
for i=0,cnt-1 do begin
    a=strmid(vis[2,ind[i]],1,3)
    case  a  of
        'rue': code=codetrue
        'ire': code=codedir
        'seu': code=codepseudo
         else: code=codeunknown
    endcase
    if code ne codeunknown then begin
         planes=long(vis[4,ind[i]+1])
         ii=where(config.(code).planes eq planes,cnt1)
         if ((cnt1 eq 0) and  (config.(code).numvis lt maxvis)) then begin
            config.(code).planes[config.(code).numvis]=planes
            config.(code).numvis = config.(code).numvis  + 1
         endif
    endif
endfor
return,config
end
