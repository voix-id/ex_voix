const JsExecHandler = {
    async mounted() {
        console.log("JsExecHandler mounted")

        this.handleEvent("js-exec", ({ to, attr }) => {
            // Find the target element(s) and execute the JS command stored in an attribute
            document.querySelectorAll(to).forEach(el => {
                console.log(to, attr, el.getAttribute(attr));
                liveSocket.execJS(el, el.getAttribute(attr));
            });
        });
    }
}

export default JsExecHandler;