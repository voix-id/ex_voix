function decodeHtml(html) {
    var txt = document.createElement("textarea");
    txt.innerHTML = html;
    return txt.value;
}

window.voixHandler = null;

function handleEvent(event) {
    window.removeEventListener("call", handleEvent);
    if (window.voixHandler) {
        let ev = {tool_name: event.target.getAttribute('name'), detail: event.detail}
        window.voixHandler.pushEvent("call", ev)
    }
    addCallEventListener(window.voixHandler);
}

export function addCallEventListener(handlerObj) {
    window.voixHandler = handlerObj;
    window.addEventListener("call", handleEvent)
}

export function addResourceHandleEvent(handlerObj) {
    handlerObj.handleEvent("ui-resource-render", ({ to, resource }) => {
        // Find the target element(s) and execute the JS command stored in an attribute or render the element as a UI resource
        document.querySelectorAll(to).forEach(el => {
            if (!window.commandResourceHandler(resource, el)) {
                window.defaultResourceHandler(resource, el)
            }
        });
    });
}

// NOTE: user can override below Resource Handler
const voixCommandResourceHandler = (resource, element) => {
    if (resource && resource.mimeType == 'application/vnd.ex-voix.command+javascript; framework=liveviewjs') {
        let attr = element.getAttribute('value-js-code')
        if (attr) {
            liveSocket.execJS(element, attr);
        }
        return true;
    }
    return false;
}

const voixBaseResourceHandler = (resource, element) => {
    if (resource && (
        resource.mimeType == 'application/vnd.mcp-ui.remote-dom+javascript; framework=webcomponents' ||
        resource.mimeType == 'application/vnd.mcp-ui.remote-dom+javascript; framework=react' ||
        resource.mimeType == 'text/html' || resource.mimeType == 'text/uri-list'
    )) {
        element.resource = resource
        element.remoteDomProps = {library: window.basicComponentLibrary, remoteElements: window.remoteElements}
        element.htmlProps = {}

        element.addEventListener('onUIAction', (event) => {
            console.log('Action received:', event.detail);
            document.querySelectorAll('ui-text').forEach(ui_text => {
                let txt = ui_text.getAttribute('content');
                ui_text.setAttribute('content', decodeHtml(txt));
            })
        });
        return true;
    }
    return false;
}

const VoixEventHandler = {
    init(params = null) {
        let parameters = params;
        if (parameters == null) {
            parameters = {
                commandResourceHandler: voixCommandResourceHandler,
                baseResourceHandler: voixBaseResourceHandler
            }
        }
        window.voixHandler = null;
        window.commandResourceHandler = parameters.commandResourceHandler;
        window.defaultResourceHandler = parameters.baseResourceHandler;
    },
    mounted() {
        console.log("VoixEventHandler mounted")

        addCallEventListener(this);
        addResourceHandleEvent(this);
    },
    updated() {
        console.log("VoixEventHandler updated")
    }
}

export default VoixEventHandler;