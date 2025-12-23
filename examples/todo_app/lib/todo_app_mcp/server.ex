defmodule TodoAppMCP.Server do
  use Anubis.Server,
    name: "TodoApp MCP Server",
    version: TodoAppMCP.version(),
    capabilities: [:tools]

  component(TodoAppMCP.Components.AddTask)
  component(TodoAppMCP.Components.UpdateTask)

  # def init(_client_info, frame) do
  #   # TODO:

  #   {:ok,frame}
  # end

end
