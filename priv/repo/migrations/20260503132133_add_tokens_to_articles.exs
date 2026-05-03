defmodule SameTimeTomorrow.Repo.Migrations.AddTokensToArticles do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      add :tokens, {:array, :string}, default: [], null: false
    end

    create index(:articles, [:tokens], using: "GIN")
  end
end
