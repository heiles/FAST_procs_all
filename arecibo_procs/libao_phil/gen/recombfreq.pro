;+
;NAME:
;recombfreq - compute recombination line freq for atoms
;SYNTAX: freq=recombfreq(atom,linenum,linestep,alpha=alpha,beta=beta,gamma=gamma,
;                       delta=delta,eps=eps,pertbl=pertbl)
;ARGS:
;   atom     : string  H,he,C,N,O atom to compute. (case insensitive).
;  linenum[n]: long   transition number (lower level)
; linestep[n]: long   1=alpha,2=beta...etc
;                     if linenum is an array and linestep is a single value
;                     then use this value for all of linenum. If any keyword
;                     alpha,beta.. is entered, then ignor linestep.
;KEYWORDS:
;   alpha   :  if set then return alpha series (deltan=1) (ignore linestep)
;   beta    :  if set then return beta  series (deltan=2) (ignore linestep)
;   gamma   :  if set then return gamma series (deltan=3) (ignore linestep)
;   delta   :  if set then return delta series (deltan=4) (ignore linestep)
;   eps     :  if set then return eps   series (deltan=5) (ignore linestep)
;   pertbl[]:{pertbl} return period table (name,isotope%, amu for all 
;                     elements we support)
;RETURNS:
;  freq[n]  : double in Mhz.
;
;DESCRIPTION:
;   compute the recombination line frequencies for an atom. Supported
;atoms are: H,He4,C12,N14,O16. You can supply 1 or more linenumbers to do
;at once as well as the step (1,2,3). Using any of the series keywords:
; alpha,beta,gamma,... will override the linestep parameter.
;
;   Taken from "Tools of Radio Astronomy", Rohlfs&Wilson,2000. pg 334.
; looks like value are good to about 1 khz for H89a at 9Ghz.
;-
function recombfreq,atom,linenum,linestep,$
        alpha=alpha,beta=beta,gamma=gamma,delta=delta,eps=eps,pertbl=pertbl
;
; constants
;
    Rinf=3.289841960368D9           ;Rydberg consta inf.. nist 1998
    melec=.0005485799110D           ; nist 1998 in amu
    Z=1.D                           ; assume 1 for large n
