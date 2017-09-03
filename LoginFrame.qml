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


        state: config.userName

        states: [
            State {
                name: "fill"
                PropertyChanges { target: userNameText; opacity: 0}
                PropertyChanges { target: userNameInput; opacity: 1}
            },
            State {
                name: "select"
                PropertyChanges { target: userNameText; opacity: 1}
                PropertyChanges { target: userNameInput; opacity: 0}
            }
        ]

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

        MaterialTextbox {
            id: userNameInput
            anchors {
                top: userIconRec.bottom
                topMargin: 30
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width
            placeholderText: qsTr("Username")
        }


        Text {
            id: userNameText
            anchors {
                top: userNameInput.top
                bottom: userNameInput.bottom
                horizontalCenter: parent.horizontalCenter
            }
            text: userName
            color: "#000000"
            font.pointSize: 15
        }

        MaterialTextbox{
            id: passwdInput
            anchors {
                top: userNameInput.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width
            placeholderText: qsTr("Password")
            echoMode: TextInput.Password
            onAccepted: {
                glowAnimation.running = true
                userName = userNameText.text
                if (config.userName == "fill") {
                    userName = userNameInput.text
                }
                sddm.login(userName, passwdInput.text, sessionIndex)
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
