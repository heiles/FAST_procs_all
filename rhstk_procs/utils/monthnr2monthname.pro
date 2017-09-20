function monthnr2monthname, monthnr

;+
;NAME: monthnr2monthname
;
;CALLING SEQUENCE
;   monthname = monthnr2monthname( monthnr)
;
;

monthname_vec= ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', $
                'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

if monthnr ge 1 and monthnr le 12 then return, monthname_vec[ monthnr-1] $
   else print, 'Month nrs must lie between 1 and 12, inclusive; returning'

return, 'XXX'

end
