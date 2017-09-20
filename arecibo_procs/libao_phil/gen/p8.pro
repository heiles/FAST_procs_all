;+
;NAME:
;p8 - set frame buffer to pseudo color.
;SYNTAX: p8
;ARGS:   none
;DESCRIPTION:
;   Set the terminals frame buffer to pseudo color. This
;should be done before any plotting is done.
;-
pro p8
device, pseudo_color=8
return
end
