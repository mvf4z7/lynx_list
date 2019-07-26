defmodule LynxListWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(LynxListWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(LynxListWeb.Gettext, "errors", msg, opts)
    end
  end

  @spec status_from_template(String.t()) :: integer
  def status_from_template(template) when is_binary(template) do
    template
    |> String.split(".")
    |> hd()
    |> String.to_integer()
  end

  @spec default_code_for_status(integer) :: String.t()
  def default_code_for_status(status) do
    status
    |> Plug.Conn.Status.reason_phrase()
    |> String.replace(" ", "")
  end
end