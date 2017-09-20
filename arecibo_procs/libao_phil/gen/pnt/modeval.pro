;+
;NAME:
;modeval - evaluate the model at the requested az,za
;
;SYNTAX : modeval,az,za,modelData,azErrAsec,zaErrAsec,enc=enc,model=model
;
; ARGS    : 
;   az[]  :     azimuth positions degrees.
;   za[]  :     zenith angle positions degrees.
;   modelData: {modelData} loaded by modinp. defined in ~phil/idl/h/hdrPnt.h
;   azErrAsec:  [] return great circle az error in arc seconds.
;   zaErrAsec:  [] return great circle za error in arc seconds.
;
;   KEYWORDS:
;   enc   :     if 1 include encoder correction. default don't include it
;   model :     if 0 don't include model correction. default:include it.
;
; DESCRIPTION:
;   Evaluate the model at the specified az, za locations. These are the
; feed locations (not the source azimuth). Use the model data in the
; structure modelData (this structure can be loaded via modinp).
;
; Return the model errors in great circle arc seconds evaluated at the
; az,za. The errors are defined such that:
; 1. let azComp,zaComp be the computed az, za to move the feed to.
; 2. compute azE, zaE from the model.
; 3. azTouse = azComp + AzE*asecToRad
;    zaTouse = zaComp + ZaE*asecToRad
;-
pro modeval,az,za,modelData,azErrAsecs,zaErrAsecs,enc=enc,model=model
;
    ddtor=!dpi/180.d    
    if n_elements(enc) eq 0 then enc=0
    if n_elements(model) eq 0 then model=1
    azErrAsecs=0.d
    zaErrAsecs=0.d
    if  model ne 0 then begin 
    case modelData.format of 
        'B': begin
            azRd=ddtor*az;
            zaRd=ddtor*za;
            cosAz =cos(azRd);
            sinAz =sin(azRd);
            cos2Az=cos(2.*azRd);
            sin2Az=sin(2.*azRd);
            cos3Az=cos(3.*azRd);
            sin3Az=sin(3.*azRd);
            cos6Az=cos(6.*azRd);
            sin6Az=sin(6.*azRd);

            sinZa      =sin(zaRd);
            sinZa2     =sinZa*sinZa;
            cos3Imb    =sin(zaRd-.1596997627D)*cos3Az;
            sin3Imb    =sin(zaRd-.1596997627D)*sin3Az;

          azErrAsecs   =  modelData.azC[ 0]             + $
                          modelData.azC[ 1]*cosAz       + $
                          modelData.azC[ 2]*sinAz       + $
                          modelData.azC[ 3]*sinZa       + $
                          modelData.azC[ 4]*sinZa2      + $
                          modelData.azC[ 5]*cos3Az      + $
                          modelData.azC[ 6]*sin3Az      + $
                          modelData.azC[ 7]*cos3Imb     + $
                          modelData.azC[ 8]*sin3Imb     + $
                          modelData.azC[ 9]*cos2Az      + $
                          modelData.azC[10]*sin2Az      + $
                          modelData.azC[11]*cos6Az      + $
                          modelData.azC[12]*sin6Az

          zaErrAsecs   =  modelData.zaC[ 0]             + $
                          modelData.zaC[ 1]*cosAz       + $
                          modelData.zaC[ 2]*sinAz       + $
                          modelData.zaC[ 3]*sinZa       + $
                          modelData.zaC[ 4]*sinZa2      + $
                          modelData.zaC[ 5]*cos3Az      + $
                          modelData.zaC[ 6]*sin3Az      + $
                          modelData.zaC[ 7]*cos3Imb     + $
                          modelData.zaC[ 8]*sin3Imb     + $
                          modelData.zaC[ 9]*cos2Az      + $
                          modelData.zaC[10]*sin2Az      + $
                          modelData.zaC[11]*cos6Az      + $
                          modelData.zaC[12]*sin6Az  
            end
          else: begin
                message,'model format' + modelData.format + ' not yet supported'
                end
        endcase
        endif
; 
;       compute the encoder error   
;
        if enc ne 0 then begin
            tmp=interpolate(modelData.enctblaz,za*2.)
            azErrAsecs=azErrAsecs+tmp
            tmp=interpolate(modelData.enctblza,za*2.)
            zaErrAsecs=zaErrAsecs+tmp
        endif
        return
end
