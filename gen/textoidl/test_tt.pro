!p.font=0
psopen, '~/foo.ps', xs=4, ys=4, /inch, /times, /bold, /iso
plot, [0]
;xyouts, 0.5, 0.7, /norm, scinot(2.34567890d-11, form='(f0.7)')
;xyouts, 0.5, 0.7, /norm, scinot(2.34567890d-11, form='(f0.7)'),FONT=0
xyouts, 0.5, 0.7, /norm, scinot(2.34567890d-11, form='(f0.7)',FONT=0)
psclose
!p.font=-1
