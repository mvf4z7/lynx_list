defmodule LynxList.Links do
  alias Ecto.Changeset
  alias LynxList.Repo
  alias LynxList.Accounts.User
  alias LynxList.Links.{Link, LinkRecord}

  @type create_link_error :: :url_exists | :validation_error

  @spec create_link(binary) :: {:ok, %Link{}} | {:error, create_link_error()}
  def create_link(url) when is_binary(url) do
    %{"url" => url}
    |> Link.create_changeset()
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

  @spec create_link_record(%User{}, map) :: {:ok, %LinkRecord{}} | {:error, %Changeset{}}
  def create_link_record(%User{} = user, %{"url" => url} = attrs) do
    with {:ok, link} <- get_or_create_link(url),
         new_attrs <- Map.merge(attrs, %{"link_id" => link.id, "user_id" => user.id}),
         changeset <- LinkRecord.changeset(new_attrs),
         link_record <- Repo.insert(changeset) do
      link_record
    else
      value -> value
    end
  end

  @spec get_or_create_link(binary) :: {:ok, %Link{}} | {:error, atom} | no_return
  defp get_or_create_link(url) when is_binary(url) do
    with {:error, :url_exists} <- create_link(url),
         {:ok, link} <- get_link_by_url(url) do
      link
    else
      # call to create_link created a %Link{}
      {:ok, link} -> {:ok, link}
      {:error, :not_found} -> raise "unable to create or get link with url #{url}"
      {:error, reason} -> {:error, reason}
    end
  end

  @spec get_create_link_error(%Ecto.Changeset{}, ChangesetHelpers.errors_map()) :: atom
  defp get_create_link_error(%Ecto.Changeset{} = changeset, %{url: _error} = errors_map) do
    case ChangesetHelpers.has_unique_constraint?(changeset, :url) do
      true -> :url_exists
      false -> get_create_link_error(changeset, errors_map)
    end
  end

  defp get_create_link_error(_changeset, _errors_map) do
    :validation_error
  end
end
