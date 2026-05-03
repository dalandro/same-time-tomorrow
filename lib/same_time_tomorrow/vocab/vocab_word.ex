defmodule SameTimeTomorrow.Vocab.VocabWord do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vocab_words" do
    field :headword, :string
    belongs_to :list, SameTimeTomorrow.Vocab.VocabList
    timestamps()
  end

  def changeset(word, attrs) do
    word
    |> cast(attrs, [:headword, :list_id])
    |> validate_required([:headword, :list_id])
    |> unique_constraint([:list_id, :headword])
  end
end
