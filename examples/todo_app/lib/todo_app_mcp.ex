defmodule TodoAppMCP do
  def version do
    if vsn = Application.spec(:todo_app)[:vsn] do
      List.to_string(vsn)
    end
  end
end
