defmodule TodoAppMCP.UIActionResult do

  @type t :: %__MODULE__{
          type: String.t() | nil,
          payload: %{} | nil
  }
  defstruct type: nil,
            payload: nil

  def new(%{type: "tool", tool_name: _tool_name, params: _params} = attrs) do
    struct!(__MODULE__, attrs)
  end

  def new(%{type: "prompt", prompt: _prompt} = attrs) do
    struct!(__MODULE__, attrs)
  end

  def new(%{type: "link", url: _url} = attrs) do
    struct!(__MODULE__, attrs)
  end

  def new(%{type: "intent", intent: _intent, params: _params} = attrs) do
    struct!(__MODULE__, attrs)
  end

  def new(%{type: "notify", message: _message} = attrs) do
    struct!(__MODULE__, attrs)
  end

  def new(_attrs) do
    raise("Unknown action result type")
  end

end
