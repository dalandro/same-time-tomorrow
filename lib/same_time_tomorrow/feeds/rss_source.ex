defmodule SameTimeTomorrow.Feeds.RssSource do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rss_sources" do
    field :name, :string
    field :url, :string
    field :enabled, :boolean, default: true
    has_many :articles, SameTimeTomorrow.Feeds.Article, foreign_key: :source_id
    timestamps()
  end

  def changeset(source, attrs) do
    source
    |> cast(attrs, [:name, :url, :enabled])
    |> validate_required([:name, :url])
    |> unique_constraint(:url)
  end
end
