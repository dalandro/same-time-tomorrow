defmodule SameTimeTomorrow.Repo.Migrations.CreateCoreTables do
  use Ecto.Migration

  def change do
    create table(:vocab_lists) do
      add :name, :string, null: false
      timestamps()
    end

    create table(:vocab_words) do
      add :list_id, references(:vocab_lists, on_delete: :delete_all), null: false
      add :headword, :string, null: false
      timestamps()
    end

    create index(:vocab_words, [:list_id])
    create unique_index(:vocab_words, [:list_id, :headword])

    create table(:rss_sources) do
      add :name, :string, null: false
      add :url, :string, null: false
      add :enabled, :boolean, default: true, null: false
      timestamps()
    end

    create table(:articles) do
      add :source_id, references(:rss_sources, on_delete: :delete_all), null: false
      add :title, :string, null: false
      add :url, :string, null: false
      add :published_at, :utc_datetime
      add :fetched_at, :utc_datetime, null: false
      timestamps()
    end

    create index(:articles, [:source_id])
    create index(:articles, [:published_at])
    create unique_index(:articles, [:url])
  end
end
