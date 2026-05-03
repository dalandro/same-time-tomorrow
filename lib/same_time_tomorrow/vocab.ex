defmodule SameTimeTomorrow.Vocab do
  import Ecto.Query
  alias SameTimeTomorrow.Repo
  alias SameTimeTomorrow.Vocab.{VocabList, VocabWord}

  def list_vocab_lists do
    Repo.all(
      from l in VocabList,
        left_join: w in assoc(l, :words),
        group_by: l.id,
        order_by: [asc: l.name],
        select: %{l | words: []}
    )
    |> Enum.map(fn list ->
      count = Repo.aggregate(from(w in VocabWord, where: w.list_id == ^list.id), :count)
      Map.put(list, :word_count, count)
    end)
  end

  def active_list_ids do
    Repo.all(from l in VocabList, where: l.active == true, select: l.id)
  end

  def toggle_list(id) do
    list = Repo.get!(VocabList, id)
    list |> VocabList.changeset(%{active: !list.active}) |> Repo.update()
  end

  def get_list!(id), do: Repo.get!(VocabList, id)

  def create_list(attrs) do
    %VocabList{}
    |> VocabList.changeset(attrs)
    |> Repo.insert()
  end

  def delete_list(list), do: Repo.delete(list)

  def import_pleco_export(list_name, file_content) do
    words = PlecoParser.parse(file_content)

    Repo.transaction(fn ->
      {:ok, list} = create_list(%{name: list_name})

      {inserted, _} =
        Repo.insert_all(
          VocabWord,
          Enum.map(words, fn hw ->
            now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
            %{list_id: list.id, headword: hw, inserted_at: now, updated_at: now}
          end),
          on_conflict: :nothing,
          conflict_target: [:list_id, :headword]
        )

      %{list: list, word_count: inserted}
    end)
  end

  def known_headwords(list_ids) when is_list(list_ids) do
    Repo.all(
      from w in VocabWord,
        where: w.list_id in ^list_ids,
        select: w.headword
    )
    |> MapSet.new()
  end
end
