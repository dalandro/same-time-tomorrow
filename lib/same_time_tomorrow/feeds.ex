defmodule SameTimeTomorrow.Feeds do
  import Ecto.Query
  alias SameTimeTomorrow.Repo
  alias SameTimeTomorrow.Feeds.{Article, RssSource}

  def list_sources, do: Repo.all(from s in RssSource, order_by: [asc: s.name])

  def toggle_source(id) do
    source = Repo.get!(RssSource, id)
    source |> RssSource.changeset(%{enabled: !source.enabled}) |> Repo.update()
  end

  def list_enabled_sources do
    Repo.all(from s in RssSource, where: s.enabled == true)
  end

  def list_articles(opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    Repo.all(
      from a in Article,
        join: s in assoc(a, :source),
        preload: [source: s],
        order_by: [desc: a.published_at],
        limit: ^limit
    )
  end

  def insert_article(attrs) do
    %Article{}
    |> Article.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing, conflict_target: :url)
  end

  def prune_old_articles do
    cutoff = DateTime.add(DateTime.utc_now(), -30, :day)

    {count, _} =
      Repo.delete_all(from a in Article, where: a.fetched_at < ^cutoff)

    {:ok, count}
  end
end
