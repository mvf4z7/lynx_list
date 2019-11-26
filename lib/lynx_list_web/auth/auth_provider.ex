defmodule LynxListWeb.Auth.AuthProvider do
  alias LynxListWeb.Auth.AuthProvider

  @type t :: %AuthProvider{
          name: String.t(),
          user_id: String.t()
        }

  @type token :: String.t()

  @enforce_keys [:name, :user_id]
  defstruct [:name, :user_id]

  @token_context LynxListWeb.Endpoint
  @token_salt "auth_provider_token"
  @default_token_max_age 15 * 60

  @spec new(Ueberauth.Auth.t()) :: %AuthProvider{}
  def new(%Ueberauth.Auth{} = auth) do
    name =
      case is_atom(auth.provider) do
        true -> Atom.to_string(auth.provider)
        false -> auth.provider
      end

    user_id = inspect(auth.uid)
    struct(AuthProvider, %{name: name, user_id: user_id})
  end

  @spec tokenize(AuthProvider.t()) :: token()
  def tokenize(%AuthProvider{} = provider) do
    Phoenix.Token.sign(
      @token_context,
      @token_salt,
      provider
    )
  end

  @type verify_token_error_reasons :: :expired | :invalid
  @spec verify_token(token(), max_age: integer()) ::
          {:ok, AuthProvider.t()} | {:error, verify_token_error_reasons()}
  def verify_token(token, options \\ []) do
    max_age = Keyword.get(options, :max_age, @default_token_max_age)
    Phoenix.Token.verify(@token_context, @token_salt, token, max_age: max_age)
  end
end
