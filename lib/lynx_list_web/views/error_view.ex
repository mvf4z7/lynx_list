defmodule LynxListWeb.ErrorView do
  use LynxListWeb, :view

  alias LynxListWeb.ErrorHelpers

  def render("error.json", %{status: status} = assigns) do
    code = Map.get(assigns, :code, ErrorHelpers.default_code_for_status(status))
    message = Map.get(assigns, :message, ErrorHelpers.default_message_for_status(status))

    # TODO: Check assigns for a change set and map errors to an errors field if
    # errors are present

    %{
      code: code,
      message: message,
      status: status
    }
  end

  def render("error.json", %{conn: conn = %Plug.Conn{}} = assigns) do
    new_assigns = Map.put(assigns, :status, conn.status || 500)
    render("error.json", new_assigns)
  end

  def render("invalid_input_error.json", assigns) do
    new_assigns =
      assigns
      |> Map.put(:code, :InvalidInput)
      |> Map.put_new(:status, 400)
      |> Map.put_new(:message, "One or more of the request inputs was invalid")

    render("error.json", new_assigns)
  end

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # Things wanted in error responses
  #  1. status code (i.e. 404)
  #  2. message (i.e. "A user with id 123 does not exist")
  #  3. errors (from change set errors )
  def template_not_found(template, assigns \\ %{}) do
    # %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
    status = ErrorHelpers.status_from_template(template)
    new_assigns = Map.put(assigns, :status, status)
    render("error.json", new_assigns)
  end
end
