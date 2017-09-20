#
set filespro=`ls -1 *.pro`
set filesh=''
#set filesh=`ls -1 *.h`
set chkDir='/pkg/rsi/local/libao/phil/was'
foreach file ($filespro $filesh)
	if (-e $chkDir/$file) then 
		echo "checking $file"
		diff -s $file $chkDir/$file
	endif
end
