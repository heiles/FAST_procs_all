;+
;NAME:
;mmcmpmatrix - compute the mueller matrix from the parameters
;
;SYNTAX:
;     mm=mmcmpmatrix(mmparams)
;
;ARGS:
;     mmparams:{mmparams} mm params structure with the parameter
;                          data already loaded: alpha,deltag,epsilon,
;                          phi,psi,chi
;RETURNS:
;      mm[4,4]: float. The computed mueller matrix without the astronomical
;                      correction included.
;DESCRIPTION: 
;  Compute the mueller matrix from the parameters that define it. The
;parameter values should have already been loaded into the mmparams 
;structure before calling this routine (see mmgetparams). The 4 by 4 matrix
;is returned in the function call. It is not loaded into the mmmparams.mm
;element in the structure.
;                      correction to get to sky coordinates.
;SEE ALSO: 
;   AO technical memo 2000-05 (The Mueller matrix parameters for Arecibo'S
;   receiver systems. http://www.naic.edu/aomenu.htm
;- 
;history:
;17oct02 .. started
function mmcmpmatrix,mmp
;
    on_error,1
;
;   feed imperfections matrix (epsilon,phi
;
    milfr = fltarr(4,4)
    milfr[0,0]=1.
    milfr[2,0] = 2.*mmp.epsilon*cos(mmp.phi)
    milfr[3,0] = 2.*mmp.epsilon*sin(mmp.phi)
    milfr[1,1] = 1.
    milfr[0,2] = 2.*mmp.epsilon* cos(mmp.phi)
    milfr[2,2] = 1.
    milfr[0,3] = 2.*mmp.epsilon* sin(mmp.phi)
    milfr[3,3] = 1.
;
;   feed portion of matrix (alpha,chi). 
;
    mf = fltarr(4,4)
    mf[0,0]=1.
    mf[1,1] =     cos(mmp.alpha)^2 - sin(mmp.alpha)^2
    mf[2,1] =  2.*cos(mmp.alpha)*sin(mmp.alpha)*cos(mmp.chi)
    mf[3,1] =  2.*cos(mmp.alpha)*sin(mmp.alpha)*sin(mmp.chi)
    mf[1,2] = -2.*cos(mmp.alpha)*sin(mmp.alpha)*cos(mmp.chi)
    mf[2,2] =     cos(mmp.alpha)^2 - sin(mmp.alpha)^2 * cos(2.*mmp.chi)
    mf[3,2] =    -sin(mmp.alpha)^2 * sin(2.*mmp.chi)
    mf[1,3] = -2.*cos(mmp.alpha)*sin(mmp.alpha)*sin(mmp.chi)
    mf[2,3] =    -sin(mmp.alpha)^2 * sin(2.*mmp.chi)
    mf[3,3] =     cos(mmp.alpha)^2 + sin(mmp.alpha)^2 * cos(2.*mmp.chi)
;
;   amplifier portion of matrix
;
    ma=fltarr(4,4)
    ma[0,0] =1.
    ma[1,0] = 0.5*mmp.deltag
    ma[0,1] = 0.5*mmp.deltag
    ma[1,1] = 1.
    ma[2,2] = cos(mmp.psi)
    ma[3,2] = -sin(mmp.psi)
    ma[2,3] = sin(mmp.psi)
    ma[3,3] =  cos(mmp.psi)
    return,ma ## milfr ## mf
end
