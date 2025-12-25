defmodule TodoAppMCP.Components.AddTask do
  @moduledoc """
  Add a new task to the list
  """

  use Anubis.Server.Component,
    type: :tool

  alias Anubis.Server.Response
  alias TodoApp.Todos

  schema do
    field(:text, :string, description: "Text of the task to add", required: true)
  end

  @impl true
  def title() do
    "add_task"
  end

  @impl true
  def description() do
    "Add a new task to the list"
  end

  @impl true
  def execute(%{
    text: text
  } = _params, frame) do

    today = DateTime.utc_now()
    today_date = DateTime.to_date(today)
    due_date = Date.shift(today_date, week: 1)

    {:ok, task} = Todos.create_task(%{
      "completed" => false,
      "text" => text,
      "priority" => "medium",
      "due_date" => due_date,
      "notes" => ""
    })

    {:reply, Response.tool() |> Response.json(task), frame}
  end
end
