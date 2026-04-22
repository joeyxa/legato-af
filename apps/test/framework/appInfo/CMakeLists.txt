#*******************************************************************************
# Copyright (C) Sierra Wireless Inc.
#
# Contributors:
#     Sierra Wireless - initial API and implementation
#*******************************************************************************

mkapp(testAppInfo.adef
      -i ${LEGATO_ROOT}/interfaces/supervisor)

# This is a C test
add_dependencies(tests_c testAppInfo)
