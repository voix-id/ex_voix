defmodule TodoAppMCP.Router do
  use TodoAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Anubis.Server.Transport do
    pipe_through :api

    forward "/", StreamableHTTP.Plug, server: TodoAppMCP.Server
  end
end
