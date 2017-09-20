;+
;NAME:
;lrcmp - computes heights,angles  given laser ranging distances.
;SYNTAX: istat=lrcmp(pcdat,retdat,ext=ext)
;    ARGS:
; pcdat[]: {lrpcinp} data read in by lrpcinp().
; KEYWORDS:
;   ext  :  if set then return extended lr data structure: Included
;           space for az,zagr,zach (but they are not yet filled in).        
; RETURNS:
;retdat[]: {lrdat}   data with computed offsets.
;   istat:  int      number of entries computed
;
;DESCRIPTION:
;   The routine computes the platform positions from the distomat distances.
;It is called by lrpcinp after reading in the raw data from the laser ranging
;PC.
;
; The coordinates and matrices are:
;
; 
;   lr6 \                     / lr1
;         \                 /d1
;        d2  \     T12    /
;               \       /
;                  \./
;                  / \
;                 /   \                           |
;                /     \                          |
; \lr5       d3 /       \d9       / lr2           | y (+ north)
;   \          /         \       /                |
;  d4 \       /           \     /d8       ---------X
;       \    /             \   /          x (+ west)
;         \ /               \ / 
;       T8  -----------------  T4          Z (+toward the bowl)
;          /        d6       \
;         /                   \
;        /d5                   \d7
;       /                       \
;      /lr4                      \lr3
;
; The d's are the 9 distances (6 measured , 3 known) that will determine
;the 9 coordinates of the corners of the triangle
;
; delta_d=[d1,d2,d3,d4,d5,d6,d7,d8,d9]
; The matrix equation is:
;  A*dx = delta_d   where
;    dx = [dx1,dy1,dz1,dx2,dy2,dz3,dx3,dy3,dz3]
;   1=t12,2=t8,3=t4 is the motion of these corners.
; then
;  dx=delta_d * ainverse
; If you compare this with any c code remember that idl has the
; first index varying most rapidly and C has the second (mainly for the
; init of ainv below).
;
;The direction cosines look to be (cornerpoint - point)/dist
;The platform corners seem to go in the opposite directions then mmd,jayaram
; memo: T12,T8,T4 rather than T12,T4,T8.
;Lets hope the ref distances were also switched.
;the distomat ordering looks like lrn on the plot (i think).
;
;NOTES:
;   let [] be a vector.
;   [Cm]  is the position of one of the 3 corners.
;   [Crm] is the reference position for the [Cm]. 
;   [DRn] be one of the 6 distomat reference vectors. It points from
;       the laser ranger to the target when the 3 platform
;       corners are at [Crm]. 
;   [Dn] be the instantaneous position from laser ranger to target.
;   deltaDn :  magnitude of ([Dn]- [DRn])
;
;
; [dxm] be the displacement vector from corner m : [Cm]-[Crm]
;
; Any motion of [dxm] perpendicular to [Dn] will not change the distance
;
; The change in distance will be the projection of [dxm] onto
; the [Dn] direction.
;
; Since the relative motions are small compared to the length  of
; [DRn], use the unit vector of [DRn] rather than [Dn] when computing the
; dot product.
;
; The unit vector for a [DRn] is just  [DRn]/magnitude(DRn)
; [Drn] points from the distomat to the target.
;
; As an example,
;   DR1  is at -x,+y1,+z
;   CRm  is at  0,+y1a,0   where y1a<y1
;  This makes the direction cosines:     
;   
;   +x,-y,-z .. This should be the first 3 elements of a[]
; 
;-
function lrcmp,pc,b,ext=ext
;
; inverse array used for distomats
;
ainv= [$
[ 1.1029,-1.1029, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000],$
[ 0.0000, 0.0000, 0.5774,-0.6368, 0.6368,-0.5774, 0.6368,-0.6368, 0.5774],$
[-0.7165,-0.7165,-0.4587, 0.5059,-0.5059, 0.4587,-0.5059, 0.5059,-0.4587],$
[ 0.5514,-0.5514, 0.5000,-0.5514, 0.5514, 0.5000,-0.5514, 0.5514,-0.5000],$
[-0.3184, 0.3184,-0.2887,-0.9551, 0.9551,-0.2887, 0.3184,-0.3184, 0.2887],$
[-0.5059, 0.5059,-0.4587,-0.7165,-0.7165,-0.4587, 0.5059,-0.5059, 0.4587],$
[ 0.5514,-0.5514, 0.5000,-0.5514, 0.5514,-0.5000,-0.5514, 0.5514,-0.5000],$
[ 0.3184,-0.3184, 0.2887,-0.3184, 0.3184,-0.2887, 0.9551,-0.9551,-0.2887],$
[ 0.5059,-0.5059, 0.4587,-0.5059, 0.5059,-0.4587,-0.7165,-0.7165,-0.4587]$
]
;a after inversion:
; .45335 -0.55438  -0.69784 0.00000  0.00000  0.00000  0.00000  0.00000  0.0000
;-.45335 -0.55438 -0.69784  0.00000  0.00000  0.00000  0.00000  0.00000  0.0000
;-.49997  0.86595  0.00000  0.49997 -0.86600  0.00000  0.00000  0.00000  0.0000
; .0000   0.00000  0.00000 -0.70684 -0.11543 -0.69784  0.00000  0.00000  0.0000
; .0000   0.00000  0.00000 -0.25344  0.66982 -0.69784  0.00000  0.00000  0.0000
; .0000   0.00000  0.00000  1.00000  0.00000  0.00000 -1.00000  0.00000  0.0000
; .0000   0.00000  0.00000  0.00000  0.00000  0.00000  0.25344  0.66982 -0.69784
; .0000   0.00000  0.00000  0.00000  0.00000  0.00000  0.70684 -0.11543 -0.69784
; .49997  0.86595  0.00000  0.00000  0.00000  0.00000 -0.49997 -0.86600  0.0000
;
; direction cosines are:
;  d^2=(x-x1)^2 + (y-y1)^2 + (z-z1)^2
;  cosa = (x-xi)/d   where i is one of the 9 points and the x is one of the
;  cosb = (y-yi)/d   3 platform corners.
;  cosg = (z-zi)/d
;
; the above a matrix is then :
;
; cosa1   cosb1    cosg1    0.00000  0.00000  0.00000  0.00000  0.00000  0.0000
; cosa2   cosb2    cosg2    0.00000  0.00000  0.00000  0.00000  0.00000  0.0000
; cosa3   cosb3    cosg3   -cosa3   -cosb3    0.00000  0.00000  0.00000  0.0000
; .0000   0.00000  0.00000  cosa4    cosb4   -0.69784  0.00000  0.00000  0.0000
; .0000   0.00000  0.00000  cosa5    cosb5   -0.69784  0.00000  0.00000  0.0000
; .0000   0.00000  0.00000  cosa6    cosb6    0.00000 -1.00000  0.00000  0.0000
; .0000   0.00000  0.00000  0.00000  0.00000  0.00000  0.25344  0.66982 -0.69784
; .0000   0.00000  0.00000  0.00000  0.00000  0.00000  0.70684 -0.11543 -0.69784
; .49997  0.86595  0.00000  0.00000  0.00000  0.00000 -0.49997 -0.86600  0.0000
; 
;
;   distomat reference used 27jan97 during theodolite measurements then
;   correct z dimension for theodolite-distomat values.
;
    refD=[163.824D,163.807,163.849,163.768,163.755,163.794];distomat order
    delta_d=dblarr(9)       ; distance measured - reference
    cmToFt= 1./(2.54*12.)
    hghtCorFt=[.1202,-2.2851,1.8168,.4356]/12.;avg,T12,T4,T8..zup convert in->ft
    hghtRef  =1253.029      ; feet above sea level... still need avg hgt cor.
