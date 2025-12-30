defmodule TodoAppMCP.UIResource do
  use EnumType

  alias Anubis.Server.Response
  alias TodoAppMCP.UI.{RawHtmlPayload, ExternalUrlPayload, RemoteDomPayload}
  # alias

  defenum MimeType do
    value Html, "text/html"
    value UriList, "text/uri-list"
    value ReactRemoteDom, "application/vnd.mcp-ui.remote-dom+javascript; framework=react"
    value WebComponentsRemoteDom, "application/vnd.mcp-ui.remote-dom+javascript; framework=webcomponents"
  end

  defenum UIActionType do
    value Tool, "tool"
    value Prompt, "prompt"
    value Link, "link"
    value Intent, "intent"
    value Notify, "notify"
  end

  defenum EncodingType do
    value Text, "text"
    value Blob, "blob"
  end

  @type t :: %__MODULE__{
          uri: String.t() | nil,
          content: RawHtmlPayload.t() | ExternalUrlPayload.t() | RemoteDomPayload.t() | nil,
          encoding: TodoAppMCP.UIResource.EncodingType.t() | nil,
          ui_metadata: %{} | nil,
          metadata: %{} | nil
        }
  defstruct uri: nil,
            content: nil,
            encoding: nil,
            ui_metadata: nil,
            metadata: nil

  def new(attrs) do
    struct!(__MODULE__, attrs)
  end

  def create_response_from(%__MODULE__{} = ui_resource) do
    mime_type =
      case ui_resource.content do
        %RawHtmlPayload{} -> TodoAppMCP.UIResource.MimeType.Html
        %ExternalUrlPayload{} -> TodoAppMCP.UIResource.MimeType.UriList
        %RemoteDomPayload{framework: "react"} -> TodoAppMCP.UIResource.MimeType.ReactRemoteDom
        %RemoteDomPayload{framework: "webcomponents"} -> TodoAppMCP.UIResource.MimeType.WebComponentsRemoteDom
      end

    content_response =
      case ui_resource.content do
        %RawHtmlPayload{} = payload -> payload.html_string
        %ExternalUrlPayload{} = payload when not is_nil(payload.iframe_url) -> payload.iframe_url
        %ExternalUrlPayload{} = payload when not is_nil(payload.target_url) -> %{target_url: payload.target_url, script_code: payload.script_code} |> Jason.encode!()
        %RemoteDomPayload{} = payload -> payload.script
      end

    case ui_resource.encoding.value() do
      "text" ->
        Response.resource()
        |> Response.text(content_response)
        |> Response.to_protocol(ui_resource.uri, mime_type.value())
      "blob" ->
        Response.resource()
        |> Response.blob(content_response)
        |> Response.to_protocol(ui_resource.uri, mime_type.value())
    end
  end
end
