import QtQuick 2.7
import QtGraphicalEffects 1.0
import SddmComponents 2.0
import QtQuick.Controls 2.0

TextField {
    clip: true
    color: config.accent2
    font.family: config.font
    font.pointSize: 15
    selectByMouse: true
    selectionColor: "#a8d6ec"
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
            id: back
            anchors.fill: parent
            anchors.bottomMargin: 5
            opacity: 0
        }

        Rectangle {
            id: tborder
            anchors.bottom: back.bottom
            width: parent.width
            height: 1
            color: "#000000"
        }
        Rectangle {
            id: borderactive
            anchors.bottom: back.bottom
            width: 0
            height: 2
            color: config.accent2
        }
    }
    onFocusChanged: {
        if (focus) {
            color = config.accent2
            borderactive.width = tborder.width
            cursorVisible = true
        } else {
            color = "#888888"
            border.color = "#000000"
            borderactive.width = 0
            cursorVisible = false
        }
    }

}
