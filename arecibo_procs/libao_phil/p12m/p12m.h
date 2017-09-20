;
; 12meter idl include file
;
;---------------------------------------------------------------------
; define structs to hold decoded status for 4 p12m device stat
;  and the program stat.
;
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;  status:  azmaster, azslave, elmaster, central
;  For each status struct keep the 32 bit status word (in host order)
;  and break out each bit into a byte (to not have to mess with
;  bit fields and byte ordering..)
;

a={p12mStazM,$
	status32:0ul,$ 			; 32 bit word all status bits
							; byteswapped to host format
;  for each  byte entries are msb to lsb
;  byte 0
	highHardLim      :0b,$
	lowHardLim       :0b,$
	highSoftLim      :0b,$
	lowSoftLim       :0b,$;
	motShaftBrakeOn  :0b,$ ; 1 coil not energizedon , 0 coil energized
	local            :0b,$ ; 1 local, 0 remote
	driveNotEnergized:0b,$;1 not energized, 0 energized
	driveNotHealthy  :0b,$;1 drive not healthy, 0 healthy
;   byte 1
	turnCountsErr    :0b,$; 0 no error, 1 error
	posDemandLimHigh :0b,$; 1 high software limit
	posDemandLimLow  :0b,$; 1 low software limit
	noDigLockVirtAxis:0b,$; 0 locked 1 not locked .track mode only	  
	offsetProfNotAtSpeed:0b,$;0 at speed, 1 not at speed.. velocity mode
	offsetProfNotAtPos:0b,$;0 at pos, 1  at pos.. position mode
	mainProfNotAtSpeed:0b,$;0 at speed, 1 not at speed.. velocity mode
	mainProfNotAtPos  :0b,$;0 at pos, 1  at pos.. position mode
;          byte 2
    free2_7           :0b,$;            
	motBrakeOn        :0b,$;1 coil not energized. measured via current. 
	motBrakeAlarm     :0b,$;1 drive energized and afer 1 sec and
;                           motBrakeOn still 1
    free2_4           :0b,$;         
	virtAxisSpeedDemandLim:0b,$;1 virt axis spd exceeds axis limit
    free_2_2          :0b,$
	RunNotPermitted   :0b,$;1 if brakealarm,axisrunaway,turnCntFail
	driveNotEnabled   :0b $;1 if safety relay tripped
} 

; status azimuth slave status 3*4 = 12 bytest

a={p12mStazSl,$
	status32         :0ul,$	; 32 bit word all status bits
                            ; byteswapped to host format
;   byte 0
    free0_7          :0b,$
    free0_6          :0b,$
    free0_5          :0b,$
	motBrakeOn       :0b,$;1 coil not energized. measured via current. 
	motBrakeAlarm    :0b,$;1 drive energized and afer 1 sec and
                          ;  motBrakeOn still 1
	driveNotEnabled  :0b,$;1 if saftey tripped
	driveNotEnergized:0b,$;1 not energized, 0 energized
	driveNotHealthy  :0b $;1 drive not healthy, 0 healthy
} 

; elevation status   7*4=28 bytes

a={p12mStel,$
	status32         :0ul,$	; 32 bit word all status bits
                           ;    byteswapped to host format
;   byte 0
    highHardLim      :0b,$
    lowHardLim       :0b,$
    highSoftLim      :0b,$
    lowSoftLim       :0b,$
	motShaftBrakeOn  :0b,$;1 coil not energizedon , 0 coil energized
    local            :0b,$;1 local, 0 remote
    driveNotEnergized:0b,$;1 not energized, 0 energized
    driveNotHealthy  :0b,$;1 drive not healthy, 0 healthy
;          byte 1
    free1_7             :0b,$;
    posDemandLimHigh    :0b,$;1 high software limit
    posDemandLimLow     :0b,$;1 low software limit
    noDigLockVirtAxis   :0b,$;0 locked 1 not locked .track mode only     
    offsetProfNotAtSpeed:0b,$;0 at speed, 1 not at speed.. velocity mode
    offsetProfNotAtPos  :0b,$;0 at pos, 1  at pos.. position mode
    mainProfNotAtSpeed  :0b,$;0 at speed, 1 not at speed.. velocity mode
    mainProfNotAtPos    :0b,$;0 at pos, 1  at pos.. position mode
;          byte 2
    free2_7             :0b,$
    motBrakeOn          :0b,$;1 coil not energized. measured via current. 
    motBrakeAlarm       :0b,$;1 drive energized and afer 1 sec and
                             ;  motBrakeOn still 1
    mainBrakeAlarm      :0b,$;1 drive energized and afer 1 sec and
                             ;  mainBrakeIndicator has not released
    virtAxisSpeedDemandLim:0b,$;1 virt axis spd exceeds axis limit
    mainBrakeOn         :0b,$;1 micro switch says brake on
    RunNotPermitted     :0b,$;1 if brakealarm,axisrunaway,turnCntFail
    driveNotEnabled     :0b $;1 if safety relay tripped
}

