defmodule ExVoix.ModelContext.Tool do

  alias ExVoix.ModelContext.Registry

  def call(event) do
    target_name = Map.get(event, "tool_name")
    detail = Map.get(event, "detail")

    mcps = Registry.load_mcps()
    mcp =
      Enum.filter(mcps, fn mcp -> length(Registry.load_tool(mcp, target_name, false)) > 0 end)
      |> Enum.at(0)
    if not is_nil(mcp) do
      [tool_info] = Registry.load_tool(mcp, target_name, false)
      # TODO: put id from target_name to detail
      has_item_id = Map.get(tool_info, "title") |> String.replace(" ", "") |> String.contains?("<%=item_id%>")
      detail =
        if has_item_id do
          name_prefix = Map.get(tool_info, "title") |> String.replace(" ", "") |> String.replace("<%=item_id%>", "")
          item_id = String.replace(target_name, name_prefix, "")
          Map.put(detail, "id", String.to_integer(item_id))
        else
          detail
        end
      IO.inspect(detail, label: "detail in call event")
      call_tool_response(mcp, Map.get(tool_info, "name"), detail)
    end
  end

  defp call_tool_response(mcp, tool_name, param_atoms) do
    case mcp.call_tool(tool_name, param_atoms, [timeout: 300_000]) do
      {:ok, %Anubis.MCP.Response{is_error: false, result: result}} ->
        case Map.get(result, "content") |> Enum.at(0) do
          %{"type" => "resource"} = content ->
            IO.inspect(content)
            resource = Map.get(content, "resource")
            IO.puts(
              "Success in resource: #{inspect(Map.get(resource, "text"))}"
            )
            {
              :ok,
              case Map.get(resource, "text") |> json_decode do
                decoded ->
                  if is_map(decoded) and Map.has_key?(decoded, "isError"),
                    do: decoded,
                    else: Map.put(decoded, "isError", false)
                  |> Map.put("tool", tool_name)
              end
            }

          content ->
            IO.puts(
              "Success in content: #{inspect(content |> Map.get("text"))}"
            )
            {
              :ok,
              case content |> Map.get("text") |> json_decode do
                nil ->
                  content |> Map.get("text")
                decoded ->
                  if is_map(decoded) and Map.has_key?(decoded, "isError"),
                    do: decoded,
                    else: Map.put(decoded, "isError", false)
                  |> Map.put("tool", tool_name)
              end
            }
        end

      # Domain error (tool returned isError: true)
      {:ok, %Anubis.MCP.Response{is_error: true, result: result}} ->
        case Map.get(result, "content") |> Enum.at(0) do
          %{"type" => "resource"} = content ->
            resource = Map.get(content, "resource")
            IO.puts("Tool error: #{inspect(Map.get(resource, "text"))}")
            {:ok,
              case content |> Map.get("text") |> json_decode do
                nil ->
                  content |> Map.get("text")
                decoded ->
                  if is_map(decoded) and Map.has_key?(decoded, "isError"),
                    do: decoded,
                    else: Map.put(decoded, "isError", true)
                  |> Map.put("tool", tool_name)
              end
            }

          content ->
            IO.puts("Tool error: #{inspect(content |> Map.get("text"))}")
            {:ok,
              case content |> Map.get("text") |> json_decode do
                nil ->
                  content |> Map.get("text")
                decoded ->
                  if is_map(decoded) and Map.has_key?(decoded, "isError"),
                    do: decoded,
                    else: Map.put(decoded, "isError", true)
                  |> Map.put("tool", tool_name)
              end
            }

        end
        {:ok, result}

      # Protocol/transport error
      {:error, %Anubis.MCP.Error{reason: reason}} ->
        IO.puts("Error: #{reason}")
        #mcp.close()
        {:ok, nil}
    end
  end

  defp json_decode(content) do
    try do
      :json.decode(content)
    rescue
      e in ArgumentError ->
        IO.puts "Failed to decode JSON: #{inspect(e.message)}"
        # Handle the error, perhaps return a default value or nil
        nil
      e in ErlangError ->
        # Catches raw Erlang errors if they are not automatically converted to Elixir exceptions
        IO.puts "An Erlang error occurred: #{inspect(e.original)}"
        nil
    end
  end
end
