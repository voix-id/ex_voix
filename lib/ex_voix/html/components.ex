defmodule ExVoix.Html.Components do
  @moduledoc """
  Provides VOIX framework components for tool and context element.
  """
  use Phoenix.Component

  import Phoenix.HTML
  # alias Phoenix.LiveView.JS
  alias ExVoix.ModelContext.Registry

  @doc """
  Renders a tool element.

  ## Examples

      <.tool mcp={@mcp} name={@name} />
  """
  attr :mcp, :atom, required: true, doc: "the module of mcp server"
  attr :name, :any, required: true, doc: "the name of tool"
  attr :item_id, :integer, doc: "the id related to item tool"
  attr :item_label, :string, doc: "the label related to item tool"

  def tool(assigns) do
    mcp = Registry.load_mcps() |> Enum.filter(fn it -> it == assigns[:mcp] end) |> Enum.at(0)
    assigns =
      if not is_nil(mcp) do
        tool = Registry.load_tool(mcp, assigns[:name]) |> Enum.at(0)
        # IO.inspect(tool, label: "tool element")
        assigns =
          assigns
          |> assign_new(:tool_name, fn _ ->
            if not is_nil(assigns[:item_id]) and not is_nil(Map.get(tool, "title")),
              do: EEx.eval_string(Map.get(tool, "title"), [item_id: assigns[:item_id]]), else: Map.get(tool, "name")
          end)
          |> assign_new(:tool_desc, fn _ ->
            if not is_nil(assigns[:item_label]),
              do: EEx.eval_string(Map.get(tool, "description"), [item_label: assigns[:item_label]]),
              else: Map.get(tool, "description")
          end)
        props = Map.get(tool, "inputSchema") |> Map.get("properties")
        properties =
          Enum.map(props, fn {prop_name, prop_info} ->
            "<prop name='#{prop_name}' type='#{Map.get(prop_info, "type", "")}' description='#{Map.get(prop_info, "description", "")}'></prop>"
          end)
        assigns
          |> assign_new(:props, fn _ ->
            properties
          end)
      else
        assigns
      end

    ~H"""
      <tool name={@tool_name} description={@tool_desc} class="hidden">
        <%= for prop <- @props do %>
          {raw(prop)}
        <% end %>
      </tool>
    """
  end

  @doc """
  Renders a context element.

  ## Examples

      <.context name={@name} content={@content} />
  """
  attr :name, :string, required: true, doc: "the name of context"
  attr :content, :string, required: true, doc: "the content of context"

  def context(assigns) do

    ~H"""
      <context id={"context_" <> @name} name={@name} class="hidden">
        {raw(@content)}
      </context>
    """
  end
end