;/ central status 8*4 - 32 bytes

a={p12mStcen,$
    status32            :0ul,$; 32 bit word all status bits
                              ; byteswapped to host format
;           byte 0
	autoStowInpActive   :0b,$;1-> 
	trkArrayLess10Pnts  :0b,$;1-> < 10 unexpired points in array.
	tmOut30sec          :0b,$;1-> enabled and timed out
	sntpResponseSlow    :0b,$;1-> response not received within warning
                             ;    delay time set in ethernet module
	sysClkNotInitialized:0b,$;1-> haven't got 1st sntp time 
	sumOperateNotReady  :0b,$;1--> 1 drive not in operate state
	sumNotRemote        :0b,$;1 --> at least 1 drive not in remote
	pwr3PhaseOff        :0b,$;1 --> 3 phase contactor open
;   byte 1
	azTrkStartOutOfRange:0b,$;1-->
	azTrkStartTurn      :0b,$;0-turn-1,1-turn0,2=turn+1,3:auto
                             ;   used two bit
	tmOut30secDisabled  :0b,$;1 disabled, 0 enabled
	raDecTrkingData     :0b,$;0 setpointss,1 trkarray,2 ramps
                             ; uses 2 bits
	trkCoordEquat       :0b,$;1 equatorial, 0 horizon
	stowInProgress      :0b,$;1 - currently stowing.
;   byte 2
	curRunMode 			:0b,$;0 stop,1 pos,2 vel,4 track
                             ; uses 2 bits
	azSlvOnline         :0b,$;1=az slave axis processor online
	azMasterOnline      :0b,$;1=az master axis processor online
	free2_3             :0b,$ 
	elOnline            :0b,$;1=el axis processor online
	free2_1             :0b,$             
	trkArrReinit        :0b,$;track arrays currently reinitializing
;/          byte 3
	connectFilterOn     :0b,$;1=connection filter applied
	free3_6             :0b,$ 
	correctionsDisa     :0b,$;0= refract,pointing on, 1 refract off,
                             ;2=pointing off, 3 refract,pointing off
							 ; uses 2 bits
	curAzElOffsetMode   :0b,$;0 stop, 1 position
	curRaDecOffsetMode  :0b,$;0 stop, 1 position
	free3_1             :0b,$
	curOffsetMode       :0b $;0 stop, 1 position
}
;
; device stat struct holding the 4 stats before decoding
;
a={p12mDevStWdsU,$
    azM :0ul,$  ; az master
    azSl:0ul,$  ; az slave
    el  :0ul,$
    cen :0ul $  ; central status
}
; device stat struct holding the 4 stats afterdecoding
a={p12mDevStWds,$
    azM :{p12mStAzM},$  ; az master
    azSl:{p12mStAzSl},$; az slave
    el  :{p12mSTel},$
    cen :{p12mStcen} $  ; central status
}

