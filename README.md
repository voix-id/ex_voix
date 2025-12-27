# ExVoix

**VOIX framework implementation using Phoenix.LiveView**

## About VOIX framework

The VOIX framework is a new, web-native, declarative framework that allows website developers to explicitly define available actions and relevant data for AI agents using simple HTML elements. This approach aims to create a more efficient, secure, and privacy-preserving collaboration between humans and AI on the web. 

## Core Concept

The primary challenge the VOIX framework addresses is the difficulty AI agents currently have in interpreting complex, human-oriented web interfaces. Existing methods often rely on visual interpretation or DOM parsing, which can be slow and unreliable. VOIX provides a machine-readable "contract" for agents, allowing them to understand a website's functionality without needing to visually interpret its design. 

## Key Features and Mechanics

Declarative HTML Elements: 
OIX introduces two main HTML tags:

```pre
<tool>: Used by developers to define specific actions an AI agent can perform on the site, such as "add to cart" or "book a flight".

<context>: Used to explicitly provide relevant state or information to the agent, such as product details or current user status.
```

** Improved Performance: **
By eliminating the need for complex visual inference or repeated verification loops, VOIX enables immediate feedback and 
significantly reduces latency for AI agent tasks, making interactions feel instantaneous.

** Privacy and Security: **
The framework enhances user privacy by separating conversational AI interactions from the website itself, shifting control to the developer to specify exactly what information is shared with agents.

** Developer-Friendly: ** 
Built on familiar web patterns and standard JavaScript event listeners, developers in an initial hackathon study found the framework easy to learn and use effectively.

** Accessibility: **
By providing a clear, non-visual description of website actions, the framework can also streamline web browsing and make it more accessible for users with visual impairments. 

## Status and Adoption
The VOIX framework is a recent research development from researchers at TU Darmstadt and is part of a movement toward the "Agentic Web," where new standards are needed to facilitate reliable AI interaction. While initial studies show promising results in its practicality and performance, its success ultimately depends on ecosystem-wide adoption and further standardization efforts. 

## More Articles
* [Building the Web for Agents: A Declarative Framework for Agent-Web Interaction](https://huggingface.co/papers/2511.11287)
* [VOIX Framework Builds AI-Friendly Websites with Two New HTML Elements](https://winsomemarketing.com/ai-in-marketing/voix-framework-builds-ai-friendly-websites-with-two-new-html-elements)
* [The future of AI browsing may depend on developers rethinking how they build websites](https://the-decoder.com/the-future-of-ai-browsing-may-depend-on-developers-rethinking-how-they-build-websites/)
* [VOIX Documentation](https://svenschultze.github.io/VOIX/)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_voix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_voix, "~> 0.1.5"}
  ]
end
```

## Integration Steps for your Phoenix.LiveView Project
- Create Elixir Phoenix framework Project
- Add {:ex_voix, "~> x.x.x"} to your mix.exs, fill x.x.x with ex_voix latest version
- Add the client for your MCP Server by adding MCP Client inside your project, you can see how to do it from examples/todo_app or
  see the [Anubis MCP Client documentation](https://hexdocs.pm/anubis_mcp/building-a-client.html)
- Add voix_event_handler LiveView Hook, 
  ```javascript
    // assets/js/app.js file
    ...
    import topbar from "../vendor/topbar"
    import VoixEventHandler from "../../deps/ex_voix/lib/ex_voix/js/voix_event_handler"

    // declare Hooks
    let Hooks = {};
    Hooks.VoixEventHandler = VoixEventHandler;

    const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
    const liveSocket = new LiveSocket("/live", Socket, {
      longPollFallbackMs: 2500,
      params: {_csrf_token: csrfToken},
      hooks: {...Hooks, ...colocatedHooks}, // add Hooks to LiveSocket
    })
    ...
  ```
- Add <.tool /> or <.context /> element in heex template, ex: todo_app/todo_app_web/live/task_live/index.html.heex
  ```html
    ...
                <.tool mcp={@todo_mcp} name="complete_task" item_id={id} item_label={task.text} />
                <.tool mcp={@todo_mcp} name="remove_task" item_id={id} item_label={task.text} />

            </li>
        <% end %>
    </ul>
    <.context name="task_list" content={@stats} />
    ...

  ```

## License
Released under the MIT License.

