pro plot_beam1d, nrc, mmInfo_arr, beamin_arr

;+
;NAME:
;plot_beam1d
;PLOT THE RESULT OF THE 1-D STRIPFITS. 4 PANELS, ONE FOR EACH STOKES
;PARAMETER; 4 COLORS, ONE FOR EACH STRIP.
;
;INPUTS:
;   B_0, the structure containing frequency info and scan nr. This
;is used only to annotate the plot title.
;
;   BOARD, the board number. Again, used only to annotate the plot
;title. 
;
;   TOTOFFSET, the total angular offsets of the strip positions in
;arcmin. totoffset[60,4]: 60 point per strip, 4 strips. units are ARCMIN
;
;   STOKESOFFSET_CONT, the stokes parametes for the strips in
;Kelvins. stokesoffset_cont[ 4, 60, 4]: 4 stokes, 60 pts/strip, 4 strips.
;
;   TEMPFITS, the ls fits to the data in stokesoffset_cont.
;tempfits[ 4, 60, 4], as in stokesoffset_cont.
;
;COMMON:
;   uses the colors defined in Carl's PLOTCOLORS common block.
;
;OUTPUTS: THE PLOT IN WINDOW 31. THE WINDOW IS CREATED IF IT IS NOT
;THERE.
;
;NOTE: this will do any nr of strips up to four; it selects the number
;according to the third dimensional element of tempfits.
;-


common plotcolors
;common crossparams

;EXTRACT FROM BEAMIN...
totoffset= beamin_arr[ nrc].totoffsets
stokesoffset_cont= beamin_arr[ nrc].stkoffsets_cont
tempfits= beamin_arr[ nrc].tempfits

;DEFINE QUANS WITH WHICH TO ANNOTE THE PLOT...
centerfreq  = mmInfo_arr[nrc].cfr
currentscan = mmInfo_arr[nrc].scan
srcname     = mmInfo_arr[nrc].srcname
board       = mmInfo_arr[nrc].brd

;CREATE A NICE BIG WINDOW...
device, window=opnd
if ( opnd[ 31] eq 0) then begin
device, get_screen_size=ss
window, 31, xs=ss[0]/2, ys=ss[1]+20, xpos=ss[0]- ss[0]/2, ypos= 20
endif
wset,31

!p.multi = [ 0, 1, 4]


plotcolor = [red, green, blue, yellow]
labelnumber = ['XX+YY', 'XX-YY', 'XY', 'YX']
nrstokes = 0

FOR nrstokes = 0,3 do begin
nr=0
plotmax = max( stokesoffset_cont[ nrstokes, *, *], min=plotmin)

indx = where(!y.range eq 0, count)
if (count ne 2) then begin
    plotmin = !y.range[0]
    plotmax = !y.range[1]
endif

plot, totoffset[ *, nr], stokesoffset_cont[ nrstokes, *, nr], $
    xtit = 'OFFSET, ARCMIN', /xsty, $
    ytit = labelnumber[ nrstokes], yrange = [plotmin, plotmax], /ysty, $
    psym=4, background=grey, color=black, charsize=1.8, $
    title = strcompress( srcname, /remove) + $
        '; SCAN ' + strcompress( currentscan, /remove) + $
        '; BOARD ' + strcompress( board, /remove_all) + $
        '; FREQ ' + strcompress( centerfreq, /remove), $
    /nodata

FOR nr = 0, (size( totoffset))[2]-1 do begin
oplot, totoffset[ *, nr], stokesoffset_cont[ nrstokes, *, nr], $
    psym = 4, color = plotcolor[ nr]
oplot, totoffset[ *, nr], tempfits[ nrstokes, *, nr], color = plotcolor[ nr]

ENDFOR
ENDFOR

xyouts, .18, .9, 'STRIP NR ', /norm
for nr= 0, 3 do $
xyouts, string( nr, format='(i2)'), color= plotcolor[ nr]
!p.multi=0

end
