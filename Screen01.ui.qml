import QtQuick 2.12
import test 1.0
import Qt.SafeRenderer 1.1
import QtQuick.Studio.Effects 1.0
import QtQuick.Controls 2.3
import QtWebEngine 1.8

Rectangle {
    id: rectangle
    width: Constants.width
    height: Constants.height

    color: Constants.backgroundColor

    Rectangle {
        id: background
        anchors.fill: parent
        color: Qt.rgba(41 / 255, 46 / 255, 52 / 255, 1.0)
    }

    Rectangle {
        x: 0
        y: richTextRenderer.cursorY
        width: richTextRenderer.width
        height: richTextRenderer.fm.height
        color: Qt.rgba(32 / 255, 32 / 255, 38 / 255)
    }

    RichTextRenderer {
        id: richTextRenderer
        width: parent.width - 10
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        onPreview: previewer.code = richTextRenderer.text
    }

    QMLSyntaxHighlighter {
        id: myhighlighter
    }

    QMLPreviewer {
        id: previewer
        anchors.centerIn: parent
    }

    Image {
        x: parent.width - width
        y: parent.height - height
        source: "images/logo.png"
        opacity: ma.containsMouse? 1: 0
        // @disable-check M224
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        MouseArea {
            id: ma
            hoverEnabled: true
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.IBeamCursor



        }
    }
}
