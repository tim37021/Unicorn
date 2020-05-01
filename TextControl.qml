import QtQuick 2.12

Item {
    id: root
    property string text: ''
    property int cursorPosition: 0
    property bool insertMode: true

    onCursorPositionChanged: {
        // make sure cursorPosition is within [0, len]
        cursorPosition = Math.max(cursorPosition, 0)
        cursorPosition = Math.min(cursorPosition, text.length)
    }

    function insert(str) {
        text = text.slice(0, cursorPosition) + str + text.slice(cursorPosition)
        cursorPosition += str.length
    }

    function replace(str) {
        if(cursorPosition === text.length || text[cursorPosition] === '\n') {
            text = text.slice(0, cursorPosition) + str + text.slice(cursorPosition)
            cursorPosition += str.length
        } else {
            text = text.substr(0, cursorPosition) + str + text.slice(cursorPosition+str.length)
            cursorPosition += str.length
        }
    }

    function remove() {
        text = text.slice(0, cursorPosition) + text.slice(cursorPosition+1)
    }

    function backremove() {
        text = text.slice(0, cursorPosition-1) + text.slice(cursorPosition)
        cursorPosition --
    }

    function home() {

        let t = text.substr(0, cursorPosition).lastIndexOf('\n')
        if(t === -1)
            cursorPosition = 0
        else
            cursorPosition -= cursorPosition - t - 1
    }

    function end() {

        let t = text.slice(cursorPosition).indexOf('\n')
        if(t === -1)
            cursorPosition = text.length
        else
            cursorPosition += t
    }


    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Backspace:
            backremove(); break
        case Qt.Key_Return:
            insert('\n'); break
        case Qt.Key_Home:
            home(); break
        case Qt.Key_End:
            end(); break
        case Qt.Key_Delete:
            remove(); break
        case Qt.Key_Insert:
            insertMode = !insertMode; break

        default:
            if(insertMode)
                insert(event.text.replace('\t', '    '))
            else
                replace(event.text.replace('\t', '    '))
        }



    }
}
