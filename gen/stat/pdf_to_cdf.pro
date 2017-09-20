pro pdf_to_cdf, pdf, cdf

;+
;NAME: pdf_to_cdf -- given a pdf, get the cdf
;CALLING SEQUENCE:
;       pdf_to_cdf, pdf, cdf
;
;INPUT:
;       PDF, N-element pdf vector
;
;OUTPUT:
;       CDF, the N-element cdf vector.
;-


;given a pdf, get the cdf

cum= total( pdf, /cum)

cdf= cum/max(cum)

return
end

