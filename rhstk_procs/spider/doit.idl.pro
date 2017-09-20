
@initialize_doit.idl

mmproc, outpath, gbtdatafile, $
	calbefore, strip, calafter, $
	board, tcalxx_board, tcalyy_board, $
        scndata, hb_arr, a, fp, beamin_arr, beamout_arr, indx, $
	beamin_cont_arr, beamout_cont_arr, $

;KEYWORDS RELEVANT TO MM0:
        mm_corr= mm_corr, mm_pro_user= mm_pro_user, $
        m_rcvrcorr= m_rcvrcorr, m_skycorr= m_skycorr, m_astro= m_astro, $
        sourcename= sourcename, rcvr_name= rcvr_name, $
        plot1d= plot1d, print1d= print1d, plot2d= plot2d, $
        print2d= print2d, keywait= keywait, npatterns= npatterns, $
        savemm0=savemm0, srcprint= srcprint, phaseplot=phaseplot, $
	nterms= nterms, $

;KEYWORDS RELEVANT TO MM4:
        mm4_1d=mm4_1d, mm4_2d=mm4_2d, $
	plt0yes=plt0yes, plt1yes=plt1yes, ps1yes=ps1yes, $
        check=check, negate_q=negate_q, chnl=chnl, saveit=saveit, $
        m7=m7, nominal_linear=nominal_linear, $
        squoosh=squoosh, totalquiet=totalquiet
