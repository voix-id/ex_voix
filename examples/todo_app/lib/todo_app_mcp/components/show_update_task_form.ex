defmodule TodoAppMCP.Components.ShowUpdateTaskForm do
  @moduledoc """
  Show update task form
  """

  use Anubis.Server.Component,
    type: :tool

  alias Anubis.Server.Response
  alias TodoAppMCP.UIResource
  alias TodoAppMCP.UIResource.EncodingType
  alias TodoAppMCP.UI.RawHtmlPayload

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
    Phoenix.LiveView.JS.patch("/tasks/#{id}/edit")
    """
    raw_html = RawHtmlPayload.new(%{html_string: interactive_js})

    resource = UIResource.new(
      %{
        uri: "ui://todo_app/task-form",
        content: raw_html,
        encoding: EncodingType.Text,
        # ui_metadata: %{},
        # metadata: %{}
      }
    )
    response = UIResource.create_response_from(resource)

    {:reply, Response.tool() |> Response.json(response), frame}
  end
end
