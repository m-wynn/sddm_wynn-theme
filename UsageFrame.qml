import QtQuick 2.7
import QtGraphicalEffects 1.0
import SddmComponents 2.0
import QtQuick.Controls 2.0

Item {
    id: frame

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
                width: parent.width / 2
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
        anchors.fill: parent
        Text {
            id: aupTitle
            anchors {
                top: parent.top
                topMargin: 50
                horizontalCenter: parent.horizontalCenter
            }
            text: "Acceptable Use Policy"
            color: "#000000"
            font {
                pointSize: 18
                bold: true
                family: config.font
            }
            wrapMode: Text.Wrap
        }
        Text {
            id: aupText
            width: (parent.width / 2) - 20
            anchors {
                top: aupTitle.top
                topMargin: 50
                horizontalCenter: parent.horizontalCenter
            }
            text: config.aup != null ? config.aup : "No Acceptable Use Policy Defined"
            color: "#000000"
            font.family: config.font
            font.pointSize: 15
            wrapMode: Text.Wrap
        }
    }
}
