#
set files=`ls *.pro`
foreach i  ($files)
    echo "expanding $i"
    expand -4 $i > junk
    mv junk $i
end
