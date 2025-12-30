defmodule TodoAppMCP.UI.ExternalUrlPayload do

  @type t :: %__MODULE__{
    type: String.t(),
    iframe_url: String.t() | nil
  }
  defstruct type: "externalUrl",
            iframe_url: nil,
            target_url: nil,
            script_code: nil

  def new(%{iframe_url: _iframe_url} = attrs) do
    struct!(__MODULE__, attrs)
  end

  def new(%{target_url: _target_url, script_code: _script_code} = attrs) do
    struct!(__MODULE__, attrs)
  end

end
