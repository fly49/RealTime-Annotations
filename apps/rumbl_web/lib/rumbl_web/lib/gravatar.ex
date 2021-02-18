defmodule RumblWeb.Gravatar do
  import Phoenix.HTML.Tag, only: [img_tag: 2]
  def create(str, size \\ 25) do
    hash = str
    |> String.trim()
    |> String.downcase()
    |> :erlang.md5()
    |> Base.encode16(case: :lower)


    url = "https://www.gravatar.com/avatar/#{hash}?s=#{size}&d=retro"
    "<img src=\"#{url}\">"
  end
end
