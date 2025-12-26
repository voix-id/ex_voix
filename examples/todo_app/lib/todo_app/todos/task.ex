defmodule TodoApp.Todos.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :text, :priority, :completed, :due_date, :notes]}
  schema "tasks" do
    field :text, :string
    field :priority, Ecto.Enum, values: [:low, :medium, :high]
    field :completed, :boolean
    field :due_date, :date
    field :notes, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:text, :priority, :completed, :due_date, :notes])
    |> validate_required([:text])
  end
end
