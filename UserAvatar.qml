import QtQuick 2.2
import QtGraphicalEffects 1.0

Item {
    id: avatar
    property string source: ""
    signal clicked()

    Image {
        id: avatarImg
        source: parent.source
        width: parent.width
        height: parent.height
        fillMode: Image.PreserveAspectCrop
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: avatarMask
        }
    }

    Rectangle {
        id: avatarMask
        width: parent.width
        height: parent.height
        radius: parent.width / 2
        visible: false
    }

    Rectangle {
        id: avatarBorder
        width: parent.width
        height: parent.height
        radius: parent.width / 2
        color: "#00000000"
        border.width: 4
        border.color: "#ffffffff"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            avatarBorder.border.color = "#77ffffff"
        }
        onExited: {
            avatarBorder.border.color = "#ffffffff"
        }
        onClicked: avatar.clicked()
    }
}
