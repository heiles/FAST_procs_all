;+
;NAME:
;tecbydate - setup for plotting by date
;SYNTAX: xtickf=tecbydate(formatCodes)
;ARGS:
;formatCode: string format codes to use on x axis. The default is:
;                   dayMonYr. see idl routine label_date() for a list of 
;                   the codes to use.
;                   %M month name
;                   %N month number (2 digits)
;                   %D day number of month (2 digits)
;                   %Y year (4 digits)
;                   %Z year (2 digits)
;                   %H hour (2 digits)
;                   %I minutes (2 digits)
;RETURNS:
;   xtickf: string  variable to pass to xtickformat=xtickf keyword when
;                   calling plot:
;
;EXAMPLE:
;; suppose we want the xaxis to be labeled as: yymmdd:hh
;   formatcodes='%Z%N%D:%H'
;   xtickf=tecbydate(formatCodes)
;   plot,tar.jd,tar.tec,xtickf=xtickf 
;-
function tecbydate,formatcodes
;
    if n_elements(formatcode) eq 0 then formatcodes='%D%M%Z'
    a=label_date(date=formatcodes)
    xtickf='label_date' 
    return,xtickf
end
