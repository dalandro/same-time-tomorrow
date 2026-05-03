defmodule SameTimeTomorrow.Repo.Migrations.AddBodyToArticles do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      add :body, :text
    end
  end
end
