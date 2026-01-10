defmodule ExVoix.ModelContext.UIResource do
  use EnumType

  alias Anubis.Server.Response
  alias ExVoix.ModelContext.UI.{RawHtmlPayload, ExternalUrlPayload, RemoteDomPayload, CommandPayload}

  defenum MimeType do
    value Html, "text/html"
    value UriList, "text/uri-list"
    value ReactRemoteDom, "application/vnd.mcp-ui.remote-dom+javascript; framework=react"
    value WebComponentsRemoteDom, "application/vnd.mcp-ui.remote-dom+javascript; framework=webcomponents"
    value LiveviewJSCommand, "application/vnd.ex-voix.command+javascript; framework=liveviewjs"
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
          encoding: ExVoix.ModelContext.UIResource.EncodingType.t() | nil,
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

  # TODO: Check below for more approriate format from MCP-UI
  def create_response_from(response, %__MODULE__{} = ui_resource) do
    mime_type =
      case ui_resource.content do
        %RawHtmlPayload{} -> ExVoix.ModelContext.UIResource.MimeType.Html
        %ExternalUrlPayload{} -> ExVoix.ModelContext.UIResource.MimeType.UriList
        %RemoteDomPayload{} = payload ->
          cond do
            payload.framework == "react" -> ExVoix.ModelContext.UIResource.MimeType.ReactRemoteDom
            payload.framework == "webcomponents" -> ExVoix.ModelContext.UIResource.MimeType.WebComponentsRemoteDom
          end
        %CommandPayload{} = payload ->
          cond do
            payload.framework == "liveviewjs" -> ExVoix.ModelContext.UIResource.MimeType.LiveviewJSCommand
            true -> ExVoix.ModelContext.UIResource.MimeType.LiveviewJSCommand
          end
      end

    content_response =
      case ui_resource.content do
        %RawHtmlPayload{} = payload -> payload.html_string
        %ExternalUrlPayload{} = payload when not is_nil(payload.iframe_url) -> payload.iframe_url
        %ExternalUrlPayload{} = payload when not is_nil(payload.target_url) ->
          %{target_url: payload.target_url, script_code: payload.script_code}
        %RemoteDomPayload{} = payload -> payload.script
        %CommandPayload{} = payload -> payload.script
      end

    case ui_resource.encoding.value() do
      "text" ->
        case response.type do
          :tool ->
            response
            |> Response.embedded_resource(ui_resource.uri,
              name: nil,
              mime_type: mime_type.value(),
              text: content_response
            )
          :resource ->
            response
            |> Response.text(content_response)
            |> Response.to_protocol(ui_resource.uri, mime_type.value())
        end

      "blob" ->
        case response.type do
          :tool ->
            response
            |> Response.embedded_resource(ui_resource.uri,
              name: nil,
              mime_type: mime_type.value(),
              blob: content_response
            )
          :resource ->
            response
            |> Response.blob(content_response)
            |> Response.to_protocol(ui_resource.uri, mime_type.value())
        end

    end
  end
end
