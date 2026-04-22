#*******************************************************************************
# Copyright (C) Sierra Wireless Inc.
#
# Contributors:
#     Sierra Wireless - initial API and implementation
#*******************************************************************************

mkapp(installStatusTest.adef)

mkapp(testApp1.adef)
mkapp(testApp2.adef)

# This is a C test
add_dependencies(tests_c installStatusTest testApp1 testApp2)
