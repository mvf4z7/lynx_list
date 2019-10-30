defmodule LynxList.Exceptions do
  alias LynxList.ChangesetHelpers

  defmodule EntityNotFound do
    @enforce_keys [:entity_module, :id]
    defexception [:entity_module, :id]

    @impl true
    @spec exception(entity_module: module(), id: Ecto.UUID.t()) :: Exception.t()
    def exception(args) do
      %{entity_module: entity_module, id: id} = Enum.into(args, %{})
      %__MODULE__{entity_module: entity_module, id: id}
    end

    @impl true
    @spec message(%__MODULE__{}) :: binary
    def message(%__MODULE__{} = exception) do
      "Unable to find #{parse_entity_name(exception.entity_module)} entity with an id of #{
        exception.id
      }"
    end

    @spec parse_entity_name(module) :: binary
    defp parse_entity_name(module) when is_atom(module) do
      # module comes in as an atom of the full dotted module path (e.g. LynxList.Foo.Bar)

      module
      |> Atom.to_string()
      |> String.split(".")
      |> Enum.reverse()
      # hd gets the last module in the module path since the list was reversed
      |> hd()
      |> Macro.underscore()
      |> String.split("_")
      |> Enum.map(&String.capitalize/1)
      |> Enum.join(" ")
    end
  end

  defmodule InvalidInputError do
    @enforce_keys [:fields]
    defexception [:fields]

    @impl true
    @spec exception(Ecto.Changeset.t()) :: Exception.t()
    def exception(%Ecto.Changeset{valid?: false} = invalid_changeset) do
      %__MODULE__{fields: ChangesetHelpers.get_errors_map(invalid_changeset)}
    end

    @impl true
    def message(%__MODULE__{fields: fields}) do
      "Validation errors present for the following fields\n#{IO.inspect(fields)}"
    end
  end
end
