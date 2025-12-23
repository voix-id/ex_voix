defmodule TodoAppMCP.Components.UpdateTask do
  @moduledoc """
  Update a task from the list
  """

  use Anubis.Server.Component,
    type: :tool

  alias Anubis.Server.Response

  schema do
    field :id, :integer, required: true
    field :completed, :boolean
  end

  @impl true
  def description() do
    "Update task from the list"
  end

  @impl true
  def execute(_params, frame) do

    response = %{}
    {:reply, Response.tool() |> Response.json(response), frame}
  end
end
