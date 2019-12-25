qt5_add_resources(voicememo_SRCS resources.qrc)
add_executable(voicememo recordingmodel.cpp utils.cpp main.cpp ${voicememo_SRCS})
target_link_libraries(voicememo Qt5::Core Qt5::Gui Qt5::Qml Qt5::Quick Qt5::Widgets Qt5::QuickControls2 Qt5::Multimedia KF5::I18n)
install(TARGETS voicememo ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})
