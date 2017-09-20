pro htmlgen

;+
;NAME:
;HTMLGEN -- make html help list for carl's procs.

list_gen= ['array' ,$
'astro' ,$
'color' ,$
'colortest' ,$
'display' ,$
'fits' ,$
'fitting' ,$
'gaussians' ,$
'general' ,$
'idlutils' ,$
'idlutils_carl' ,$
'image' ,$
'math' ,$
'mpfit' ,$
'path' ,$
'plotting' ,$
'ps' ,$
'sig_processing' ,$
'stat' ,$
'textoidl' ,$
'unix' ,$
'wavelets' ,$
'window' ,$
'zeeman']

outfile= list_gen + '.html'

for nr=0,n_elements( list_gen)-1 do $
mk_html_help, '/dzd2/heiles/idl/gen/' + list_gen[ nr], $
;mk_html_help, input, $
	'/dzd2/heiles/idl/gen/html/' + outfile[ nr], $
	title= list_gen[ nr] + ' procs'

return
end

