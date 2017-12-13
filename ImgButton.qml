import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: button
    radius: 5
    color: focus ? "#33000000" : "transparent"
    width: 30
    height: 30
    property url normalImg: ""
    property url hoverImg: normalImg
    property url pressImg: normalImg
    property color normalColor: "transparent"
    property color hoverColor: normalColor
    property color pressColor: normalColor

    signal clicked()
    signal enterPressed()

    onNormalImgChanged: img.source = normalImg

    Image {
        id: img
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
    }
    
    ColorOverlay {
        id: imgOverlay
        anchors.fill: img
        source: img
        color: normalColor
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            img.source = hoverImg
            imgOverlay.color = hoverColor
        }
        onPressed: {
            img.source = pressImg
            imgOverlay.color = pressColor
        }
        onExited: {
            img.source = normalImg
            imgOverlay.color = normalColor
        }
        onReleased: {
            img.source = normalImg
            imgOverlay.color = normalColor
        }
        onClicked: button.clicked()
    }
    Component.onCompleted: {
        img.source = normalImg
        imgOverlay.color = normalColor
    }
    Keys.onPressed: {
        if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
            button.clicked()
            button.enterPressed()
        }
    }
}
