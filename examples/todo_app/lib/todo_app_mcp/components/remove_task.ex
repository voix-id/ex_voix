defmodule TodoAppMCP.Components.RemoveTask do
  @moduledoc """
  Remove task from the list
  """

  use Anubis.Server.Component,
    type: :tool

  alias Anubis.Server.Response

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
  def execute(_params, frame) do

    response = %{}
    {:reply, Response.tool() |> Response.json(response), frame}
  end
end
