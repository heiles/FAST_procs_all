#
#set verbose
set files=($*)
set nargs=$#files
if   "$nargs" ==  "0"  then 
    set files=`ls *.pro`
endif
foreach i  ($files)
    if -e $i then   
        echo "expanding $i"
        expand -4 $i > junk
         mv junk $i
    else
        echo "$i doesn't exist"
    endif
end
