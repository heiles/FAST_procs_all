;+
;NAME:
;awappexamples - Using the wapp pulsar routines.
;
;   Starting idl.
;   - To use the wapp routines you need to tell idl where to
;     look to get these procedures. You can do it manually each
;     time you run idl, or you can put it in an idl startup file.
;     Manually:
;       idl
;       @phil
;       @wappinit
;
;     Using a idl setup file:
;       Suppose your home directory is ~jones.
;       create the file ~jones/.idlstartup
;       add the lines        
;          !EDIT_INPUT=500
;          @phil
;          @wappinit
;       to this file.
;       In your .cshrc file (if you run csh) add the line
;           setenv IDL_STARTUP ~/.idlstartup
;       You can then run idl with :
;           idl
;       
;INTRO.
;
;   The wapp consists of up to 4 cpus (wapp1,wapp2,wapp3,wapp4). During
;datataking each cpu will write a separate file. The files will change
;after 2.2 gb or the start of a new observation.
;
;   The gui (cima) will write the names of these files to a logfile. This
;file is normally called: /share/obs4/usr/pulsar/'projid'/'projid'.cimalog
;The routines wappgetfileinfo() or wapplistfileinfo will scan these
;files and create a structure holding the filenames and header info
;for every file found. These can be used to access the files. It is 
;also possible to open an single file and process it.
;
;   The routines read in data, normalize the acf's, compute the spectra,
;and scale to total power. No level correction is done yet. Cross
;spectra are not yet implemented/returned..
;
;0. MISC..
;   - to access a procedures documentation:
;     or http://www.naic.edu/~phil,-->software document..-->idl wapp documenation
;   - ctrl-c:             
;     if you ctrl-c out of a routine, you may have to type retall to get
;     back to the main level (i'm stilll debugging some routines and they
;     don't all do it automatically).
;   - generic routines:
;     idl routines that are not wapp specific are documented under
;     idl generic routines.
;
;1. Input/list  all datafiles in a logfile:
;   You can input or input and list all of the file info for the datafiles
;   in a logfile. The information includes the filenames and the headers.
;   Any files no longer on disc are skipped.
;   A. To input without listing:
;      1. logfile='/share/obs4/usr/pulsar/p1770/p1770.cimalog'
;      2. nsets=wappgetfileinfo(lun,wappI,logfile=logfile)
;      The info is returned in wappI.. (help,wappI,/st)
;
;   B. To input and list the datafiles in the logfile.
;      1. logfile='/share/obs4/usr/pulsar/p1770/p1770.cimalog'
;      2. wapplistfileinfo(wappI,logfile=logfile)
;      The info is returned in wappI.. (help,wappI,/st)
;
;2. Accessing a single datafile:
;
;   The sequence is:
;   1. open the file (or let wappgethdr() open it)
;   2. call wappgethdr() to read the header
;   3. wappget()  input data (one or more records).
;
;   EXAMPLE:
;   1. openr,lun,'/share/wapp11/B1737+13_north.wapp.52776.000',/get_lun
;   2. istat=wappgethdr(lun,hdr)
;   3. nrecs=wappget(lun,hdr,d,nrec=1000)
;   4. help,d,/st
;      D  FLOAT = Array[256, 2, 1000]
;      256 channels by 2 pol by 1000 records (the cross pol were not returned)
;   .. call free_lun,lun when done with i/o
;
;   or
;   1. logfile='/share/obs4/usr/pulsar/p1770/p1770.cimalog'
;   2. wapplistfileinfo,wappI,logfile=logfile
;   3. Open the 6th entry in wappI
;      istat=wappgethdr(lun,hdr,wappcpuI=wappI[5].wapp[0])
;   4. nrecs=wappget(lun,hdr,d,nrec=1000)
;   .. call free_lun,lun when done with i/o
;
;   The nrec= keyword lets you move around in the file. By default the 
;   access is sequential. 
;
;   Beware using: 
;     rew,lun
;     nrecs=wappget(lun,hdr,d,nrec=1000)
;   This will fail since wappget() is positioned at the header, not the
;   first datarecord. In this example
;     rew,lun
;     nrecs=wappget(lun,hdr,d,nrec=1000,posrec=1)
;   will work.
;
;3. monitoring file via images.
;   You can make a continuous set of images of datasets using
;   wappmonimg()
;
;   A. looking at a single file:
;      1. openr,lun,'/share/wapp11/B1737+13_north.wapp.52776.000',/get_lun
;      2. istat=wappgethdr(lun,hdr)
;      3. clip=[-.5,.5]         scale lut to these data values
;      4. xloadct               adjust the lut.
;      5. img=wappmonimg(lun,hdr,pol=12,clip=clip)
;         You an adjust the clip level by quitting, and then plotting
;         the returned img..
;         window,0
;         plot,img
;
;   B. looking at all datatfiles in a logfile.
;      1. logfile='/share/obs4/usr/pulsar/p1770/p1770.cimalog'
;      2. clip=[-.1,.1]         scale lut to these data values
;      3. xloadct               adjust the lut.
;      4. img=wappmonimg(lun,hdr,pol=12,clip=clip,logfile=logfile)
;         You can select different boards/files in logfile using the
;         menu in wappmonimg (hit any key for it to appear).
;
;4. DISCLAIMERS:
;   This is currently being written so lots of things may not work. 
;Let me know what troubles you have (phil@naic.edu).
;-
