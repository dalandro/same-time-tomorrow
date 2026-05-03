defmodule SameTimeTomorrow.Repo.Migrations.AddUniqueIndexRssSourcesUrl do
  use Ecto.Migration

  def change do
    create unique_index(:rss_sources, [:url])
  end
end
