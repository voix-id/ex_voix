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

  def load_tools() do
  end

  def load_resources() do

  end

  def put_contexts(_contexts \\ %{}) do

  end
end
