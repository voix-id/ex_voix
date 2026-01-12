[![0.3.6](https://img.shields.io/hexpm/v/ex_voix.svg)](https://hex.pm/packages/ex_voix)

# ExVoix

**Agentic Web implementation using Phoenix.LiveView**

## About VOIX framework and MCP-UI (The Core of ExVoix)

The VOIX framework is a new, web-native, declarative framework that allows website developers to explicitly define available actions and relevant data for AI agents using simple HTML elements. This approach aims to create a more efficient, secure, and privacy-preserving collaboration between humans and AI on the web. 

MCP-UI is an open-source standard and SDK that extends the basic MCP protocol, allowing AI agents to render rich, interactive web components (like forms, product selectors, maps) directly within chat interfaces or any app user interfaces, moving beyond text-only responses to create dynamic, rich UI / UX for complex tasks like shopping or booking.

## Core Concept

The primary challenge the VOIX framework addresses is the difficulty AI agents currently have in interpreting complex, human-oriented web interfaces. Existing methods often rely on visual interpretation or DOM parsing, which can be slow and unreliable. VOIX provides a machine-readable "contract" for agents, allowing them to understand a website's functionality without needing to visually interpret its design.

The collaboration between VOIX framework, MCP-UI and Phoenix LiveView will bring the powerful interaction between AI and human.  
The VOIX framework is displaying the capabilities of the website, informing to AI Agent what kind of actions can be done from website point of view. The MCP-UI will bring rich interaction to the AI Agent user, displaying Web UI as the resources of the website. And the phoenix framework is the underlying technologies that can bind all the components together.

## Key Features and Mechanics

Declarative HTML Elements: 
VOIX introduces two main HTML tags:

```pre
<tool>: Used by developers to define specific actions an AI agent can perform on the site, such as "add to cart" or "book a flight".

<context>: Used to explicitly provide relevant state or information to the agent, such as product details or current user status.
```

MCP and MCP-UI:
```
Model Context Protocol (MCP): The underlying system connecting AI agents to external tools and data, for this setup, the mcp will be running in the server side, bring more security to the user and the system.

MCP-UI: An extension to MCP, providing a way to send interactive UI elements.

UIResource: The core object defining the UI content (HTML, URL, Remote DOM) to be delivered and displayed.

Client SDK: How the UIResource will be delivered and displayed to the users by Phoenix LiveView and MCP-UI client renderer.
```

**Improved Performance:**
By eliminating the need for complex visual inference or repeated verification loops, VOIX enables immediate feedback and 
significantly reduces latency for AI agent tasks, making interactions feel instantaneous.

**Privacy and Security:**
The framework enhances user privacy by separating conversational AI interactions from the website itself, shifting control to the developer to specify exactly what information is shared with agents.

**Developer-Friendly:** 
Built on familiar web patterns and standard JavaScript event listeners, developers in an initial hackathon study found the framework easy to learn and use effectively.

**Accessibility:**
By providing a clear, non-visual description of website actions, the framework can also streamline web browsing and make it more accessible for users with visual impairments. 

## Status and Adoption
The VOIX framework is a recent research development from researchers at TU Darmstadt and is part of a movement toward the "Agentic Web," where new standards are needed to facilitate reliable AI interaction. While initial studies show promising results in its practicality and performance, its success ultimately depends on ecosystem-wide adoption and further standardization efforts. 

MCP-UI created by Ido Salomon and Liad Yosef, standardizes a mechanism for agents to embed user interfaces directly within the conversation flow or any UI flow, treating them as a first-class content type. The technology is highlighted when Shopify Engineering and Block publicly announce their support and implementation of MCP-UI to enable "agentic commerce" experiences.

## More Articles
* [Building the Web for Agents: A Declarative Framework for Agent-Web Interaction](https://huggingface.co/papers/2511.11287)
* [VOIX Framework Builds AI-Friendly Websites with Two New HTML Elements](https://winsomemarketing.com/ai-in-marketing/voix-framework-builds-ai-friendly-websites-with-two-new-html-elements)
* [The future of AI browsing may depend on developers rethinking how they build websites](https://the-decoder.com/the-future-of-ai-browsing-may-depend-on-developers-rethinking-how-they-build-websites/)
* [VOIX Documentation](https://svenschultze.github.io/VOIX/)
* [MCP-UI: The Future of Agentic Interfaces](https://block.github.io/goose/blog/2025/08/25/mcp-ui-future-agentic-interfaces/)

## Original Source Repository
* [VOIX Github](https://github.com/svenschultze/VOIX)
* [MCP-UI Github](https://github.com/MCP-UI-Org/mcp-ui)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_voix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_voix, "~> 0.3"}
  ]
end
```

## Integration Steps for Phoenix.LiveView Project (Required)
- Create Elixir Phoenix framework Project
- Add {:ex_voix, "~> x.x.x"} to your mix.exs, fill x.x.x with ex_voix latest version
- Add the client for your MCP Server by adding MCP Client inside your project, you can see how to do it from examples/todo_app in todo_app_mcp/clients/todo_app_mcp.ex file and register the file in application.ex or
  see the [Anubis MCP Client documentation](https://hexdocs.pm/anubis_mcp/building-a-client.html)
- Add below line in file ex: todo_app/lib/todo_app_web.ex
  ```elixir
  ...
  def live_view do
    quote do
      use Phoenix.LiveView
      import ExVoix.Html.Components # <- Add this line

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent
      import ExVoix.Html.Components # <- Add this line

      unquote(html_helpers())
    end
  end
  ...
  ```
- Add event handler when voix tool call is triggered, ex: todo_app/lib/todo_app_web/live/task_live/index.ex
  ```elixir
  ...
  @impl true
  def handle_event("call", params, socket) do
    case Tool.call(params) do
      nil ->
        {:noreply, socket}

      {:ok, res} ->
        {:noreply, tool_call_action(socket, res)}

    end
  end

  defp tool_call_action(socket, res) do
    if is_map(res) and not Map.get(res, "isError", true) do
      case Map.get(res, "tool") do
        "add_task" ->
          socket
            |> assign(:stats, stats())
            |> assign(:current_date, current_date())
            |> stream_insert(:tasks, maybe_extract_item(res))

        "complete_task" ->
          socket
            |> assign(:stats, stats())
            |> assign(:current_date, current_date())
            |> stream_insert(:tasks, maybe_extract_item(res))

        "remove_task" ->
          socket
            |> assign(:stats, stats())
            |> assign(:current_date, current_date())
            |> stream_delete(:tasks, maybe_extract_item(res))

        "show_stats_window" ->
          socket
            |> assign(:resource, res)
            |> push_patch(to: "/tasks/stats")

        _ ->
          socket |> execute_remote_code("#executable-script", res)

      end
    else
      tasks =
        Todos.list_tasks()
        |> Enum.map(fn t -> %{id: t.id, task: t} end)

      socket
        |> assign(:stats, stats())
        |> assign(:current_date, current_date())
        |> stream(:tasks, tasks, reset: true)
    end
  end
  ...
  ```
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
- Add @todo_mcp module in your liveview mount function
  ```elixir
    ...
    @impl true
    def mount(_params, _session, socket) do
      tasks =
        Todos.list_tasks()
        |> Enum.map(fn t -> %{id: t.id, task: t} end)

      {
        :ok,
        socket
        |> assign(:add_task_text, nil)
        |> assign(:stats, stats())
        |> assign(:current_date, current_date())
        |> assign(:resource, nil)
        |> assign(:todo_mcp, TodoAppMCP.Clients.TodoAppMCP)
        |> stream(:tasks, tasks)
      }
    end
    ...
  ```
- Add <.tool />, <.context /> and <.ui_resource_renderer /> element in heex template, ex: todo_app/lib/todo_app_web/live/task_live/index.html.heex
  ```html
    <div>
    ...
                <.tool mcp={@todo_mcp} name="complete_task" item_id={id} item_label={task.text} />
                <.tool mcp={@todo_mcp} name="remove_task" item_id={id} item_label={task.text} />

            </li>
        <% end %>
    </ul>
    <.context name="task_list" content={@stats} />
    <.context name="current_date" content={@current_date} />

    </form>
    </div>

    <.ui_resource_renderer id="executable_script" resource={@resource} />
    ...

  ```
- Start the phoenix server
  ```bash
  > mix phx.server
  ```

## mcp-ui client support for rendering raw-html, external-url or remote-dom from mcp-ui server (optional):
- Install mcp-ui client with npm or bun in assets directory for rendering mcp-ui in browser
  ```bash
  > cd assets

  > npm install @mcp-ui/client
  or
  > bun add @mcp-ui/client
  ```
- Add mcp ui client component and elements
  ```javascript
    // assets/js/app.js file
    ...
    import topbar from "../vendor/topbar"
    import VoixEventHandler from "../../deps/ex_voix/lib/ex_voix/js/voix_event_handler"

    import '@mcp-ui/client/ui-resource-renderer.wc.js';
    import { 
      basicComponentLibrary,
      remoteCardDefinition, 
      remoteButtonDefinition, 
      remoteTextDefinition, 
      remoteStackDefinition, 
      remoteImageDefinition,
    } from '@mcp-ui/client';
    // you can change below component definition with your own design
    import { defineWebComponents } from '../../deps/ex_voix/lib/ex_voix/js/mcp-ui-client/webcomponents';

    // declare Hooks
    let Hooks = {};
    Hooks.VoixEventHandler = VoixEventHandler;

    const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
    const liveSocket = new LiveSocket("/live", Socket, {
      longPollFallbackMs: 2500,
      params: {_csrf_token: csrfToken},
      hooks: {...Hooks, ...colocatedHooks}, // add Hooks to LiveSocket
    })

    // Prepare for MCP-UI render
    window.basicComponentLibrary = basicComponentLibrary
    window.remoteElements = [
      remoteCardDefinition, 
      remoteButtonDefinition, 
      remoteTextDefinition, 
      remoteStackDefinition, 
      remoteImageDefinition,
    ]
    defineWebComponents();
    ...
  ```
- Add `<ui-resource-renderer />` element in heex template, you can place the element anywhere in the template, place it where you want to render the content. Ex: todo_app/lib/todo_app_web/live/task_live/index.html.heex
  ```html
  ...
    <.modal
        :if={@live_action in [:stats]}
        id="popup-window"
        show
        on_cancel={JS.patch(~p"/tasks")}
    >
    <ui-resource-renderer id="remote-code-renderer" phx-hook='VoixEventHandler'></ui-resource-renderer>
    <.tool mcp={@todo_mcp} name="close_any_form" />
    </.modal>
  ...
  ```
- Restart the phoenix server

## More Examples and Demo
- FastMCP and MCP-UI integration ([here](https://github.com/onprem-vip/todo_mcp_ui))
- Demo site: [Voix and MCP-UI Demo](https://demo1.onprem.vip)

## License
Released under the MIT License.
