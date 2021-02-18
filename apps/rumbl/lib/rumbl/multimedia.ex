defmodule Rumbl.Multimedia do
  import Ecto.Query, warn: false
  alias Rumbl.Repo
  alias Rumbl.Accounts
  alias Rumbl.Multimedia.Video
  alias Rumbl.Multimedia.Category
  alias Rumbl.Multimedia.Annotation

  def list_videos do
    Repo.all(Video) |> Repo.preload(:category)
  end

  def list_videos_with_users do
    Repo.all(Video) |> Repo.preload([:category, :user])
  end

  def get_video!(id), do: Repo.get!(Video, id)

  def create_video(%Accounts.User{} = user, attrs \\ %{}) do
    %Video{}
    |> Video.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end

  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end

  def change_video(%Video{} = video, attrs \\ %{}) do
    Video.changeset(video, attrs)
  end

  def list_user_videos(%Accounts.User{} = user) do
    Video
    |> user_videos_query(user)
    |> Repo.all()
    |> Repo.preload(:category)
  end

  def get_user_video(%Accounts.User{} = user, id) do
    Video
    |> user_videos_query(user)
    |> Repo.get(id)
  end

  def create_category!(name) do
    Repo.insert!(%Category{name: name}, on_conflict: :nothing)
  end

  def list_alphabetical_categories do
    Category
    |> Category.alphabetical()
    |> Repo.all()
  end

  defp user_videos_query(query, %Accounts.User{id: user_id}) do
    from(v in query, where: v.user_id == ^user_id)
  end

  # defp videos_with_users_query(query) do
  #   from v in query,
  #     join: u in Accounts.User, on: v.user_id == u.id
  # end

  # defp videos_with_categories_query(query) do
  #   from v in query,
  #     join: c in Category, on: v.category_id == c.id
  # end

  # defp video_props_query(query) do
  #   from [v, u, c] in query,
  #     select: %{title: v.title, author: u.name, category: c.name}
  # end

  def annotate_video(%Accounts.User{id: user_id}, video_id, attrs) do
    %Annotation{video_id: video_id, user_id: user_id}
    |> Annotation.changeset(attrs)
    |> Repo.insert()
  end

  def list_anntotations(%Video{} = video, since_id \\ 0) do
    Repo.all(
      from a in Ecto.assoc(video, :annotations),
        where: a.id > ^since_id,
        order_by: [asc: a.at, asc: a.id],
        limit: 500, preload: [:user]
    )
  end
end
