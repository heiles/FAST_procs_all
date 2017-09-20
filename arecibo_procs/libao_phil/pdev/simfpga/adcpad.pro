pro adcpad,adc_off,adc_scale,dat_in,ovl_in,dat_out,ovl_out,verb=verb,stop=stop

	dat_off_sum=long(dat_in) + adc_off
	m1=(dat_in  and '800') ne 0
	m2=(adc_off and '800') ne 0
	m3=(dat_off_sum and '800') ne 0
	ovl=(m1 eq m2) && (m1 ne m3)
	adcpad_mult,dat_off_sum,adc_scale,ovl,dat_out,ovl_out,verb=verb,stop=stop
	return
end
