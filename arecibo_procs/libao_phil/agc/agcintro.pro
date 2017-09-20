;+
;NAME:
;agcintro - intro/examples for agc routines.
;
;   The main telescope drive systems (Az,Gr,Ch or AGC) were designed and 
;built by vertex antenna company. There are two status blocks:Critical and
;Full blocks that are logged to disc once a second. The files are kept by
;day with the filenames cbFbyymmdd.dat in the directory /share/obs1/pnt/log.
;The last 6 months of data is normally kept on disc (data before this is
;backed up to tape).
;   The idl routine agcinpday allows you to input and manipulate this data. 
;The data is returned as an array of idl structures eg:
;
;IDL> npts=agcinpday(020605,b)
;IDL> help,b
;     B  STRUCT    = -> CBFB Array[86399]
;IDL> help,b,/st
;** Structure CBFB, 2 tags, length=288:
;   CB              STRUCT    -> CB Array[1] .. this is the critical block
;   FB              STRUCT    -> FB Array[1] .. this is the full block
;
;The critical block contains:
IDL> help,b.cb,/st
;** Structure CB, 8 tags, length=56:
;   TIME        DOUBLE        .013 .. seconds from midnite 
;   TMOFFSETPT  FLOAT      0.00000 .. time offset for program track
;   FREEPTPOS   UINT           127 .. free queue locations for prgmtrk
;   GENSTAT     UINT            64 .. generic status (bitmap)
;   MODE        UINT      Array[3] .. axis mode bitmaps (az,gr,ch)
;   STAT        UINT      Array[3] .. axis status bitmaps (az,gr,ch)
;   VEL         FLOAT     Array[3] .. motor velocity deg/sec (az,gr,ch)
;   POS         FLOAT     Array[3] .. encoder pos deg (az,gr,ch)
;
;The full block contains:
;
;IDL> help,b.fb,/st
;** Structure FB, 19 tags, length=232:
;   TIME          DOUBLE 0.08400   .. seconds from midnite
;   AX            STRUCT -> FBAXISINFO Array[3].. axis info struct(az,gr,ch)
;   AZENCDIF      FLOAT -0.0295564 ..  azEnc1-azEnc2 (deg) (dome-ch)
;   TQAZ          FLOAT Array[8]   .. az torques in ftlbs.
;                                     motor order:11,12,51,52,41,42,81,82 
;   TQGR          FLOAT Array[8]   .. gregorian torques in ftlbs.
;                                     motor order:11,12,21,22,31,32,41,42
;   TQCH          FLOAT Array[2]   .. carriage house torques in ftlbs.
;                                     motor order:1,2
;   PLCINPSTAT    BYTE  Array[20]  .. input status block from plc
;   PLCOUTSTAT    BYTE  Array[24]  .. output status block from plc
;   POSSETPNT     FLOAT Array[3]   .. position set point az,gr,ch (deg)
;   VELSETPNT     FLOAT Array[3]   .. velocity setpoint deg/sec (az,gr,ch)
;   BENDINGCOMPAZ INT         21   .. bending compensation for az
;   TORQUEBIASGR  INT         31   .. torque bias for gr (ftlbs)
;   GRAVITYCOMPGR INT        -26   .. gravity compensation gr (ftlbs)
;   TORQUEBIASCH  INT          0   .. torque bias ch
;   GRAVITYCOMPCH INT          0   .. gravity compensation ch (ftlbs)
;   POSLIM        FLOAT Array[2, 3].. poslim [upper,lower],[az,gr,ch] deg
;   ENCCOR        FLOAT Array[3]   .. encoder correction [deg] (az,gr,ch)
;   TMOUTNOHOSTSEC INT        20   .. timeout for vme system (secs)
;   TMELAPSEDSEC  LONG  24650888   .. elapsed time in seconds.
;
;Somethings to watch out for.
;   1. times:
;       The cblock and fblock have slightly different time stamps since
;       they are sampled serially. Occasionally the 1st time of 
;       a file is 86400.003 rather than .003. You need to fix this if it
;       messes up plotting versus time.
;   2. positions/velocities:
;       The positions cb.pos[] are the encoder values and are extremely
;       accurate. The velocities cb.vel[]  are derived from the amplifiers.
;       Each amplifier has a voltage readback that is proportional to the
;       speed. cb.vel[1] is the average of the eight dome amplifiers. If
;       you want an exact velocity, use the difference of encoder positions
;       divided by the time difference between readings.
;       
;       The position setpoint b.fb.setpoint[] is the last preset position 
;       requested. When running in program track mode (normal operation),
;       this value does not reflect the current location of the dome.
;
;       The velocity setpoint b.fb.velsetpnt is the velocity setpoint in
;       degrees per second that is passed to the analog circuitry by
;       the plc. The bias voltages (torque,gravity, delta velocity) are then 
;       added to this value to drive the PI loop.    
;       
;   3. torques.
;      The ch and gr torques are calibrated via hagens torque
;      wrench. We need to do this for the azimuth motors too. The
;      bending compensation, torquebias, gravity compensation are
;      from vertex and they need to be double checked. 
;
;   4. The last 12 bytes of plcoutstat have been replaced in the lcu
;      with the irig clock time monitor.
;
;EXAMPLES:
;
;   1. Input a days worth of data.
;      npts=agcinpday(020611,b)
;   2. fixup the time to be hour of the day
;      tm=b.cb.time/3600.
;      tm[0]=tm[1]      ; fix up the 86400. junk
;   3. plot dome position versus hour 
;       plot,tm,b.cb.pos[1]
;   4. grab the dome torques into a separate array and
;      reorder from [8,86400] to [86400,8] to make it easier to plot
;      then do a strip plot versus time with each tq a separate color.
;      (see generic idl routines stripsxy)
;      tqgr=transpose(b.fb.tqgr)
;      stripsxy,tm,tqgr,0,0,/step
;   5. monitor the torques on the dome for the current day:
;      agcmon,-1
;-
