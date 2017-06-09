import QtQuick 2.0

Rectangle {
    id: button
    width: parent.width
    height: 30
    property string textContent: "hello"
    property color normalColor: "#000000"
    property color hoverColor: normalColor
    property color pressColor: normalColor
    property color textColor: "#ffffff"

    signal clicked()
    signal enterPressed()

    onNormalColorChanged: color = normalColor

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: color = hoverColor
        onPressed: color = pressColor
        onExited: color = normalColor
        onReleased: color = normalColor
        onClicked: button.clicked()
    }
    Component.onCompleted: {
        color = normalColor
    }
    Keys.onPressed: {
        if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
            button.clicked()
            button.enterPressed()
        }
    }
    Text {
        anchors.centerIn: parent
        font.pointSize: 12
        text: textContent
        color: textColor
    }
}
