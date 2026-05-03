defmodule SameTimeTomorrow.Repo.Migrations.AddActiveToVocabLists do
  use Ecto.Migration

  def change do
    alter table(:vocab_lists) do
      add :active, :boolean, default: true, null: false
    end
  end
end
