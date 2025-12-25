defmodule ExVoix.ModelContext.Registry do

  def load_mcps() do
    pids = Process.list()

    mcp_names =
      Enum.filter(pids, fn pid ->
        res =
          case Process.info(pid, :dictionary) do
            {:dictionary, res} -> res
            {:error, _} -> []
          end

        not is_nil(Keyword.get(res, :"\$logger_metadata\$")) and
          not is_nil(Keyword.get(res, :"\$logger_metadata\$") |> Map.get(:mcp_client_name))
      end)
      |> Enum.map(fn pid ->
        {:registered_name, res} = Process.info(pid, :registered_name)
        res
      end)

    # IO.inspect(mcp_names)
    # IO.inspect((mcp_names |> Enum.at(0)).list_tools())
    # DbLog.put("registered_mcps", mcp_names)
    # IO.inspect(DbLog.get("registered_mcps", []), label: "registered_mcps")
    mcp_names
  end

  def load_tool(mcp, name) do
    result =
      case mcp.list_tools() do
        {:ok, result} ->
          # IO.inspect(result, label: ":ok result")
          result

        {:error, err} ->
          IO.inspect(err, label: ":error reason")
          {:ok, result} = mcp.list_tools()
          result
      end
    # IO.inspect(Map.get(result, :result) |> Map.get("tools"), label: "get_list_tools result")
    tools = Map.get(result, :result) |> Map.get("tools")
    # IO.inspect(tools)
    cond do
      is_map(tools) ->
        Enum.filter(tools |> Map.keys(), fn t -> t == name end)

      true ->
        Enum.filter(tools, fn t -> not is_nil(Map.get(t, "name")) and Map.get(t, "name") == name end)

    end
  end

  def load_resources(_mcp, _name) do
    # TODO: once the voix standard already firmed for resources, implement this
  end

end
