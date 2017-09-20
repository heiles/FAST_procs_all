;
;   structures for dewar temperature monitoring
;
	a= {rcvMon, $
         key        :   bytarr(4) ,$; 'rcv'
         rcvNum     :   0B        ,$; receiver number
         stat       :   0B        ,$; b0-lkshor,b1=hemtledA,b2:hemtledB
         year       :   0         ,$; 4 digit year ast

         day        :    0.D      ,$; day of year with fraction of day ast.

         t16K   :         0.  ,$;
         t70K   :         0.  ,$;

         tomt   :         0.  ,$;
         pwrP15     :         0.  ,$; dewar +15, -15

         pwrN15     :         0.  ,$; dewar +15, -15
         postAmpP15 :     0.      ,$; postAmp +15 volt supply
         dcur       : fltarr(3,2) ,$;dewar bias currents[4amps, polA b]millamps
         dvolts     : fltarr(3,2) };dewar Volts    [amp1-4, polA b] volts

