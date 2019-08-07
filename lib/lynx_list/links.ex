defmodule LynxList.Links do
  alias LynxList.Repo
  alias LynxList.Accounts.User
  alias LynxList.Links.{Link, LinkRecord}

  @spec create_link(map) :: {:ok, %Link{}} | {:error, atom}
  def create_link(attrs) when is_map(attrs) do
    attrs
    |> Link.changeset()
    |> Repo.insert()
    |> case do
      {:ok, link} ->
        {:ok, link}

      {:error, changeset} ->
        errors_map = ChangesetHelpers.get_errors_map(changeset)
        {:error, get_create_link_error(changeset, errors_map)}
    end
  end

  @spec get_link_by_url(binary) :: {:ok, %Link{}} | {:error, :not_found}
  def get_link_by_url(url) when is_binary(url) do
    case Repo.get_by(Link, url: url) do
      nil -> {:error, :not_found}
      link -> {:ok, link}
    end
  end

  @spec save_link_record(%User{}, map) :: %LinkRecord{}
  def save_link_record(%User{} = user, attrs) do
  end

  defp get_or_create_link(attrs) when is_map(attrs) do
  end

  @spec get_create_link_error(%Ecto.Changeset{}, ChangesetHelpers.errors_map()) :: atom
  defp get_create_link_error(%Ecto.Changeset{} = changeset, %{url: _error} = errors_map) do
    case ChangesetHelpers.has_unique_constraint?(changeset, :url) do
      true -> :url_exists
      false -> get_create_link_error(changeset, errors_map)
    end
  end

  defp get_create_link_error(_changesetG, _errors_map) do
    :validation_error
  end
end
