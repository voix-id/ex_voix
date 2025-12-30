defmodule TodoAppMCP.UI.RawHtmlPayload do

  @type t :: %__MODULE__{
    type: String.t(),
    html_string: String.t() | nil
  }
  defstruct type: "rawHtml",
            html_string: nil

  def new(%{html_string: _html_string} = attrs) do
    struct!(__MODULE__, attrs)
  end

end
