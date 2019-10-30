defmodule LynxList.ChangesetHelpers do
  alias Ecto.Changeset

  @type errors_map :: %{
          required(atom) => %{
            errors: [String.t()],
            value: any()
          }
        }

  @spec get_errors_map(%Changeset{}) :: errors_map
  def get_errors_map(%Changeset{changes: changes} = changeset) do
    Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {field, errors} ->
      {field, %{errors: errors, value: Map.get(changes, field)}}
    end)
    |> Enum.into(%{})
  end

  @spec has_unique_constraint?(%Changeset{}, atom) :: bool()
  def has_unique_constraint?(%Changeset{valid?: true}, _field), do: false

  def has_unique_constraint?(%Changeset{errors: errors}, field) do
    field_errors = Keyword.get_values(errors, field)

    Enum.reduce(field_errors, false, fn error, acc ->
      {_message, opts} = error

      case acc do
        true -> true
        false -> match?(:unique, Keyword.get(opts, :constraint))
      end
    end)
  end
end
