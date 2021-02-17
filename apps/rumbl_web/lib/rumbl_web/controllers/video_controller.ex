defmodule RumblWeb.VideoController do
  use RumblWeb, :controller

  alias Rumbl.Multimedia
  alias Rumbl.Multimedia.Video

  plug :fetch_video when action in [:show, :edit, :update, :delete]
  plug :load_categories when action in [:new, :create, :edit, :update]

  def index(conn, _params) do
    videos = Multimedia.list_user_videos(conn.assigns.current_user)
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params) do
    changeset = Multimedia.change_video(%Video{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}) do
    case Multimedia.create_video(conn.assigns.current_user, video_params) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: Routes.video_path(conn, :show, video))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _) do
    render(conn, "show.html", video: conn.assigns.video)
  end

  def edit(conn, _) do
    video = conn.assigns.video
    changeset = Multimedia.change_video(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"video" => video_params}) do
    case Multimedia.update_video(conn.assigns.video, video_params) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: Routes.video_path(conn, :show, video))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", video: conn.assigns.video, changeset: changeset)
    end
  end

  def delete(conn, _) do
    {:ok, _video} = Multimedia.delete_video(conn.assigns.video)
    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: Routes.video_path(conn, :index))
  end

  def browse(conn, _params) do
    videos = Multimedia.list_videos()
    render(conn, "index.html", videos: videos)
  end

  defp load_categories(conn, _) do
    assign(conn, :categories, Multimedia.list_alphabetical_categories())
  end

  defp fetch_video(conn, _) do
    video_id =
      conn.params["id"]
      |> Video.sluglify_back()

    case Multimedia.get_user_video(conn.assigns.current_user, video_id) do
      %Video{} = video ->
        conn |> assign(:video, video)

      nil ->
        conn |> put_flash(:error, "You can manage only your videos!") |> redirect(to: "/") |> halt()
    end
  end
end
