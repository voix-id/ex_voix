defmodule TodoAppMCP.Components.ShowUpdateTaskForm do
  @moduledoc """
  Show update task form
  """

  use Anubis.Server.Component,
    type: :tool

  alias Anubis.Server.Response
  alias ExVoix.ModelContext.UIResource
  alias ExVoix.ModelContext.UIResource.EncodingType
  alias ExVoix.ModelContext.UI.CommandPayload

  schema do
    field :id, :integer, required: true
  end

  @impl true
  def title() do
    "show_update_task_form_<%= item_id %>"
  end

  @impl true
  def description() do
    "Show update task '<%= item_label %>' form"
  end

  @impl true
  def execute(%{
    id: id
  } = _params, frame) do
    interactive_js = """
    JS.patch("/tasks/#{id}/edit")
    """
    lvjs_payload = CommandPayload.new(%{
      framework: "liveviewjs",
      script: interactive_js |> String.trim()
    })

    resource = UIResource.new(
      %{
        uri: "ui://todo_app/show-task-form",
        content: lvjs_payload,
        encoding: EncodingType.Text,
        # ui_metadata: %{},
        # metadata: %{}
      }
    )
    response = UIResource.create_response_from(Response.tool(), resource)

    {:reply, response, frame}
  end
end
