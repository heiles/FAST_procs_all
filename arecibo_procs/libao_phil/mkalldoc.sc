#!/bin/bash
#
# make install
# calls this script to update all the documentation.
#
	idl << EOF
@phil
@geninit
@mkallidldoc
exit
EOF
