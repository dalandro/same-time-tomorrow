defmodule SameTimeTomorrow.Vocab.WordAnalysis do
  @moduledoc """
  Finds unknown words that appear most frequently across article titles.
  Uses stored tokens from articles.tokens — no re-segmentation needed.
  Re-analysis is cheap when vocab list changes.

  TODO: extend to full article body once in-app reader stores content.
  """

  import Ecto.Query
  alias SameTimeTomorrow.Repo
  alias SameTimeTomorrow.Feeds.Article

  @doc """
  Returns [{word, article_count}] sorted by article_count desc.
  Only includes tokens not in known_words.
  """
  def high_interest_words(known_words, opts \\ []) do
    limit = Keyword.get(opts, :limit, 30)
    article_sample = Keyword.get(opts, :article_sample, 500)

    known_list = MapSet.to_list(known_words)

    Repo.all(
      from a in Article,
        where: a.tokens != ^[],
        order_by: [desc: a.published_at],
        limit: ^article_sample,
        select: a.tokens
    )
    |> Enum.flat_map(fn tokens ->
      tokens
      |> Enum.reject(&(&1 in known_list))
      |> Enum.uniq()
    end)
    |> Enum.frequencies()
    |> Enum.sort_by(fn {_, c} -> -c end)
    |> Enum.take(limit)
  end
end
