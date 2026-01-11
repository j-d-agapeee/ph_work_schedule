cmake_minimum_required(VERSION 3.16)

project(ph_work_schedule VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Network)
find_package(Qt6 REQUIRED COMPONENTS Core)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appph_work_schedule
    main.cpp
)

qt_add_qml_module(appph_work_schedule
    URI ph_work_schedule
    QML_FILES
        Main.qml
        QML_FILES OverLay.qml
        SOURCES firebase.h firebase.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appph_work_schedule PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appph_work_schedule
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appph_work_schedule
    PRIVATE Qt6::Quick Qt6::Network
)
target_link_libraries(appph_work_schedule PRIVATE Qt6::Core)

include(GNUInstallDirs)
install(TARGETS appph_work_schedule
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
