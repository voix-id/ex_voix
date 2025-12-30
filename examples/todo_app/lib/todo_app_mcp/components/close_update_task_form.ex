defmodule TodoAppMCP.Components.CloseUpdateTaskForm do
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
    #field :id, :integer, required: true
  end

  @impl true
  def title() do
    "close_update_task_form"
  end

  @impl true
  def description() do
    "Close update task form"
  end

  @impl true
  def execute(_params, frame) do
    interactive_js = """
    Phoenix.LiveView.JS.patch("/tasks")
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
