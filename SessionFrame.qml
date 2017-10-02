import QtQuick 2.7
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.0

Item {
    id: frame
    signal selected(var index)
    signal needClose()

    property bool shouldShowBG: true
    property alias currentItem: sessionList.currentItem

    function isMultipleSessions() {
        return sessionList.count > 1
    }

    onFocusChanged: {
        // Active by mouse click
        if (focus) {
            sessionList.currentItem.focus = false
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

    Text {
        id: sessionTitle
        anchors {
            top: parent.top
            topMargin: 50
            horizontalCenter: parent.horizontalCenter
        }
        text: "Session"
        color: "#000000"
        font {
            pointSize: 18
            bold: true
        }
        wrapMode: Text.Wrap
    }
    ListView {
        id: sessionList
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: sessionTitle.bottom
        width: parent.width / 3
        clip: true
        height: parent.height - 100
        model: sessionModel
        currentIndex: sessionModel.lastIndex
        orientation: ListView.Vertical
        spacing: 5
        delegate: Button {
            property bool activeBG: sessionList.currentIndex === index && shouldShowBG

            background: Rectangle {
                color: activeBG || focus ? "#55000000" : "transparent"
                border.width: 3
                border.color: activeBG || focus ? "#33ffffff" : "transparent"
            }

            width: parent.width
            height: 35

            Text {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: name
                font.pointSize: 15
                color: "black"
                wrapMode: Text.WordWrap
            }

            Keys.onLeftPressed: {
                sessionList.decrementCurrentIndex()
                sessionList.currentItem.forceActiveFocus()
            }
            Keys.onRightPressed: {
                sessionList.incrementCurrentIndex()
                sessionList.currentItem.forceActiveFocus()
            }
            Keys.onEscapePressed: needClose()
            Keys.onEnterPressed: {
                selected(index)
                sessionList.currentIndex = index
            }
            Keys.onReturnPressed: {
                selected(index)
                sessionList.currentIndex = index
            }
            onClicked: {
                selected(index)
                sessionList.currentIndex = index
            }
        }
        ScrollBar.vertical: ScrollBar {
            parent: sessionList.parent
            anchors.top: sessionList.top
            anchors.left: sessionList.right
            anchors.bottom: sessionList.bottom
        }
    }

    MouseArea {
        z: -1
        anchors.fill: parent
        onClicked: needClose()
    }

    Keys.onEscapePressed: needClose()
}
