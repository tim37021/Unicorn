import QtQuick 2.12

QtObject {
    function formatText(plainText) {
        let i = 0;
        let doc = ''
        let ret = []

        while(i < plainText.length) {
            let m = plainText.substr(i, 1)
            if(m[0].match(/\s/)) {

                if(m[0] === ' ')
                    doc += " ";
                else if(m[0] === '\t')
                    doc += "    ";
                else if(m[0] === '\n') {
                    // dump doc
                    if(doc !== '') ret.push({color: '#AAAAAA', text: doc})
                    ret.push({color: '#AAAAAA', text: '\n'})
                    doc = ''
                } else {
                    doc += m[0]
                }
                i++;

            } else {
                let f = plainText.slice(i).match(/[\S]+/)
                f = f[0]
                if(f[0] === '"' || f[0] === '\'') {
                    let m = f.match(/^["'][^'"]*["']/)
                    if(m) {
                        if(doc !== '') {
                            ret.push({color: '#AAAAAA', text: doc})
                            doc = ''
                        }
                        ret.push({color: '#00AA00', text: m[0]})
                        i+=m[0].length
                        continue
                    }
                }
                // match comment
                if(f.substr(0, 2) === '//') {
                    let m = plainText.slice(i).match(/^\/\/.*$/gm)
                    if(m) {
                        if(doc !== '') {
                            ret.push({color: '#AAAAAA', text: doc})
                            doc = ''
                        }
                        ret.push({color: '#0033AA', text: m[0]})
                        i+=m[0].length
                        continue
                    }
                }



                if(doc !== '') {
                    ret.push({color: '#AAAAAA', text: doc})
                    doc = ''
                }

                if(f.match(/^([+-]?\d|\w)/)) {
                    let m;
                    if (m=f.match(/^[A-Z][A-Z0-9a-z]*(\.\w*)*$/))
                    {ret.push({color: '#BB00BB', text: m[0], bold: true}); i += m[0].length}
                    else if (m=f.match(/^(true|false)$/))
                    {ret.push({color: '#0088BB', text: m[0], bold: true}); i += m[0].length}
                    else if (m=f.match(/^(property|alias|signal)$/))
                    {ret.push({color: '#AB00AB', text: m[0]}); i += m[0].length}
                    else if(m=f.match(/^(if|else|import)/))
                    {ret.push({color: '#28AAAA', text: m[0], bold: true}); i += m[0].length}
                    else if(m=f.match(/^on[A-Z][A-Z0-9a-z]*/))
                    {ret.push({color: '#808000', text: m[0], bold: true}); i += m[0].length}
                    else if(m=f.match(/^[a-z][A-Z0-9a-z]*/))
                    {ret.push({color: '#AAAAAA', text: m[0]}); i += m[0].length}
                    else if (m=f.match(/^[+-]?\d+(\.\d+)?/))
                    {ret.push({color: '#00AA00', text: m[0], bold: true}); i += m[0].length}
                    else
                    {ret.push({color: '#AAAAAA', text: f}); i+=f.length}
                } else {
                    doc += f[0]
                    i++;
                }
            }

        }

        if(doc !== '') {
            ret.push({color: '#AAAAAA', text: doc})
        }
        return ret

    }
}
