 PRO junk_wshow
      tlb = Widget_Base()
      draw = Widget_Draw(tlb, XSIZE=200, YSIZE=200)
      Widget_Control, tlb, /REALIZE
      XManager, 'tlb', tlb, /NO_BLOCK
   END
