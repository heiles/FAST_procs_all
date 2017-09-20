; TEST DISPLAYING A DIRECT COLOR IMAGE...
.run ct_fiddle

device, GET_VISUAL_NAME=visual_class, GET_VISUAL_DEPTH=depth
if not (strmatch(visual_class,'DirectColor',/FOLD_CASE) AND $
        (depth eq 24)) $
  then stop, 'You are not running in 24-bit DirectColor!' $
  else print, 'You are running 24-bt DirectColor.'

print, 'Press ANY KEY to move on to the next test.'

loadct, 0, /SILENT
xsize = 500
ysize = 250
img = bytscl(findgen(xsize)) # (bytarr(ysize)+1B)

window, 0, XSIZE=xsize, YSIZE=ysize, TITLE='This should be a grayscale ramp!'
tv, img

io = get_kbrd(1)

window, 0, XSIZE=xsize, YSIZE=ysize, TITLE='This should be the red channel!'
tv, img, CHANNEL=1

io = get_kbrd(1)

window, 0, XSIZE=xsize, YSIZE=ysize, TITLE='This should be the green channel!'
tv, img, CHANNEL=2

io = get_kbrd(1)

window, 0, XSIZE=xsize, YSIZE=ysize, TITLE='This should be the blue channel!'
tv, img, CHANNEL=3

io = get_kbrd(1)

window, 0, XSIZE=xsize, YSIZE=ysize, TITLE='This should be a rainbow color table!'
loadct, 13, /SILENT
tv, img

io = get_kbrd(1)

loadct, 0, /SILENT
read_jpeg, filepath(SUBDIR=['examples', 'data'], 'rose.jpg'), img
img = rebin(img,3,227*3,149*3)
window, 0, XSIZE=227*3, YSIZE=149*3, TITLE='This should look like a rose!'
tv, img, TRUE=1

io = get_kbrd(1)

window, 0, XSIZE=227*3, YSIZE=149*3, TITLE='Make the red disappear!'
tv, img, TRUE=1
ct_fiddle, 'r'
