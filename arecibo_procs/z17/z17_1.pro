pro z17_1, npatt, blchnls, hdrsrcname, hdrscan, hdr1info, hdr2info, $
            stkon, stk16offs, z17_1, ncov=ncov, trxoffs=trxoffs, cont=cont
  
;+       
;PURPOSE:Derive expected profiles and optical depths from z17 absorption
;data, going to first derivatives in ra and dec. The equations of
;condition for each channel are:
;  (Tobs - Trcvr) = Tcont exp^{-tau} + Texp +
;          delra * dTexp/dra + deldec * dTexp/ddec +
;where;
;  Tobs is the measured temps at the 17 positions
;  Trcvr is the approx cold-sky rcvr temp, a fcn of ZA; the main point of
;     including this is to eliminate the ZA dependence of Trcvr.
;  Tcont is the off-line continuum temp, derived from baseline (blchnls)
;  exp^{-tau} is the HI absorption
;  Texp is the 'expected profile' at the source position
;  dTexp/dra is the spatial derivative of Texp in ra (not corrected for
;     cos (dec); units Kelvins/arcmin
;  dTexp/ddec is the spatial derivative of Texp in dec; units:
;  Kelvins/arcmin
;
;CALLING SEQUENCE:
;  z17_1, npatt, blchnls, hdrsrcname, hdrscan, hdr1info, hdr2info, $
;            stkon, stk16offs, z17_1, ncov=ncov, trxoffs=trxoffs
;
;INPUTS
;       NPATT, the pattern nr to treat--do one at a time
;       BLCHNLS, the array of chnls to regard as baselline (the off-line
;               channels).
;       STKON[ nchnls, nstk, nrpatt]. the on source stokes params.
;       STK16OFFS[ nchnls, nstk, 16, nrpatt]. the 16 off source stokes
;               params.   
;       HDRSRCNAME[ nrpatt], the array of source names
;       HDRSCAN[ nrpatt], the array of scan nrs
;       HDR1INFO[ 48, nrpatt], the header values.
;       HDR2INFO[ 22, 32, nrpatt], the multiple-position header values.
;
;KEYWORDS:
;       TRXOFFS, the rcvr(sys) temps for the 16 off positions.
;       NCOV, the covariance matrix of the ls fit
;       CONT,  the continuum ant temp deflction
;
;OUTPUTS:
;z17_2= {srcname: source name 
;        scan: scan nr
;        vlsr: array of 2048 vlsr
;        emt: array of 2048 exp_minus_tau 
;        sigemt_obs: array of 2048 'empirical' errors in emt
;        Texp: a[ *,1], array of 2048 Texp
;        sigTexp_obs:  array of 2048 'empirical' errors in Texp
;        dTexp_dra:  array of 2048 first derivs of Texp wrt ra
;        dTexp_ddec:  array of 2048 first derivs of Texp wrt dec
;        sigemt: array of 2048 std uncertainties in emt
;        sigTexp: array of 2048 std uncertainties in Texp
;        sigdTexp_dra: array of 2048 std uncertainties 
;        sigdTexp_ddec:array of 2048 std uncertainties 
;        emt_simple: the naively derived emt (all spatial derivs = 0)
;        texp_simple:the naively derived Texp (all spatial derivs = 0)
;        hdr1: hdr1info[ *, npatt], $
;        hdr2: hdr2info[ *, *, npatt], $
;        blchnls:blchnls}
;
;-       

forward_function trcvr

;deal with channels and their defititions...
sz= size( stkon)
nchnls= sz[ 1]
nblchnls= n_elements( blchnls)

;DEFINE THE INDICES IN hdr2info THAT WERE USED FOR THE DATA AND
;OBTAIN THE POSITION ARRAY (delra, deldec) WE NEED.
;the array of 17 positions is the on source one followed by the 16 off
;source ones.
indxon= [2,21]
indxoff=5 + indgen(16)
raoff= hdr2info[ indxoff, 3, npatt]
decoff= hdr2info[ indxoff, 4, npatt]
raoffavg= mean(raoff)
decoffavg= mean(decoff)
raon= hdr2info[ indxon, 3, npatt]
decon= hdr2info[ indxon, 4, npatt]
raonavg= mean( raon)
deconavg= mean( decon)
delraon= raon- raonavg
deldecon= decon- deconavg
delraoff= raoff- raoffavg
deldecoff= decoff- decoffavg
delra= [delraon[0], delraoff]
deldec= [deldecon[0], deldecoff]
;CONVERT DEL ANGLES TO ARCMIN...
delra= delra* 15.* 60.
deldec= deldec* 60.
;OBTAIN THE CORRESPONDING ARRAY OF ZA'S and cold-sky rcvr temps
zaon= hdr2info[ indxon, 7, npatt]
trcvr, zaon, trxon
zaoffs= hdr2info[ indxoff, 7, npatt]
trcvr, zaoffs, trxoffs

;EXTRACT STKI for specified channels...
stkion= reform( stkon[ *, 0, npatt])
stkioffs= reform( stk16offs[ *, 0, *, npatt])
;subtract off the rcvr contribution (a fcn of za) for the obs...
stkion= stkion- mean( trxon)
for np=0, 15 do stkioffs[*,np]= stkioffs[*,np]- trxoffs[ np]

;calculate continuum from the off channels. this is the continuum           
;temp from the source that is absorbed..
blon= total( stkion[blchnls])/nblchnls
bloffs= total( stkioffs[ blchnls, *], 1)/nblchnls
bl= [blon,bloffs]

;EXTRACT the 'naive' exp{-tau} and Texp by simple averaging and 
;differences.
;CONTINUUM SOURCE DEFLN (avg of baseline chnls;
;       used only for the guess of emt_simple)
blstkion= reform( stkon[ blchnls, 0, npatt])
blstkioffs= reform( stk16offs[ blchnls, 0, *, npatt])
cont= mean( blstkion) - mean( blstkioffs)

;OBTAIN THE GUESSES FOR EMT_SIMPLE and TEXP_SIMPLE...
emt_simple = (stkion- total(stkioffs, 2)/ 16)/ cont
texp_simple= total( stkioffs,2)/16

nrparams= 4   ;this is the nr of parameeters solved for
nrdata= 17   ;this is the nr of measuements

;make output arrays for 2048 spectral channels...
a= fltarr( 2048, nrparams)
siga= fltarr( 2048, nrparams)
sigTexp_obs= fltarr( 2048)
resids_obs= fltarr( 16)

;stop

;MAKE X MATRIX...
xmat= fltarr( nrparams, nrdata)
;       COL 0 is the continuum source deflection temps from the blchnls
;       COL 1-6 are taylor series coefficients 
;         (1, delra, deldecm, delra^2, deldec^2, delra*deldec
;               for the first freq chnl
;       ROW 0-16 are the 17 measurements for chnl 0
for np=0, 16 do xmat[ 1:3,np]= [1., delra[np], deldec[np]]
   xmat[ 0, *] = bl

;MAKE DATA VECTOR...
yy= fltarr( 17)
for nc=0, nchnls-1 do begin
   yy[ 0]= stkion[nc]
   yy[ 1:16]= stkioffs[ nc,*]
   xmatt= transpose( xmat)
   alpha= xmatt ## xmat
   beta= xmatt ## yy
   cov= invert( alpha, status)
   aa= reform( cov ## beta)
   yyfit_aa= xmat ## aa
   resids= yy - yyfit_aa
   var= total( resids^2)/( nrdata- nrparams) 
   sig= sqrt( var)
   var_aa= var* diag_matrix( cov)
   sig_aa= sqrt( var_aa)
   a[ nc, *]= aa
   siga[ nc, *]= sig_aa

;doug = cov[indgen(nrparams)* (nrparams+1)]
;doug = doug#doug
;ncov = cov/sqrt(doug)

resids_obs= resids[ 1:16 ]
sigTexp_obs[ nc]= sqrt(total( resids_obs^2)/16)
endfor

getvlsr, hdr1info, vlsr, npatt=npatt

z17_1= {srcname:hdrsrcname[ npatt], $
        scan: hdrscan[ npatt], $
        vlsr: vlsr, $
        tcont: cont, $
        emt: a[ *, 0], $
        sigemt_obs: sigTexp_obs/cont, $
        Texp: a[ *,1], $
        sigTexp_obs: sigTexp_obs, $
        dTexp_dra: a[ *,2], $
        dTexp_ddec: a[ *,3], $
        sigemt: siga[ *,0], $
        sigTexp: siga[ *,1], $
        sigdTexp_dra: siga[ *,2], $
        sigdTexp_ddec: siga[ *,3], $
        emt_simple:emt_simple, $
        texp_simple:texp_simple, $
        hdr1: hdr1info[ *, npatt], $
        hdr2: hdr2info[ *, *, npatt], $
        blchnls:blchnls}

;stop
return
end
