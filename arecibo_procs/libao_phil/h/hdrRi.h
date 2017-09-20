;
;   ri inp portion of hdr
;
a={hdrriV1,    extTiming:       0L,$;0--> use rtg
               smpMode:         0L,$;-1 ipp nogwcount,0 contin,1 ipp with gwcnt
               packing:         0L,$;1,2,4,8,12
       muxAndSubCyclde:         0L,$;0none,1 mux,10cyclmode,11 both
               fifoNum:         0L,$;1,2,12
            smpPairIpp:         0L,$;samples for 1 pair in  1 ipp
            ippsPerBuf:         0L,$;ipps per buf
        ippNumStartBuf:         0L,$;1st ipp of this buf. count from 1
                   ipp:         0.,$;in usecs
                    gw:         0.,$;in usecs.. sampling interval
               startOn:         0L}

a={hdrriV2,    extTiming:       0L,$;0--> use rtg
               smpMode:         0L,$;-1 ipp nogwcount,0 contin,1 ipp with gwcnt
               packing:         0L,$;1,2,4,8,12
       muxAndSubCyclde:         0L,$;0none,1 mux,10cyclmode,11 both
               fifoNum:         0L,$;1,2,12
            smpPairIpp:         0L,$;samples for 1 pair in  1 ipp
            ippsPerBuf:         0L,$;ipps per buf
        ippNumStartBuf:         0L,$;1st ipp of this buf. count from 1
                   ipp:         0.,$;in usecs
                    gw:         0.,$;in usecs.. sampling interval
               startOn:         0L,$;0,1,10,99 what to start on 
			      free:         0L}

	common riunpcom,rilkup1,rilkup2,rilkup4,rilkup8
	rilkup1=[1.,-1.]
	rilkup2=[.5,1.5,-1.5,-.5]
	rilkup4=findgen(16)+.5
	rilkup4[8:*]=-16.+rilkup4[8:*]
	rilkup8=findgen(256)+.5
	rilkup8[128:*]=-256. + rilkup8[128:*]
