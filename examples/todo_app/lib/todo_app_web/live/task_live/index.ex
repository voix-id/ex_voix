defmodule TodoAppWeb.TaskLive.Index do
  use TodoAppWeb, :live_view

  alias TodoApp.Todos
  alias TodoApp.Todos.Task

  @impl true
  def mount(params, session, socket) do
    IO.inspect({"mount", params, session})

    if connected?(socket) do

    end

    tasks =
      Todos.list_tasks()
      # |> Enum.with_index()
      |> Enum.map(fn t -> %{id: t.id, task: t} end)

    {
      :ok,
      socket
      |> stream(:tasks, tasks)
    }
  end

  @impl true
  def handle_params(params, url, socket) do
    # IO.inspect({"handle_params", params, (if Map.has_key?(socket.assigns, :questions), do: socket.assigns.questions, else: nil)})
    # IO.inspect(URI.parse(url))
    socket =
      socket
      |> assign(uri: URI.parse(url))

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    task = Todos.get_task!(id)
    socket
    |> assign(:page_title, "Todo App · Edit Task")
    |> assign(:task, task)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Todo App · New Task")
    |> assign(:task, %Task{})
  end

  defp apply_action(socket, :index, params) do
    task_changeset = task_changeset_from(params)
    IO.inspect(task_changeset, label: "Task from params")

    socket
    |> assign(:page_title, "Todo App · Tasks")
    |> assign(:task, %Task{})
    |> assign(:form, to_form(task_changeset))
  end

  @impl true
  def handle_info({TodoAppWeb.TaskLive.FormComponent, {:saved, task}}, socket) do
    tsk = %{id: task.id, task: task}
    {:noreply, stream_insert(socket, :tasks, tsk)}
  end

  @impl true
  def handle_event("update_task", %{"task" => task}, socket) do
    #IO.inspect(task, label: "update_task")
    updated_tasks =
      Enum.map(task, fn {"completed_" <> id, value} ->
        task = Todos.get_task!(id)
        {:ok, tsk} = Todos.update_task(task, %{"completed" => value})
        %{id: tsk.id, task: tsk}
      end)
    task = Enum.at(updated_tasks, 0)

    {:noreply, stream_insert(socket, :tasks, task)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Todos.get_task!(id)
    {:ok, _} = Todos.delete_task(task)
    tsk = %{id: task.id, task: task}

    {:noreply, stream_delete(socket, :tasks, tsk)}
  end

  defp task_changeset_from(params = %{}) do
    Todos.change_task(%Task{}, params)
  end
  defp task_changeset_from(_), do: nil

  defp priority_badge(priority, completed) do
    case priority do
      :high ->
        if completed,
          do: "text-xs uppercase font-semibold opacity-30 badge badge-error",
          else: "text-xs uppercase font-semibold opacity-60 badge badge-error"
      :medium ->
        if completed,
          do: "text-xs uppercase font-semibold opacity-30 badge badge-warning",
          else: "text-xs uppercase font-semibold opacity-60 badge badge-warning"
      :low ->
        if completed,
          do: "text-xs uppercase font-semibold opacity-30 badge badge-info",
          else: "text-xs uppercase font-semibold opacity-60 badge badge-info"
    end
  end

  defp complete_task_text(completed) do
    if completed, do: "line-through", else: ""
  end

  defp due_date_in_days(due_date) do
    today = DateTime.utc_now()
    date_today = DateTime.to_date(today)

    diff = Date.diff(date_today, due_date)
    cond do
      diff < 0 -> "Due: #{diff*(-1)} more days"
      diff > 0 -> "Due: #{diff} days ago"
      diff == 0 -> "Due: today"
    end
  end

  defp due_date_text(completed) do
    if completed,
      do: "text-xs uppercase font-semibold opacity-30 badge badge-outline badge-secondary",
      else: "text-xs uppercase font-semibold opacity-60 badge badge-outline badge-secondary"
  end
end
