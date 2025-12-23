defmodule TodoAppMCP.Components.AddTask do
  @moduledoc """
  Add a new task to the list
  """

  use Anubis.Server.Component,
    type: :tool

  alias Anubis.Server.Response

  schema do
    field(:text, :string, required: true)
  end

  def execute(%{
    text: _text
  } = _params, frame) do

    response = %{}
    {:reply, Response.tool() |> Response.json(response), frame}
  end
end
