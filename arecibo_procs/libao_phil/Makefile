#
# 
# make file to install phil's idl routines in /pkg/rsi/local/lib/phil
#
DEST=/pkg/rsi/local/libao/phil
#DEST=/tmp/phil
all:

install: FORCE
	echo "copying files"
	rsync -avzC . ${DEST}
	echo "Use make doc to rebuild documentation"
doc: FORCE
	echo "Rebuilding documentation"
	mkalldoc.sc
FORCE:

