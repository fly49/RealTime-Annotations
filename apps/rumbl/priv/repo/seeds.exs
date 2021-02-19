alias Rumbl.Multimedia

for category_name <- ~w(Action Drama Romance Comedy Sci-fi Documentary) do
  case Multimedia.get_category_by_name(category_name) do
    nil -> Multimedia.create_category!(category_name)
    category ->
  end
end
