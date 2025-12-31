# ExVoix

**Agentic Web implementation using Phoenix.LiveView**

## About VOIX framework and MCP-UI (The Core of ExVoix)

The VOIX framework is a new, web-native, declarative framework that allows website developers to explicitly define available actions and relevant data for AI agents using simple HTML elements. This approach aims to create a more efficient, secure, and privacy-preserving collaboration between humans and AI on the web. 

MCP-UI is an open-source standard and SDK that extends the basic MCP protocol, allowing AI agents to render rich, interactive web components (like forms, product selectors, maps) directly within chat interfaces, moving beyond text-only responses to create dynamic, application-like experiences for complex tasks like shopping or booking.

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

Phoenix LiveView SDK: How the UIResource will be delivered and displayed to the users by Phoenix LiveView.
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

MCP-UI created by Ido Salomon and Liad Yosef, standardizes a mechanism for agents to embed user interfaces directly within the conversation flow, treating them as a first-class content type. The technology is highlighted when Shopify Engineering and Block publicly announce their support and implementation of MCP-UI to enable "agentic commerce" experiences.

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
    {:ex_voix, "~> 0.2"}
  ]
end
```

## Integration Steps for Phoenix.LiveView Project
- Create Elixir Phoenix framework Project
- Add {:ex_voix, "~> x.x.x"} to your mix.exs, fill x.x.x with ex_voix latest version
- Add the client for your MCP Server by adding MCP Client inside your project, you can see how to do it from examples/todo_app or
  see the [Anubis MCP Client documentation](https://hexdocs.pm/anubis_mcp/building-a-client.html)
- Add below line in file ex: todo_app/lib/todo_app_web.ex
  ```elixir
  ...
  def live_view do
    quote do
      use Phoenix.LiveView
      import ExVoix.Html.Components # -> Add this line

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent
      import ExVoix.Html.Components # -> Add this line

      unquote(html_helpers())
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
    import LvjsExecHandler from "../../deps/ex_voix/lib/ex_voix/js/lvjs_exec_handler"

    // declare Hooks
    let Hooks = {};
    Hooks.VoixEventHandler = VoixEventHandler;
    Hooks.LvjsExecHandler = LvjsExecHandler;

    const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
    const liveSocket = new LiveSocket("/live", Socket, {
      longPollFallbackMs: 2500,
      params: {_csrf_token: csrfToken},
      hooks: {...Hooks, ...colocatedHooks}, // add Hooks to LiveSocket
    })
    ...
  ```
- Add <.tool />, <.context /> and <.lvjsexec /> element in heex template, ex: todo_app/lib/todo_app_web/live/task_live/index.html.heex
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
    <.lvjsexec id="task_script" js_code={@code} />
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
        if not Map.get(res, "isError") do
          case Map.get(res, "tool") do
            "add_task" ->
              {:noreply,
                socket
                  |> assign(:stats, stats())
                  |> assign(:current_date, current_date())
                  |> stream_insert(:tasks, maybe_extract_item(res))}

            "complete_task" ->
              {:noreply,
                socket
                  |> assign(:stats, stats())
                  |> assign(:current_date, current_date())
                  |> stream_insert(:tasks, maybe_extract_item(res))}

            "remove_task" ->
              {:noreply,
                socket
                  |> assign(:stats, stats())
                  |> assign(:current_date, current_date())
                  |> stream_delete(:tasks, maybe_extract_item(res))}

            "show_update_task_form" ->
              IO.inspect(Map.get(res, "text"))
              socket =
                socket |> assign(:code, LvJs.eval(Map.get(res, "text")))

              payload = %{to: "#task_script", attr: "data-js-command"}
              {:noreply,
                socket
                |> push_event("lvjs-exec", payload)
              }

            "close_update_task_form" ->
              IO.inspect(Map.get(res, "text"))
              socket =
                socket |> assign(:code, LvJs.eval(Map.get(res, "text")))

              payload = %{to: "#update_task_script", attr: "data-js-command"}
              {:noreply,
                socket
                |> push_event("lvjs-exec", payload)
              }
          end          
        else
          tasks =
            Todos.list_tasks()
            |> Enum.map(fn t -> %{id: t.id, task: t} end)

          {:noreply,
            socket
              |> assign(:stats, stats())
              |> assign(:current_date, current_date())
              |> stream(:tasks, tasks, reset: true)
          }
        end
    end
  end
  ...
  ```

## More Examples
- FastMCP and MCP-UI integration ([here](https://github.com/onprem-vip/todo_mcp_ui))

## License
Released under the MIT License.
