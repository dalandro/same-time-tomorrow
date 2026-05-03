defmodule SameTimeTomorrow.Vocab.VocabList do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vocab_lists" do
    field :name, :string
    has_many :words, SameTimeTomorrow.Vocab.VocabWord, foreign_key: :list_id
    timestamps()
  end

  def changeset(list, attrs) do
    list
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
