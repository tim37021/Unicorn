import QtQuick 2.0

Item {
    id: container
    property string code
    property string message
    property ListModel error: ListModel {

    }

    onCodeChanged: {
        container.children = ""
        let lint = [] //linter.process(codeEd.code)
        let errorLines = []

        for(let x of lint) {
            let group = x.match(/[^:]+:(\d+).*/)
            if(group !== null)
                errorLines.push(group[1])
        }
        try{


            if(lint.length === 0) {
                let obj = Qt.createQmlObject(code, container, '.')
                obj.anchors.centerIn = container

                previewAnime.restart()
                message = ""
            } else {

                message = lint[0]
            }



        } catch(e) {
            message = e.toString().split('\n')[1].replace(/(^[ ]*|qrc:\/:)/g, '')
            errorLines = [message.match(/(\d+):/)[1]]
        }
    }

    NumberAnimation {
        id: previewAnime
        target: container
        properties: "opacity"
        from: 0
        to: 1
        duration: 300
    }
}

