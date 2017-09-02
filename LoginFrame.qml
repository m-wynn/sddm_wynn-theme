import QtQuick 2.7
import QtGraphicalEffects 1.0
import SddmComponents 2.0
import QtQuick.Controls 2.0

Item {
    id: frame
    property int sessionIndex: sessionModel.lastIndex
    property string userName: userModel.lastUser
    property bool isProcessing: glowAnimation.running
    property alias input: passwdInput
    property alias button: loginButton

    Connections {
        target: sddm
        onLoginSucceeded: {
            glowAnimation.running = false
            Qt.quit()
        }
        onLoginFailed: {
            passwdInput.echoMode = TextInput.Normal
            passwdInput.text = textConstants.loginFailed
            passwdInput.focus = false
            passwdInput.color = "#e7b222"
            glowAnimation.running = false
        }
    }
    Item {
        anchors.fill: parent

        Item {
            id: layered
            opacity: 0.8
            layer.enabled: true
            anchors {
                centerIn: parent
                fill: parent
            }

            Rectangle {
                id: rec1
                width: parent.width / 3
                height: parent.height - 35
                anchors.centerIn: parent
                color: "#f0f0f0"
                radius: 2
            }

            DropShadow {
                id: drop
                anchors.fill: rec1
                source: rec1
                horizontalOffset: 0
                verticalOffset: 3
                radius: 10
                samples: 21
                color: "#55000000"
                transparentBorder: true
            }
        }
    }

    Item {
        id: loginItem
        anchors.centerIn: parent
        width: parent.width / 3 - 100
        height: parent.height

        UserAvatar {
            id: userIconRec
            anchors {
                top: parent.top
                topMargin: 50
                horizontalCenter: parent.horizontalCenter
            }
            width: 130
            height: 130
            source: userFrame.currentIconPath
            onClicked: {
                root.state = "stateUser"
                userFrame.focus = true
            }
        }
        Glow {
            id: avatarGlow
            anchors.fill: userIconRec
            radius: 0
            samples: 17
            color: "#99ffffff"
            source: userIconRec

            SequentialAnimation on radius {
                id: glowAnimation
                running: false
                alwaysRunToEnd: true
                loops: Animation.Infinite
                PropertyAnimation { to: 20 ; duration: 1000}
                PropertyAnimation { to: 0 ; duration: 1000}
            }
        }


        Text {
            id: userNameText
            anchors {
                top: userIconRec.bottom
                topMargin: 30
                horizontalCenter: parent.horizontalCenter
            }
            text: userName
            color: "#000000"
            font.pointSize: 15
        }

        TextField {
            id: passwdInput
            anchors {
                top: userNameText.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width
            clip: true
            color: config.accent2
            font.pointSize: 15
            selectByMouse: true
            selectionColor: "#a8d6ec"
            placeholderText: qsTr("Password")
            echoMode: TextInput.Password
            verticalAlignment: TextInput.AlignVCenter
            leftPadding: 2
            bottomPadding: 15
            cursorDelegate: Item {
                id: root

                property Item input: parent

                width: 3
                height: input.cursorRectangle.height
                visible: input.activeFocus && input.selectionStart === input.selectionEnd


                Rectangle {
                    width: 2
                    height: parent.height + 3
                    radius: width
                    color: config.accent2
                }

                Rectangle {
                    id: handle
                    x: -width/2 + parent.width/2
                    width: 2
                    height: width
                    radius: width
                    color: config.accent2
                    anchors.top: parent.bottom
                }
                MouseArea {
                    drag {
                        target: root
                        minimumX: 0
                        minimumY: 0
                        maximumX: input.width
                        maximumY: input.height - root.height
                    }
                    width: handle.width * 2
                    height: parent.height + handle.height
                    x: -width/2
                    onReleased: {
                        var pos = mapToItem(input, mouse.x, mouse.y);
                        input.cursorPosition = input.positionAt(pos.x, pos.y);
                    }
                }
            }
            background: Item {
                implicitHeight: 40
                Rectangle {
                    id: passback
                    anchors.fill: parent
                    anchors.bottomMargin: 5
                    opacity: 0
                }

                Rectangle {
                    id: passborder
                    anchors.bottom: passback.bottom
                    width: parent.width
                    height: 1
                    color: "#000000"
                }
                Rectangle {
                    id: passborderactive
                    anchors.bottom: passback.bottom
                    width: 0
                    height: 2
                    color: config.accent2
                }
            }
            onFocusChanged: {
                if (focus) {
                    color = config.accent2
                    echoMode = TextInput.Password
                    passborderactive.width = passborder.width
                    cursorVisible = true
                } else {
                    color = "#888888"
                    passborder.color = "#000000"
                    passborderactive.width = 0
                    cursorVisible = false
                }
            }

            onAccepted: {
                glowAnimation.running = true
                sddm.login(userNameText.text, passwdInput.text, sessionIndex)
            }
            KeyNavigation.backtab: {
                if (sessionButton.visible) {
                    return sessionButton
                }
                else if (userButton.visible) {
                    return userButton
                }
                else {
                    return shutdownButton
                }
            }
            KeyNavigation.tab: loginButton
            Timer {
                interval: 200
                running: true
                onTriggered: passwdInput.forceActiveFocus()
            }
        }

        Button {
            id: loginButton
            width: parent.width
            text: qsTr("LOG IN")
            highlighted: true
            background: Rectangle {
                color: config.accent2
                implicitHeight: 40
            }

            anchors {
                top: passwdInput.bottom
                topMargin: 30
                horizontalCenter: parent.horizontalCenter
                leftMargin: 8
                rightMargin: 8 + 36
            }

            KeyNavigation.tab: shutdownButton
            KeyNavigation.backtab: passwdInput
        }
        DropShadow {
            anchors.fill: loginButton
            horizontalOffset: 0
            verticalOffset: 1
            radius: 8.0
            samples: 17
            color: "#80000000"
            source: loginButton
        }
    }
}
