
const CodeRenderer = {
    async mounted() {
        console.log("CodeRenderer mounted")

        this.handleEvent("code-render", ({ to, resource }) => {
            // Find the target element(s) and execute the JS command stored in an attribute
            document.querySelectorAll(to).forEach(el => {
                el.resource = resource

                el.addEventListener('onUIAction', (event) => {
                    console.log('Action received:', event.detail);
                });
            });
        });
    }
}

export default CodeRenderer;