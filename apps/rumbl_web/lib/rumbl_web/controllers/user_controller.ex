defmodule RumblWeb.UserController do
  use RumblWeb, :controller

  alias Rumbl.Accounts
  alias Rumbl.Accounts.User

  plug :authenticate_user when action in [:index, :show]

  def new(conn, _params) do
    changeset = Accounts.change_registration(%User{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> RumblWeb.Auth.login(user)
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
