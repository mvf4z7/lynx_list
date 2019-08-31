defmodule LynxList.Exceptions do
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
      # Get the last module in the module path
      |> hd()
      |> Macro.underscore()
      |> String.split("_")
      |> Enum.map(&String.capitalize/1)
      |> Enum.join(" ")
    end
  end
end
