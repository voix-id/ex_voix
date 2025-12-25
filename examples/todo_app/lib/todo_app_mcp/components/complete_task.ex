defmodule TodoAppMCP.Components.CompleteTask do
  @moduledoc """
  Mark task as complete
  """

  use Anubis.Server.Component,
    type: :tool

  alias Anubis.Server.Response

  schema do
    field :id, :integer, required: true
    field :completed, :boolean, description: "Is the task completed?"
  end

  @impl true
  def title() do
    "complete_task_<%= item_id %>"
  end

  @impl true
  def description() do
    "Mark task '<%= item_label %>' as complete"
  end

  @impl true
  def execute(_params, frame) do

    response = %{}
    {:reply, Response.tool() |> Response.json(response), frame}
  end
end