;
;   platform corners T12,T8,T4  in cm (3,3) first dim xyx of T12,T8,then T
;           x      y       z
    plt=[[ 0.0   , 3800.86,0.],$   ;T12
         [ 3292.0,-1900.43,0.],$   ;T8
         [-3292.0,-1900.43,0.]]    ;T4

    npnts=n_elements(pc)
    if (keyword_set(ext)) then begin
        b=replicate({lrdatext},npnts)
    endif else begin
        b=replicate({lrdat},npnts)
    endelse
    b.date  =pc.daynum+ (pc.hour + (pc.min +  pc.sec/60.D)/60.D)/24.D
    b.tempB =pc.tempB
    b.tempPl=pc.tempPl
    b.dist  =pc.m[0:5].dist
    b.distTm=pc.m[0:5].secs 
    b.secPerPnt=pc.secPerPnt
    b.dok=1
;
;   setup indices to map the non-edge part of delta d to the distomat 
;   measurements.
;
    ind_dd =[0,1,3,4,6,7]       ;the  d's above skipping the platform edges
    ind_ref=[0,5,4,3,2,1]       ;map distomat order into distance order
    indx=[0,3,6]                ; in delta_x array
    indy=indx+1
    indz=indy+1
    for i=0,npnts-1 do begin
        delta_d[ind_dd]=((b[i].dist[ind_ref] - refD[ind_ref]))*100.;to cm.
        ind=where((delta_d lt -200.) or (delta_d gt 200.),count) ; catch distomats with no value
        if count gt 0 then begin
            b[i].dok=0;
        endif else begin
