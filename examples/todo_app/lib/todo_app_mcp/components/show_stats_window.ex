defmodule TodoAppMCP.Components.ShowStatsWindow do
  @moduledoc """
  Show TodoApp statistics window
  """

  use Anubis.Server.Component,
    type: :tool

  alias Anubis.Server.Response
  alias ExVoix.ModelContext.UIResource
  alias ExVoix.ModelContext.UIResource.EncodingType
  alias ExVoix.ModelContext.UI.RemoteDomPayload
  alias TodoApp.Todos

  schema do
    # field :id, :integer, required: true
  end

  @impl true
  def title() do
    "show_stats_window"
  end

  @impl true
  def description() do
    "Show TodoApp statistics window"
  end

  @impl true
  def execute(_params, frame) do
    stats = Todos.get_stats()
    stats_text = Enum.map_join(stats, "<br />", fn {k,v} -> "#{k}: #{v}" end)
    # IO.inspect(stats_text)

    js_code =
    """
      let isDarkMode = false;

      // Create the main container stack with centered alignment
      const stack = document.createElement('ui-stack');
      stack.setAttribute('direction', 'vertical');
      stack.setAttribute('spacing', '20');
      stack.setAttribute('align', 'center');

      // Create the title text
      const title = document.createElement('ui-text');
      title.setAttribute('content', 'TodoApp Statistics');

      // Create the toggle button
      const toggleButton = document.createElement('ui-button');
      toggleButton.setAttribute('label', '🌙 Switch to Dark Mode');

      // Create the stats text
      const stats = document.createElement('ui-text');
      stats.setAttribute('content', '#{stats_text}');

      // Add the toggle functionality
      toggleButton.addEventListener('press', () => {
        isDarkMode = !isDarkMode;

        if (isDarkMode) {
          // Switch to dark mode
          toggleButton.setAttribute('label', '☀️ Switch to Light Mode');
        } else {
          // Switch to light mode
          toggleButton.setAttribute('label', '🌙 Switch to Dark Mode');
        }

        console.log('Logo toggled to:', isDarkMode ? 'dark' : 'light', 'mode');
      });

      // Assemble the UI
      stack.appendChild(title);
      stack.appendChild(stats);
      stack.appendChild(toggleButton);
      root.appendChild(stack);
    """

    wc_payload = RemoteDomPayload.new(%{
      framework: "webcomponents",
      script: js_code |> String.trim()
    })

    resource = UIResource.new(
      %{
        uri: "ui://todo_app/show-stats-window",
        content: wc_payload,
        encoding: EncodingType.Text,
        # ui_metadata: %{},
        # metadata: %{}
      }
    )
    response = UIResource.create_response_from(Response.tool(), resource)

    {:reply, response, frame}
  end

end
