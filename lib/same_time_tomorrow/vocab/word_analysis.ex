defmodule SameTimeTomorrow.Vocab.WordAnalysis do
  @moduledoc """
  Finds unknown words that appear most frequently across article titles.
  High document-frequency unknown words are high-value learning targets —
  knowing them would unlock the most articles.

  TODO: extend to full article body text once in-app reader stores content.
  """

  alias SameTimeTomorrow.Feeds

  @doc """
  Returns [{word, article_count}] sorted by article_count desc.
  Only includes CJK tokens not in known_words.
  """
  def high_interest_words(known_words, opts \\ []) do
    limit = Keyword.get(opts, :limit, 30)
    article_sample = Keyword.get(opts, :article_sample, 500)

    Feeds.list_articles(limit: article_sample)
    |> Enum.flat_map(fn article ->
      article.title
      |> normalize()
      |> Jieba.cut()
      |> Enum.filter(&cjk_token?/1)
      |> Enum.reject(&MapSet.member?(known_words, &1))
      |> Enum.uniq()
      |> Enum.map(&{&1, article.id})
    end)
    |> Enum.group_by(fn {word, _} -> word end, fn {_, id} -> id end)
    |> Enum.map(fn {word, article_ids} -> {word, length(article_ids)} end)
    |> Enum.sort_by(fn {_, count} -> -count end)
    |> Enum.take(limit)
  end

  defp normalize(text) do
    case OpenCC.convert(:opencc_t2s, text) do
      {:ok, simplified} -> simplified
      _ -> text
    end
  rescue
    _ -> text
  end

  defp cjk_token?(token) do
    String.graphemes(token)
    |> Enum.any?(fn g ->
      case g do
        <<cp::utf8>> -> cp in 0x4E00..0x9FFF or cp in 0x3400..0x4DBF
        _ -> false
      end
    end)
  rescue
    _ -> false
  end
end
