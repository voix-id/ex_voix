function decodeHtml(html) {
    var txt = document.createElement("textarea");
    txt.innerHTML = html;
    return txt.value;
}

let handler;

function handleEvent(event) {
    window.removeEventListener("call", handleEvent);
    if (handler) {
        let ev = {tool_name: event.target.getAttribute('name'), detail: event.detail}
        handler.pushEvent("call", ev)
    }
    addCallEventListener();
}

export function addCallEventListener() {
    window.addEventListener("call", handleEvent)
}

export function handleCommandLvJS(resource, element) {
    if (resource && resource.mimeType == 'application/vnd.ex-voix.command+javascript; framework=liveviewjs') {
        let attr = element.getAttribute('value-js-code')
        if (attr) {
            liveSocket.execJS(element, attr);
        }
        return true;
    }
    return false;
}

const VoixEventHandler = {
    init() {
        handler = this;
    },
    mounted() {
        console.log("VoixEventHandler mounted")

        addCallEventListener();

        this.handleEvent("ui-resource-render", ({ to, resource }) => {
            // Find the target element(s) and execute the JS command stored in an attribute or render the element as a UI resource
            document.querySelectorAll(to).forEach(el => {
                if (!handleCommandLvJS(resource, el)) {
                    if (resource && (
                        resource.mimeType == 'application/vnd.mcp-ui.remote-dom+javascript; framework=webcomponents' ||
                        resource.mimeType == 'application/vnd.mcp-ui.remote-dom+javascript; framework=react' ||
                        resource.mimeType == 'text/html' || resource.mimeType == 'text/uri-list'
                    )) {
                        el.resource = resource
                        el.remoteDomProps = {library: basicComponentLibrary, remoteElements: remoteElements}
                        el.htmlProps = {}

                        el.addEventListener('onUIAction', (event) => {
                            console.log('Action received:', event.detail);
                            document.querySelectorAll('ui-text').forEach(ui_text => {
                                let txt = ui_text.getAttribute('content');
                                ui_text.setAttribute('content', decodeHtml(txt));
                            })
                        });
                    }
                }
            });
        });

    },
    updated() {
        console.log("VoixEventHandler updated")
    }
}

export default VoixEventHandler;