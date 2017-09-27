/***********************************************************************/

import QtQuick 2.7
import QtGraphicalEffects 1.0
import SddmComponents 2.0
import QtQuick.Controls 2.0


Rectangle {
    id: root
    width: 640
    height: 480
    state: "stateLogin"

    readonly property int hMargin: 24
    readonly property int vMargin: 30
    readonly property int buttonSize: 40

    TextConstants { id: textConstants }

    states: [
        State {
            name: "statePower"
            PropertyChanges { target: loginFrame; opacity: 0}
            PropertyChanges { target: powerFrame; opacity: 1}
            PropertyChanges { target: sessionFrame; opacity: 0}
            PropertyChanges { target: userFrame; opacity: 0}
            PropertyChanges { target: usageFrame; opacity: 0}
            PropertyChanges { target: bgBlur; radius: 30}
        },
        State {
            name: "stateSession"
            PropertyChanges { target: loginFrame; opacity: 0}
            PropertyChanges { target: powerFrame; opacity: 0}
            PropertyChanges { target: sessionFrame; opacity: 1}
            PropertyChanges { target: userFrame; opacity: 0}
            PropertyChanges { target: usageFrame; opacity: 0}
            PropertyChanges { target: bgBlur; radius: 30}
        },
        State {
            name: "stateUser"
            PropertyChanges { target: loginFrame; opacity: 0}
            PropertyChanges { target: powerFrame; opacity: 0}
            PropertyChanges { target: sessionFrame; opacity: 0}
            PropertyChanges { target: userFrame; opacity: 1}
            PropertyChanges { target: usageFrame; opacity: 0}
            PropertyChanges { target: bgBlur; radius: 30}
        },
        State {
            name: "stateLogin"
            PropertyChanges { target: loginFrame; opacity: 1}
            PropertyChanges { target: powerFrame; opacity: 0}
            PropertyChanges { target: sessionFrame; opacity: 0}
            PropertyChanges { target: userFrame; opacity: 0}
            PropertyChanges { target: usageFrame; opacity: 0}
            PropertyChanges { target: bgBlur; radius: 0}
        },
        State {
            name: "stateUsage"
            PropertyChanges { target: loginFrame; opacity: 0}
            PropertyChanges { target: powerFrame; opacity: 0}
            PropertyChanges { target: sessionFrame; opacity: 0}
            PropertyChanges { target: userFrame; opacity: 0}
            PropertyChanges { target: usageFrame; opacity: 1}
            PropertyChanges { target: bgBlur; radius: 30}
        }

    ]
    transitions: Transition {
        PropertyAnimation { duration: 100; properties: "opacity";  }
        PropertyAnimation { duration: 300; properties: "radius"; }
    }

    Repeater {
        model: screenModel
        Background {
            x: geometry.x; y: geometry.y; width: geometry.width; height:geometry.height
            source: config.default_background
            fillMode: Image.Tile
            onStatusChanged: {
                if (status == Image.Error && source !== config.default_background) {
                    source = config.default_background
                }
            }
        }
    }

    Item {
        id: mainFrame
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height

        Image {
            id: mainFrameBackground
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: config.default_background
        }

        FastBlur {
            id: bgBlur
            anchors.fill: mainFrameBackground
            source: mainFrameBackground
            radius: 0
        }

        Item {
            id: centerArea
            width: parent.width
            height: 430
            anchors {
                centerIn: parent
            }

            PowerFrame {
                id: powerFrame
                anchors.fill: parent
                enabled: root.state == "statePower"
                onNeedClose: {
                    root.state = "stateLogin"
                    loginFrame.input.forceActiveFocus()
                }
                onNeedShutdown: sddm.powerOff()
                onNeedRestart: sddm.reboot()
                onNeedSuspend: sddm.suspend()
            }

            SessionFrame {
                id: sessionFrame
                anchors.fill: parent
                enabled: root.state == "stateSession"
                onSelected: {
                    root.state = "stateLogin"
                    loginFrame.sessionIndex = index
                    loginFrame.passwdInput.forceActiveFocus()
                }
                onNeedClose: {
                    root.state = "stateLogin"
                    loginFrame.passwdInput.forceActiveFocus()
                }
            }

            UserFrame {
                id: userFrame
                anchors.fill: parent
                enabled: root.state == "stateUser"
                onSelected: {
                    root.state = "stateLogin"
                    loginFrame.userName = userName
                    loginFrame.input.forceActiveFocus()
                }
                onNeedClose: {
                    root.state = "stateLogin"
                    loginFrame.input.forceActiveFocus()
                }
            }

            LoginFrame {
                id: loginFrame
                anchors.fill: parent
                enabled: root.state == "stateLogin"
                opacity: 0
                transformOrigin: Item.Top
            }

            UsageFrame {
                id: usageFrame
                anchors.fill: parent
                enabled: root.state == "usageFrame"
                opacity: 0
                transformOrigin: Item.Top
            }
        }

        Rectangle {
            id: topArea
            anchors {
                top: parent.top
                left: parent.left
            }
            width: parent.width
            height: 64
            color: config.accent1

            Label {
                id: hostnameText
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: hMargin
                }

                font.pointSize: 16

                text: sddm.hostName ? sddm.hostName : "hostname"
            }

            Item {
                id: timeArea
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width / 3
                height: parent.height

                Label {
                    id: timeText
                    anchors {
                        centerIn: parent
                    }

                    font.pointSize: 16

                    function updateTime() {
                        text = new Date().toLocaleString(Qt.locale("en_US"), "hh:mm:ss")
                    }
                }

                Timer {
                    interval: 1000
                    repeat: true
                    running: true
                    onTriggered: {
                        timeText.updateTime()
                    }
                }

                Component.onCompleted: {
                    timeText.updateTime()
                }
            }

            Item {
                id: powerArea
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
                width: parent.width / 3
                height: parent.height

                Row {
                    spacing: 20
                    anchors.right: parent.right
                    anchors.rightMargin: hMargin
                    anchors.verticalCenter: parent.verticalCenter

                    state: config.user_name

                    states: [
                        State {
                            name: "fill"
                            PropertyChanges { target: userButton; width: 0}
                        },
                        State {
                            name: "select"
                            PropertyChanges { target: userButton; opacity: 1}
                        }
                    ]


                    ImgButton {
                        id: sessionButton
                        width: buttonSize
                        height: buttonSize
                        visible: sessionFrame.isMultipleSessions()
                        normalImg: "icons/switchframe/session.png"
                        pressImg: "icons/switchframe/session_focus.png"
                        onClicked: {
                            root.state = "stateSession"
                            sessionFrame.focus = true
                        }
                        onEnterPressed: sessionFrame.currentItem.forceActiveFocus()

                        KeyNavigation.tab: loginFrame.input
                        KeyNavigation.backtab: {
                            if (userButton.visible) {
                                return userButton
                            }
                            else {
                                return shutdownButton
                            }
                        }
                    }

                    ImgButton {
                        id: userButton
                        width: buttonSize
                        height: buttonSize
                        visible: userFrame.isMultipleUsers()

                        normalImg: "icons/switchframe/user.png"
                        pressImg: "icons/switchframe/user_focus.png"
                        onClicked: {
                            root.state = "stateUser"
                            userFrame.focus = true
                        }
                        onEnterPressed: userFrame.currentItem.forceActiveFocus()
                        KeyNavigation.backtab: shutdownButton
                        KeyNavigation.tab: {
                            if (sessionButton.visible) {
                                return sessionButton
                            }
                            else {
                                return loginFrame.input
                            }
                        }
                    }

                    ImgButton {
                        id: shutdownButton
                        width: buttonSize
                        height: buttonSize
                        visible: sddm.canPowerOff ? sddm.canPowerOff : "true"

                        normalImg: "icons/switchframe/powermenu.png"
                        pressImg: "icons/switchframe/powermenu_focus.png"
                        onClicked: {
                            root.state = "statePower"
                            powerFrame.focus = true
                        }
                        onEnterPressed: powerFrame.shutdown.focus = true
                        KeyNavigation.backtab: loginFrame.button
                        KeyNavigation.tab: {
                            if (userButton.visible) {
                                return userButton
                            }
                            else if (sessionButton.visible) {
                                return sessionButton
                            }
                            else {
                                return loginFrame.input
                            }
                        }
                    }
                }
            }

        }
        DropShadow {
            anchors.fill: topArea
            horizontalOffset: 0
            verticalOffset: 0
            radius: 8.0
            samples: 17
            color: "#80000000"
            source: topArea
        }

        MouseArea {
            z: -1
            anchors.fill: parent
            onClicked: {
                root.state = "stateLogin"
                loginFrame.input.forceActiveFocus()
            }
        }

        Button {
            id: aupButton
            width: 200
            text: qsTr("Acceptable Use Policy")
            highlighted: true
            background: Rectangle {
                id: aupButtonBack
                color: config.accent2
                implicitHeight: 40
            }

            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            onClicked: {
                root.state = "stateUsage"
            }

            onFocusChanged: {
                if (focus) {
                    aupButtonBack.color = config.accent2_hover
                } else {
                    aupButtonBack.color = config.accent2
                }
            }

            Component.onCompleted: {
                if (!config.aup) {
                    height = 0
                }
            }
        }

        DropShadow {
            id: aupButtonShadow
            anchors.fill: aupButton
            horizontalOffset: 0
            verticalOffset: 1
            radius: 8.0
            samples: 17
            color: "#80000000"
            source: aupButton
        }
    }
}
