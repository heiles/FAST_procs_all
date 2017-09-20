;+
;NAME:
;covarnorm - normalize the covariance matrix
;SYNTAX: covar=corvarnorm(covar)
;ARGS:
;   covar[]: float covariance matrix.
;DESCRIPTION:
;   Normalize  a covariance matrix to have unit diagonols.
;-
function covarnorm,covar

    s=size(covar)
    doug=covar[indgen(s[1])*(s[1]+1)]
    doug = doug#doug
    return,covar/sqrt(abs(doug))
end
