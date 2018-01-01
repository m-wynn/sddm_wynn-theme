import QtQuick 2.7
import QtGraphicalEffects 1.0
import SddmComponents 2.0
import QtQuick.Controls 2.0

Item {
    id: frame
    property int sessionIndex: find_list(sessionModel, config.default_session)
    property string userName: userModel.lastUser
    property alias input: userNameInput
    property alias passwdInput: passwdInput
    property alias button: loginButton
    function find_list(haystack, needle) {
        var i;
        for (i = 0; i < sessionModel.rowCount(); i++) {
            var file = sessionModel.data(sessionModel.index(i,0), 258)
            var name = file.substring(file.lastIndexOf('/')+1, file.lastIndexOf('.'))
            if(name.toLowerCase() == needle.toLowerCase()) {
                return i
            }
        }

        if (sessionModel.lastIndex >= 0 && sessionModel.lastIndex < sessionModel.rowCount() ) {
            return sessionModel.lastIndex
        }
        else {
            return 0
        }
    }

    Connections {
        target: sddm
        onLoginSucceeded: {
            spinner.running = false
            Qt.quit()
        }
        onLoginFailed: {
            loginButton.text = textConstants.loginFailed
            passwdInput.text = ""
            loginButtonBack.color = "#f44336"
            spinner.running = false
            loginFailed.running = true

        }
    }
    Timer {
        id: loginFailed;
        interval: 5000;
        running: false;
        repeat: false;
        onTriggered: {
            loginButton.text = qsTr("LOG IN")
            loginButtonBack.color = config.accent2
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


        state: config.user_name

        states: [
            State {
                name: "fill"
                PropertyChanges { target: userNameText; visible: false}
                PropertyChanges { target: userNameInput; visible: true}
                PropertyChanges { target: userIconRec; source: config.logo }
            },
            State {
                name: "select"
                PropertyChanges { target: userNameText; visible: true}
                PropertyChanges { target: userNameInput; visible: false}
                PropertyChanges { target: userIconRec; source: userFrame.currentIconPath }
            }
        ]

        BusyIndicator {
            id: spinner
            running: false
            visible: running
            anchors {
                top: parent.top
                topMargin: 40
                horizontalCenter: parent.horizontalCenter
            }
            width: 150
            height: 150
            contentItem: Item {
                id: spinning_item
                implicitWidth: spinner.width
                implicitHeight: spinner.height
                ConicalGradient {
                    id: borderFill
                    anchors.fill: parent
                    property double start: 0.1
                    property double end: 0.9
                    gradient: Gradient {
                        GradientStop { position: borderFill.start; color: "#00ffffff" }
                        GradientStop { position: borderFill.start + 0.1; color: config.accent2 }
                        GradientStop { position: borderFill.end - 0.1; color: config.accent2 }
                        GradientStop { position: borderFill.end; color: "#00ffffff" }
                    }
                    visible: false
                }

                RotationAnimator {
                    target: spinning_item
                    running: spinner.visible && spinner.running
                    from: 0
                    to: 360
                    loops: Animation.Infinite
                    duration: 1250
                }
                Rectangle {
                    id: mask
                    radius: 150/2
                    border.width: 5
                    anchors.fill: parent
                    color: 'transparent'
                    visible: false
                }
                OpacityMask {
                    id: opm
                    anchors.fill: parent
                    source: borderFill
                    maskSource: mask
                }
            }
        }

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
                if (config.user_name == "select") {
                    root.state = "stateUser"
                    userFrame.focus = true
                }
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
            focus: config.user_name == "fill"

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
            KeyNavigation.tab: passwdInput

            onFocusChanged: {
                if (!focus) {
                    if (config.session_api != null) {
                        var url = config.session_api.replace("%s", text)
                        var xhr = new XMLHttpRequest();
                        xhr.onreadystatechange = function() {
                            if (xhr.readyState == 4 && xhr.status == 200) {
                                var session = xhr.responseText
                                if (session == 'N'){
                                    sessionIndex = find_list(sessionModel, config.default_session)
                                } else if (session != null) {
                                    sessionIndex = find_list(sessionModel, session)
                                }
                            }
                        }
                        xhr.open('GET', url, true)
                        xhr.send('')
                    }
                }
            }
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
            font.family: config.font
            font.pointSize: 15
        }

        MaterialTextbox{
            id: passwdInput
            anchors {
                top: userNameInput.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            focus: config.user_name == "select"
            width: parent.width
            placeholderText: qsTr("Password")
            echoMode: TextInput.Password
            onAccepted: {
                spinner.running = true
                userName = userNameText.text
                if (config.user_name == "fill") {
                    userName = userNameInput.text
                }
                sddm.login(userName, passwdInput.text, sessionIndex)
            }
            KeyNavigation.backtab: {
                if (userNameInput.visible) {
                    return userNameInput
                }
                else if (sessionButton.visible) {
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
                id: loginButtonBack
                color: config.accent2
                implicitHeight: 40
            }

            font.family: config.font

            anchors {
                top: passwdInput.bottom
                topMargin: 30
                horizontalCenter: parent.horizontalCenter
                leftMargin: 8
                rightMargin: 8 + 36
            }
            onClicked: {
                spinner.running = true
                userName = userNameText.text
                if (config.user_name == "fill") {
                    userName = userNameInput.text
                }
                sddm.login(userName, passwdInput.text, sessionIndex)
            }

            Keys.onPressed: if (event.key === Qt.Key_Return) {
                spinner.running = true
                userName = userNameText.text
                if (config.user_name == "fill") {
                    userName = userNameInput.text
                }
                sddm.login(userName, passwdInput.text, sessionIndex)
            }

            onFocusChanged: {
                // Changing the radius here may make sddm 0.15 segfault
                if (focus) {
                    loginButtonShadow.verticalOffset = 2
                    loginButtonBack.color = config.accent2_hover
                } else {
                    loginButtonShadow.verticalOffset = 1
                    loginButtonBack.color = config.accent2
                }
            }

            KeyNavigation.tab: userNameInput
            KeyNavigation.backtab: passwdInput
        }
        DropShadow {
            id: loginButtonShadow
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
