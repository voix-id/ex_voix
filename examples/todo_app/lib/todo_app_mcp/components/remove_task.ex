defmodule TodoAppMCP.Components.RemoveTask do
  @moduledoc """
  Remove task from the list
  """

  use Anubis.Server.Component,
    type: :tool

  alias Anubis.Server.Response
  alias TodoApp.Todos

  schema do
    field :id, :integer, required: true
  end

  @impl true
  def title() do
    "remove_task_<%= item_id %>"
  end

  @impl true
  def description() do
    "Remove task '<%= item_label %>' from the list"
  end

  @impl true
  def execute(%{
    id: id
  } = _params, frame) do

    task = Todos.get_task!(id)
    {:ok, tsk} = Todos.delete_task(task)
    {:reply, Response.tool() |> Response.json(%{
      tool: "remove_task",
      item: tsk |> Jason.encode!()
    }), frame}
  end
end
