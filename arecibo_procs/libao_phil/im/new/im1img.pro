;+
;NAME:
;im1img - input and plot an image of 1 frequency for 1 day.
;
;SYNTAX:  im1img,yymmdd,freq,img,xrange,yrange,win=win,zx=zx,zy=zy
;
;ARGS  :
;   INPUTS:
;   yymmdd: long    year,month,day to display
;   freq  : float   frequency band to display
;  OUTPUTS:
;   img[401,n]:float  2-d image displayed. dbm units.
;   xrange[2] :float  min,max frequency   (for x labeling).
;   yrange[2] :float  min,max hour of day (for y labeling).
;
;KEYWORDS:
;   win   : int     window to write to.default is window,1
;   zx    : int     zoom in x direction (by pixel replication). default : 2 
;   zy    : int     zoom in y direction (by pixel replication). default : 4 
;
;DESCRIPTION:
;   Input a days worth of rfi monitoring data for a particular frequency
;band. Create a 2-d image and display it. Return the image and the x,y
;label values. Also print out the imgdisp line that was used to display
;the image (copy and paste this line to redo the image).
;
; The frequency bands are:
;      70 ,165 , 235, 330, 430, 550, 725, 955,1075,1325,1400,2200,
;     3600,4500,5500,6500,7500,8500,9500
;
;The image is scaled to db's. The display routine limits the data range
;to -1 sigma and +2 sigma about the median. You can recall the display 
;routine with different values.
;
;imgdisp,(img>(-61.0))<(-50.9),xrange=xrange,yrange=yrange,zx= 2,zy= 4,win= 1
;
;In the above line the image is clipped below at -61, and clipped from above
;at -50.9. To get an idea of the range of data values you can:
;window,0       .. so you don't overwrite the image
;plot,img       .. plot out the whole image.
;
;EXAMPLE:
; .. do the following 3 lines when starting idl.
; .. the routines are setup to work from an xterm.
;
;idl
;@phil
;@iminit
;
;then you enter:
;
;im1img,10423,1325,img,xrange,yrange,
;.. the routine will display the image and then print the lines:
;
;   average:-56.9 median:-57.6 rms: 3.35 call:
;   imgdisp,(img>(-61.0))<(-50.9),xrange=xrange,yrange=yrange,zx= 2,zy= 4,win= 1
;
;You can use the cursor left button to grab the 2nd line and re-execute it
;(this also puts it in idl's history buffer so the up arrow can then 
; re-execute it).
;
;xloadct  .. to start the color  table editor.
;window,0
;plot,img .. to get an idea of the data range
;imgdisp,(img>(-61.0))<(-55),xrange=xrange,yrange=yrange,zx= 2,zy= 4,win= 1
;         .. redo the image with a different scaling.
;cp       .. position the cursor and then hit a button to read the 
;            freq, and time off of the image.
;-
pro im1img,yymmdd,freq,img,xrange,yrange,win=win,zx=zx,zy=zy
;
    if not keyword_set(zx)   then zx=2
    if not keyword_set(zy)   then zy=4
    if not keyword_set(win)  then win=1
    
    iminpday,yymmdd,d 
    imgfrq,d,freq,d1
    len=n_elements(d1.r)
    img=d1.r.d
    immktm,d1,y
    yrange=[y[0],y[len-1]]
    y=immkfrq(d1.r[0])
    xrange=[y[0],y[400]]
    medval=median(img)
    a=rms(img,/quiet)
    sig=a[1]
    minv=medval - sig
    maxv=medval + 2*sig
    imgdisp,(img> minv)<maxv,xrange=xrange,yrange=yrange,zx=zx,zy=zy,win=win
lab=string(format='("average:",f5.1," median:",f5.1," rms:",f5.2," call:")',$
                a[0],medval,a[1])
    
    print,lab
    lab=string(format=$
'("imgdisp,(img>(",f5.1,"))<(",f5.1,"),xrange=xrange,yrange=yrange,zx=",i2,",zy=",i2,",win=",i2)',minv,maxv,zx,zy,win)
    print,lab
    flush,-1
    return
end
