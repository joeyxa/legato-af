#*******************************************************************************
# Copyright (C) Sierra Wireless Inc.
#*******************************************************************************

mkapp(secStoreTest1a.adef)
mkapp(secStoreTest1b.adef)
mkapp(secStoreTest2.adef)
mkapp(secStoreTest2Global.adef)
mkapp(secStoreTestGlobal.adef)

if ($ENV{TARGET} MATCHES "localhost")
    add_subdirectory(secStoreUnitTest)
endif()

# This is a C test
add_dependencies(tests_c secStoreTest1a
                         secStoreTest1b
                         secStoreTest2
                         secStoreTest2Global
                         secStoreTestGlobal)
