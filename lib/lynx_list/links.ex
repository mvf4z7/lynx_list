defmodule LynxList.Links do
  alias Ecto.Changeset
  alias LynxList.{ChangesetHelpers, Repo}
  alias LynxList.Exceptions.{EntityNotFound}
  alias LynxList.Accounts.User
  alias LynxList.Links.{Link, LinkRecord}

  @type create_link_error :: :url_exists | :validation_error

  @spec create_link(binary) :: {:ok, %Link{}} | {:error, create_link_error()}
  def create_link(url) do
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

  @spec create_link_record(%User{}, map) :: {:ok, %LinkRecord{}} | {:error, atom}
  def create_link_record(%User{} = user, attrs) do
    with url <- Map.get(attrs, "url"),
         {:ok, link} <- get_or_create_link(url),
         new_attrs <- Map.merge(attrs, %{"link" => link, "user" => user}),
         changeset <- LinkRecord.create_changeset(new_attrs),
         {:ok, link_record} <- Repo.insert(changeset) do
      {:ok, link_record}
    else
      {:error, changeset = %Changeset{}} ->
        case ChangesetHelpers.has_unique_constraint?(changeset, :link) do
          true -> {:error, :url_exists}
          false -> {:error, :validation_error}
        end

      error ->
        error
    end
  end

  @spec get_link_record(binary) :: {:ok, %LinkRecord{}} | {:error, %EntityNotFound{}}
  def get_link_record(id) do
    # Create EntityNotFoundException for error tuple (e.g. {error, EntityNotFoundException}
    # This Exception could store a reference to the Entity being searched and the id provided
    Repo.get(LinkRecord, id)
    |> Repo.preload([:link, :user])
    |> case do
      nil -> {:error, EntityNotFound.exception(entity_module: LinkRecord, id: id)}
      link_record -> {:ok, link_record}
    end
  end

  @spec get_or_create_link(binary) :: {:ok, %Link{}} | {:error, atom} | no_return
  defp get_or_create_link(url) do
    error_message = "unable to create or get link with url #{url}"

    case create_link(url) do
      {:error, :url_exists} ->
        case get_link_by_url(url) do
          {:ok, link} ->
            {:ok, link}

          _error ->
            raise error_message
        end

      {:ok, link} ->
        {:ok, link}

      error ->
        error
    end
  end

  @spec get_create_link_error(%Ecto.Changeset{}, ChangesetHelpers.errors_map()) :: atom
  defp get_create_link_error(%Ecto.Changeset{} = changeset, %{url: _error}) do
    case ChangesetHelpers.has_unique_constraint?(changeset, :url) do
      true -> :url_exists
      false -> create_validation_error(changeset)
    end
  end

  defp get_create_link_error(changeset, _errors_map) do
    create_validation_error(changeset)
  end

  defp create_validation_error(_changeset) do
    :validation_error
  end
end
