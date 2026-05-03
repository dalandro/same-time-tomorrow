defmodule SameTimeTomorrow.Feeds.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :title, :string
    field :url, :string
    field :published_at, :utc_datetime
    field :fetched_at, :utc_datetime
    belongs_to :source, SameTimeTomorrow.Feeds.RssSource
    timestamps()
  end

  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :url, :published_at, :fetched_at, :source_id])
    |> validate_required([:title, :url, :fetched_at, :source_id])
    |> unique_constraint(:url)
  end
end