; ---------------------------------------------------
; pipelined requested data..
;
a={p12mPlDat,$
    azReqD:0d,$; for this timestamp, cmp + correction .. degrees
    elReqD:0d,$; for this timestamp, cmp + correction
    corAzD:0d,$; total az correction
    corElD:0d,$; total el correction
    modelCorAzD:0d,$; model correction
    modelCorElD:0d,$; model correction
    modelLocAzD:0d,$; where model correction computed
    modelLocElD:0d,$; where model correction computed
    raJReqD:0d,$;  deg.for this timestamp, backcomputed from az,el
    decJReqD:0d,$;   for this timestamp
    c1OffCumD:0d,$;  cumulative offset first coord..az
    c2OffCumD:0d,$;  cumulative offset 2nd coord  .. el
     dut1Sec:0d,$;   for this time stamp
    tickTmIsec:0ll$  ;so we can make sure pl and current equal
}
; ---------------------------------------------------
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; state info read every sec not decoded
;
a={p12mStBlkU,$
	mjd    :0D,$
	; 32bit status.  not decoded
	stwds: {p12mDevStWdsU},$
	azPos_D:0d,$
	azErr_D:0d,$; deg
	azFdBackVel_DS:0d,$;deg/sec
	azMotCur_A:0d,$;
	azSlMotCur_A:0d,$;
	elPos_D:0d,$;
	elErr_D:0d,$;
	elFdBackVel_DS:0d,$;
	elMotCur_A:0d$;
}
;
; logI unformatted.. matches disc
;
a={p12mLogIU,$
    cpuTmAtWaitTick: 0d,$;// secs 1970 when wait for tick
    cpuTmAtTick: 0d,$    ; // secs 1970 at tick
    durRdDev: 0d,$       ; // number secs to rd device
    durWrLast: 0d,$      ;// number secs for previous write blk
	st       : {p12mStBlkU},$; not decoded 
	 tickTmIsec: 0ll,$
	 prState :       0ul ,$
     numIoThrds: 0l,$
     frListFrBufs:0l,$
     nDevConnectOk:0l,$
     nDevConnectFail:0l,$
     trArFreePnts   :0l,$
		pl:{p12mPlDat}, $
	 azErrD: 0.,$
	 elErrD: 0.,$
	 gcErrD: 0.,$
	 fill  : 0.}

; ----------------------------------------------------
; logI decoded.. matches disc
;  stat block decoded
;
a={p12mStBlk,$
	mjd    :0D,$
	stwds:{p12mDevStWds},$; decoded stat words
	azPos_D:0d,$
	azErr_D:0d,$; deg
	azFdBackVel_DS:0d,$;deg/sec
	azMotCur_A:0d,$;
	azSlMotCur_A:0d,$;
	elPos_D:0d,$;
	elErr_D:0d,$;
	elFdBackVel_DS:0d,$;
	elMotCur_A:0d$;
}
;
; decoded program stat word

a={p12mPrStWd,$
	trPnt         :0,$ ; b0 prg has valid tracking point
	trPntPending  :0,$ ; b1   prg has valid pending tracking point
	telState      :0,$ ; b2-4 telescope state
	reqState      :0,$ ; b5-7 requested new state
	waitNextState :0,$ ; b8-10next state we are waiting for
;
	stChangeReq   :0, $ ;b11 state change request is active
	xfWaitTick    :0, $ ;b12 xf waiting on tick
	xfWaitStop    :0, $ ;b13 xf waiting on tick
	xfWaitReset   :0,$ ; b14 xf waiting on reset
	xfWaitReboot  :0,$ ; b15 xf waiting on reboot
	p12mConActive :0,$ ; b16 if actively con/re/connecting
	onSrc         :0 $ ; b17 if on source
	} 
; ----------------------------------------------------
; logI unformatted.. matches disc
;
a={p12mLogI,  $
    cpuTmAtWaitTick: 0d,$;// secs 1970 when wait for tick
    cpuTmAtTick: 0d,$    ;// secs 1970 at tick
    durRdDev: 0d,$       ;// number secs to rd device
    durWrLast: 0d,$      ;// number secs for previous write blk
        st:{p12mStBlk}, $; decoded
	 tickTmIsec: 0ll,$
	 prState: {p12mPrStWd},$
     numIoThrds: 0l,$
     frListFrBufs:0l,$
     nDevConnectOk:0l,$
     nDevConnectFail:0l,$
     trArFreePnts   :0l,$
		pl:{p12mPlDat}, $
	 azErrD: 0.,$ ; little circle req-measured
	 elErrD: 0.,$
	 gcErrD: 0.,$
	 fill  : 0.}
;---------------------------------------------------------------------------
; hold model info for a given model. used by pnt/modeval,modinp.,fitmod
;
a={p12mmodeldata,$
				fname:         '',$; where we looked for model
			     name:         '',$; model name... modelSB
                type  :          0,$; 1 - mark godwin
                 nargs:          0,$; number coef in az or el
		        yymmdd:         0L,$; when it became active
              coefC1  : dblarr(20),$; coef from col 1
              coefC2  : dblarr(20)}; coef from col 2

