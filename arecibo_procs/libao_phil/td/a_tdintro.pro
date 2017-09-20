;+
;NAME:
;a_tdintro - Looking at tiedown data
;   
;Where the data comes from:
;
;       The tiedown archive data is recorded with 1 second resolution by
;the program tieLogD. It is running on the observer computer and reads
;from the scramnet memory. The daily archive files are located in
;/share/obs2/tie/log/tieyymmdd.dat. The program is started 
;automatically by the  rc3.d/S99local script when the computer is booted. The
;source code is found in ~phil/vw/datatk/shm/Mon/Tie/tieLogD.c .
;
;   At the end of each day the daily file is copied to a backup area:
;/share/phil/bkup/tie/. At then end of each month the data is moved to
;a subdirectory of yymm/.. 
;
;Using the data:
;
;   To look/use the data you need to start idl (preferablly on one
;of the linux server machines.. fusion00,fusion01,fusion02, aolc1,..)
;
;   idl
;   @phil
;   @tdinit
;  .. some routines need access to the laser ranging routines.. for these
;     @lrinit.
;
;1. The raw data: 
;
;   - tdinpday() this inputs the 1 second data for a day. It can be
;                a summary (the default) or the complete data structure.
;
;
;2. 1 minute summary data:
;
;   - tdsummary() this routine returns summyar info for a  range of dates.
;                The data has been intepolated to 1 minute resolution. 
;                It also contains the laser ranging info.  This data is 
;                created at the end of each month so you can only look 
;                at data from months prior to the current.
;
;3. Make some plots:
;   - tdchkday() this makes a summary plot of a days worth of data.
;                it also returns the full 1 second records.
;   - tdkips()   plot the tensions for a day.
;   
;-