;
;       delta_xi means the x,y,z coord not just x
;       delta_xi[x,y,z:t12,t8,t4]
        delta_xi=reform(ainv ## delta_d,3,3); matrix multiply to get delta x's
        b[i].pnts[*,0]=delta_xi[*,0]; T12
        b[i].pnts[*,1]=delta_xi[*,2]; T4
        b[i].pnts[*,2]=delta_xi[*,1]; T8
;
;   get average translation of entire platform
;   x-west,y-north,z-down cm
        b[i].dx= total(delta_xi[0,*])/3.
        b[i].dy= total(delta_xi[1,*])/3.
        b[i].dz= total(delta_xi[2,*])/3.
;        
;     y2p-----------------
;        \                |
;          \              |
;            \            |
;              \          |
; ----y2---------x--------y3
;                  \      |
;                    \    |
;                      \th|
;                        \|
;                        y3p
; distance between points before after the same (rotation).
; d=x2-x3 (before rotation)
; (y2p-y3p)/d = acos(th)
; works for rotation about z,y since two points are same distance..
; for rotation about x T12,T4,T8 difference distance fro rotation axis
; instead of the above just use the small angle approx..
;   r*dtheta=distance moved
;
;   for 3' distance differs b .1 asec over 216 feet.
;  xrot use difference z of T12 and avg of t4,T8, distance 
;  is yT12 - y(avgT4,t8)
;                     z12 - avg(z4,z8)/(t12 to farside length)
        b[i].xrot=(delta_xi[2,0]-total(delta_xi[2,1:2])/2.)/$
                (plt[1,0]-plt[1,1])
;
;                     p2z     -      p3z    /      p3x  -p2x
        b[i].yrot=(delta_xi[2,1]-delta_xi[2,2])/(plt[0,2]-plt[0,1]) ; radians

;                     p2y     -        p3y     /    (p2x -   p3x)
        b[i].zrot=(delta_xi[1,1]-delta_xi[1,2])/(plt[0,1]-plt[0,2]) ; radians
;
;   corrections for zheight to be up and feet above sea level.
;   avg height      dz                
        b[i].avgh      =(-B[I].dz*cmToFt)+hghtCorFt[0] +  hghtRef
        b[i].cornerH   =(-(b[i].pnts[2,*]-b[i].dz)*cmToFt)+ $
                           hghtCorFt[1:3] + b[i].avgh
        endelse
    endfor
;
    return,npnts
end
