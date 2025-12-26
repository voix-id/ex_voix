defmodule TodoAppMCP.Components.CompleteTask do
  @moduledoc """
  Mark task as complete
  """

  use Anubis.Server.Component,
    type: :tool

  alias Anubis.Server.Response
  alias TodoApp.Todos

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
  def execute(%{
    id: id,
    completed: value
  } = _params, frame) do

    task = Todos.get_task!(id)
    {:ok, tsk} = Todos.update_task(task, %{"completed" => value})
    {:reply, Response.tool() |> Response.json(%{
      tool: "complete_task",
      item: tsk |> Jason.encode!()
    }), frame}
  end
end
