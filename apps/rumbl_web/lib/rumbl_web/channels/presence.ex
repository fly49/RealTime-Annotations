defmodule RumblWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](http://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence, otp_app: :rumbl,
                        pubsub_server: Rumbl.PubSub
  alias RumblWeb.Gravatar

  def fetch(_topic, entries) do
    users =
      entries
      |> Map.keys()
      |> Rumbl.Accounts.list_users_with_ids()
      |> Enum.into([], fn user ->
        gravatar = Gravatar.create(user.username)
        %{id: to_string(user.id), username: user.username, gravatar: gravatar}
      end)

    for {key, %{metas: metas}} <- entries, into: %{} do
      %{username: username, gravatar: gravatar} =
        Enum.find(users, fn s -> s.id == key end)
      {key, %{metas: metas, username: username, gravatar: gravatar}}
    end
  end
end
