;+
;NAME:
;0Readme - rfirms routines
;   These are the idl routines that compute fractional occurence of rfi
;by frequency. It does this by computing the rms/mean for each frequency
;channel in a scan. Any  rms/mean greater then a threshold value are 
;called rfi. 
;
;   Users may want to use rfi plthistloop to look at the data.
;
;Computing the rms by channel from correlator files:
; --------------------------------------------------
;       pfrms - compute rms spectra for every scan in a file.
;               (corrms() is called to process each scan).
;pfrmsinpfiles- take a filelist and call pfrms for every filename in the list.
;
;Making histograms of rfi by frequency channel for rms data:
; ----------------------------------------------------------
;rfihistscan    - compute rfi for 1 scan add to histogram. 
;pfrfihist      - take a filelist and call rfihistscan for every scan in
;                 each file.
;
;Processing the monthly data:
; ---------------------------
;rfimkhist      - for each month find all of the archived rms files and make
;                 a histogram for each month (of the requested receiver range).
;                 Store the histograms in idl save files.
;rfihistlist    - called by rfimkhist to make the filelist for a month.
;rfihistinp     - after making the monthly histograms this routine will make
;                 the year to date histogram including all months.
;
;Plotting histograms:
; -------------------
;rfihistinp     - inputs a histogram save file.
;rfiplthist     - plot a histogram.
;rfiplthistloop - input and plot a range of histograms.
;
;toUse rfiplthistloop:
; -------------------
;
;   idl
;   @phil
;   @rfiinit
;   rfiplthistloop,'lb',1,9 .. to plot jan-sep. see the documention for
;                the arguments.
;
;-  
