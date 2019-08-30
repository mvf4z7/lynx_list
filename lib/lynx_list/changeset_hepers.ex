defmodule LynxList.ChangesetHelpers do
  alias Ecto.Changeset

  @type changeset_error :: {String.t(), Keyword.t()}
  @type errors_map :: %{required(atom) => [changeset_error]}

  @spec get_errors_map(%Changeset{}) :: errors_map
  def get_errors_map(%Changeset{errors: errors}) do
    errors
    |> Keyword.keys()
    |> Enum.reduce(%{}, fn key, acc ->
      values = Keyword.get_values(errors, key)
      Map.put(acc, key, values)
    end)
  end

  @spec has_unique_constraint?(%Changeset{}, atom) :: bool()
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