;
; table of elements
;  name, percent isotope, amu. C12
;
a={pt , nm : ' ' ,$; name 
          fract: 0.,$; iosotopic percent composition
          amu : 0.d}  ; relative amu neg number--> move up to get
          
    maxelm=65L
    pertbl=replicate({pt},maxelm)
    pertbl[0]={pt,nm:'H'  ,fract:99.9885   ,amu:1.0078250321D}
    pertbl[1]={pt,nm:'D'  ,fract:0.0115    ,amu:2.014101778D}
    pertbl[2]={pt,nm:'T'  ,fract:0.        ,amu: 3.0160492675D}
    pertbl[3]={pt,nm:'He3',fract:0.000137  ,amu: 3.0160293097D}
    pertbl[4]={pt,nm:'He4',fract:99.999863 ,amu: 4.0026032497D}
    pertbl[5]={pt,nm:'He' ,fract:-1.       ,amu:-1.D}
    pertbl[6]={pt,nm:'Li6',fract:7.59      ,amu: 6.0151223D}
    pertbl[7]={pt,nm:'Li7',fract:92.41     ,amu: 7.0160040}
    pertbl[8]={pt,nm:'Li' ,fract:-1.       ,amu:-1.D}
    pertbl[9]={pt,nm:'Be9',fract:100.      ,amu: 9.0121821D}
    pertbl[10]={pt,nm:'Be' ,fract:-1.       ,amu:-1.}
    pertbl[11]={pt,nm:'B10',fract:19.9      ,amu:10.0129370D}
    pertbl[12]={pt,nm:'B11',fract:80.1      ,amu:11.0093055D}
    pertbl[13]={pt,nm:'B'  ,fract:-1.       ,amu:-1.D}
    pertbl[14]={pt,nm:'C12',fract:98.93     ,amu:12.0D}
    pertbl[15]={pt,nm:'C'  ,fract:-1.       ,amu:-1.}
    pertbl[16]={pt,nm:'C13',fract:1.07      ,amu:13.0033548378D}
    pertbl[17]={pt,nm:'C14',fract:0.        ,amu:14.003241988D}
    pertbl[18]={pt,nm:'N14',fract:99.632    ,amu:14.0030740052D}
    pertbl[19]={pt,nm:'N'  ,fract:-1.       ,amu:-1.D}
    pertbl[20]={pt,nm:'N15',fract:0.368     ,amu:15.0001088984D}
    pertbl[21]={pt,nm:'O16',fract:99.757    ,amu:15.9949146221D}
    pertbl[22]={pt,nm:'O'  ,fract:-1.       ,amu:-1.D}
    pertbl[23]={pt,nm:'O17',fract:.038      ,amu:16.99913150D}
    pertbl[24]={pt,nm:'O18',fract:.205      ,amu:17.9991604D}
    pertbl[25]={pt,nm:'F19',fract:100.     ,amu:100.}   
    pertbl[26]={pt,nm:'F'  ,fract:-1.      ,amu:-1.}    
    pertbl[27]={pt,nm:'Ne20',fract:90.48       ,amu:19.9924401759}
    pertbl[28]={pt,nm:'Ne'  ,fract:-1.         ,amu:-1.}
    pertbl[29]={pt,nm:'Na23'  ,fract:100.     ,amu:22.989767}
    pertbl[30]={pt,nm:'Na'  ,fract:-1.      ,amu:-1.}
    pertbl[31]={pt,nm:'Mg24'  ,fract:78.99  ,amu:23.98504190D}
    pertbl[32]={pt,nm:'Mg'  ,fract:-1.      ,amu:-1.}
    pertbl[33]={pt,nm:'Mg25'  ,fract:10.0   ,amu:24.98583702D}
    pertbl[34]={pt,nm:'Mg26'  ,fract:11.01   ,amu:25.98259304D}
    pertbl[35]={pt,nm:'Al27'  ,fract:100.   ,amu:26.9815384D}
    pertbl[36]={pt,nm:'Si28'  ,fract:92.2297 ,amu:27.9769265327D}
    pertbl[37]={pt,nm:'Si'    ,fract:-1.     ,amu:-1.}
    pertbl[38]={pt,nm:'Si29'  ,fract:4.6832  ,amu:28.97649472D}
    pertbl[39]={pt,nm:'Si30'  ,fract:3.0872  ,amu:29.97377022D}
    pertbl[40]={pt,nm:'P31'   ,fract:100.    ,amu:30.97376151}
    pertbl[41]={pt,nm:'P'     ,fract:-1.     ,amu:-1.}
    pertbl[42]={pt,nm:'S32'   ,fract:94.93   ,amu:31.97207069D}
    pertbl[43]={pt,nm:'S'     ,fract:-1.     ,amu:-1.}
    pertbl[44]={pt,nm:'S33'   ,fract:0.76    ,amu:32.97145850D}
    pertbl[45]={pt,nm:'S34'   ,fract:4.29    ,amu:33.96786683D}
    pertbl[46]={pt,nm:'S36'   ,fract:.02        ,amu:35.96708088D}
    pertbl[47]={pt,nm:'Cl35'  ,fract: 75.78  ,amu:34.96885271D}
    pertbl[48]={pt,nm:'Cl'    ,fract:-1.     ,amu:-1.}
    pertbl[49]={pt,nm:'Cl37'  ,fract:24.22   ,amu:36.96590260D}
    pertbl[50]={pt,nm:'Ar36'  ,fract:0.3365 ,amu:35.96754628D}
    pertbl[51]={pt,nm:'Ar38'  ,fract:0.0632  ,amu:37.9627322D}
    pertbl[52]={pt,nm:'Ar40'  ,fract:99.6003 ,amu:39.962383123D}
    pertbl[53]={pt,nm:'Ar'    ,fract:-1.        ,amu:-1.}
    pertbl[54]={pt,nm:'K39'   ,fract: 93.2581,amu:38.9637069D}
    pertbl[55]={pt,nm:'K'     ,fract:-1.        ,amu:-1.}
    pertbl[56]={pt,nm:'K40'   ,fract:0.0117 ,amu:39.96399867D}
    pertbl[57]={pt,nm:'K41'   ,fract: 6.7302 ,amu:40.96182597D}
    pertbl[58]={pt,nm:'Ca40'  ,fract: 96.941 ,amu:39.9625912D}
    pertbl[59]={pt,nm:'Ca'    ,fract: -1.   ,amu:-1.}
    pertbl[60]={pt,nm:'Ca42'  ,fract:0.647  ,amu:41.9586183D}
    pertbl[61]={pt,nm:'Ca43'  ,fract:0.135  ,amu:42.958766D}
    pertbl[62]={pt,nm:'Ca44'  ,fract:  2.086 ,amu:43.9554811D}
    pertbl[63]={pt,nm:'Ca46'  ,fract: 0.004  ,amu:45.9536928D}
    pertbl[64]={pt,nm:'Ca48'  ,fract: 0.187  ,amu:47.952534D}

    val=strcmp(atom,pertbl.nm,/fold_case)
    ind=where(val eq 1,count)
    if count eq 0 then message,'can not find atom:'+atom
    atoml=pertbl[ind]
    if atoml.fract lt 0. then atoml=pertbl[ind-1]
;;  case 1 of
;;      atoml eq 'h': begin
;;          amu=1.007825D
;;          R=3.28805129D9
;;          end
;;      atoml eq 'he': begin
;;          amu=4.002603D
;;          R=3.28939118D9
;;          end
;;      atoml eq 'c': begin
;;          amu=12.0d
;;          R=3.28969163D9
;;          end
;;      atoml eq 'n': begin
;;          amu=12.003074d
;;          R=3.28971314D9
;;          end
;;      atoml eq 'o': begin
;;          amu=15.994915
;;          R=3.28972919D9
;;          end
;;      else: begin
;;          message,'supported atoms: H,He,C,N,O'
;;          end
;;  endcase

    n=n_elements(linenum)
    linestepL=lonarr(n)
    case 1 of 
        n_elements(linestep) eq 0: linestepL=linestepL + 1
        n_elements(linestep) eq 1: linestepL=linestepL + linestep
        n_elements(linestep) eq n: linestepL=linestep
        else : message,'number elements line step must match linenum'
    endcase

    case 1 of
        keyword_set(alpha): linestepl=linestepl*0 + 1
        keyword_set(beta ): linestepl=linestepl*0 + 2
        keyword_set(gamma): linestepl=linestepl*0 + 3
        keyword_set(delta): linestepl=linestepl*0 + 4
        keyword_set(eps):   linestepl=linestepl*0 + 5
        else            :   linestepl=linestepl
    endcase
;
    Rm=Rinf/(1.D + melec/atoml.amu)
    freq=Z*Z*Rm*(1.D/(linenum*linenum) - 1.D/(linenum+linestepl)^2)
    return,freq
end
