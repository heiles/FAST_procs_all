pro cdf_to_pdf, cdf, pdf

;+
;NAME: cdf_to_pdf -- given a cdf, get the pdf
;CALLING SEQUENCE:
;	cdf_to_pdf, cdf, pdf
;
;INPUT:
;	CDF, N-element cdf vector
;
;OUTPUT:
;	PDF, the N-element pdf vector.
;-


pdf= [ cdf[0],[(cdf- shift(cdf,1))[1:*]] ]

return
end

