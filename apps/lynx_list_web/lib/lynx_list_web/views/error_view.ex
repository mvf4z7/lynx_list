defmodule LynxListWeb.ErrorView do
  use LynxListWeb, :view

  def render("error.json", %{conn: conn} = assigns) do
    status = conn.status
    code = Map.get(assigns, :code, default_code_for_status(status))
    message = Map.get(assigns, :message, "")

    # TODO: Check assigns for a change set and map errors to an errors field if
    # errors are present

    %{
      code: code,
      message: message,
      status: status
    }
  end

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".

  # Things wanted in error responses
  #  1. status code (i.e. 404)
  #  2. message (i.e. "A user with id 123 does not exist")
  #  3. errors (from change set errors )
  def template_not_found(template, assigns) do
    IO.inspect(assigns)
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
