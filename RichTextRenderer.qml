import QtQuick 2.12
import QtWebEngine 1.8

Canvas {
    id: root

    signal hoverProviderTriggered(string text)
    property alias text: tc.text
    property alias cursorPosition: tc.cursorPosition
    property int cursorX: 0
    property int cursorY: 0
    property var textDocument: []
    property alias fm: fontMetrics
    focus: true

    signal preview()

    onCursorPositionChanged: {
        let c = text.slice(0, cursorPosition).split('\n')
        cursorX = fontMetrics.advanceWidth(c[c.length-1])
        cursorY = fontMetrics.height * (c.length-1)
    }

    onTextChanged: {
        previewTimer.restart()

        textDocument = highlighter.formatText(text)
        requestPaint()
    }

    Timer {
        id: previewTimer
        interval: 500
        onTriggered: root.preview()
    }


    TextControl {
        id: tc

    }

    QMLSyntaxHighlighter {
        id: highlighter

    }

    FontMetrics {
        id: fontMetrics
        font.pointSize: 11
        font.family: "Consolas"
    }

    QtObject {
        id: priv
        property var data: []
        property var lineData: []

        function bsearch(arr, key, cmp) {
            let p = 0
            let q = arr.length
            let mid;
            while(q-p>1) {
                mid = Math.floor((p+q) / 2)
                if(cmp(arr[mid], key))
                    p = mid
                else
                    q = mid
            }
            return p
        }

        function calcCursor(idx, pos) {
            if(textDocument.length>0) {
                let the_text = textDocument[idx].text

                cursorX = data[idx].x + fontMetrics.advanceWidth(the_text.substr(0, pos)+(pos===the_text.length?'G':''))
                cursorY = data[idx].y
                // no binding loop if calculated correctly
                cursorPosition = data[idx].position + pos
            } else {
                cursorX = fontMetrics.advanceWidth(text.substr(0, pos)+(pos===text.length?'G': ''))
                cursorY = 0
                cursorPosition = pos
            }
        }

        function text_bsearch(font_metrics, text, target_w) {
            let p = 0
            let q = text.length
            let mid
            while(q-p>1) {
                mid = Math.floor((p+q) / 2)

                if(font_metrics.advanceWidth(text.substr(0, mid)) <= target_w) {
                    p = mid
                } else
                    q = mid

            }
            return p
        }
    }

    Rectangle {
        id: cursorRect
        x: cursorX
        y: cursorY
        width: fontMetrics.advanceWidth('g')
        height: fontMetrics.height
        opacity: 0.5
    }

    onPaint: {
        let ctx = this.getContext('2d')
        ctx.clearRect(0, 0, width, height)
        ctx.textBaseline = "top"

        ctx.font = "11pt Consolas"



        let dx = 0, dy = 0;
        priv.data = []
        priv.lineData = []
        let text_pos = 0
        let new_line = true
        for(let i=0; i<textDocument.length; i++) {
            priv.data.push({position: text_pos, x: dx, y: dy})
            text_pos += textDocument[i].text.length
            if(textDocument[i].text === '\n') {
                dx = 0
                dy += fontMetrics.height
                priv.lineData.push(i)
                continue
            }
            if(textDocument[i].bold)
                ctx.font = "bold 11pt Consolas"
            else
                ctx.font = "11pt Consolas"

            ctx.fillStyle = textDocument[i].color


            ctx.fillText(textDocument[i].text, dx, dy)
            new_line = false


            dx+=ctx.measureText(textDocument[i].text).width
        }
    }

    Keys.onPressed: {
        tc.Keys.pressed(event)
        event.accepted = true
    }

    Keys.onUpPressed: {
        // measure font metrics

        let c = text.substr(0, cursorPosition).split('\n')
        if(c.length>=2) {

            let target = fontMetrics.advanceWidth(c[c.length-1])
            let p = priv.text_bsearch(fontMetrics, c[c.length-2], target)
            cursorPosition -= (c[c.length-2].length-p)+1+c[c.length-1].length
        }
    }

    Keys.onDownPressed: {
        // measure font metrics

        let c = text.slice(cursorPosition).split('\n')

        let l = text.substr(0, cursorPosition).lastIndexOf('\n')
        if(l === -1)
            l = 0
        let c0 = text.substr(l, cursorPosition-l)
        if(c.length>=2) {

            let target = fontMetrics.advanceWidth(c0)
            let p = priv.text_bsearch(fontMetrics, c[1], target)

            cursorPosition += c[0].length + p + 1
        }
    }


    Keys.onRightPressed: {
        cursorPosition++
    }

    Keys.onLeftPressed: {
        cursorPosition--
    }


    function hitTest(x, y) {
        let closest;
        for(let i=0; i<textDocument.length; i++) {
            if(y>=priv.data[i].y && y<=priv.data[i].y+fontMetrics.height) {
                if(x>=priv.data[i].x && x<=priv.data[i].x+fontMetrics.advanceWidth(textDocument[i].text))
                    return [i, Math.floor((x-priv.data[i].x)/fontMetrics.advanceWidth(' '))]
                closest = [i, 0]
            }
        }
        return closest

    }


    MouseArea {
        id: ma
        anchors.fill: parent
        //hoverEnabled: true
        cursorShape: Qt.IBeamCursor
        onClicked: {
            let pos = hitTest(mouse.x, mouse.y)
            if(pos)
                priv.calcCursor(...pos)
            focus = true
        }
/*
        onPositionChanged: {
            hoverProviderTimer.restart()
        }

        Timer {
            id: hoverProviderTimer
            interval: 500

            onTriggered: {
                let ret = hitTest(ma.mouseX, ma.mouseY)
                if(ret) {
                    root.hoverProviderTriggered(textDocument[ret[0]].text)
                    textDocument[ret[0]].bold = 'true'
                    root.requestPaint()
                }
            }
        }
        */

    }


}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
