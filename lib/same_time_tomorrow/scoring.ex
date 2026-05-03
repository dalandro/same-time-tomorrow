defmodule SameTimeTomorrow.Scoring do
  @moduledoc """
  Scores articles against a known vocabulary set.
  Uses pre-stored tokens from articles.tokens when available (fast path).
  Falls back to live tokenization for articles without stored tokens.

  TODO: research optimal threshold (i+1 / input hypothesis); make configurable
  TODO: make threshold configurable in UI
  """

  alias SameTimeTomorrow.Tokenizer

  # TODO: research optimal threshold; make configurable
  @threshold 0.80

  @doc "Returns true if article meets the known-% threshold."
  def known_enough?(article, known_words) do
    score(article, known_words) >= @threshold
  end

  @doc "Returns float 0.0–1.0 for an article struct or raw text string."
  def score(%{tokens: [_ | _] = tokens}, known_words) do
    score_tokens(tokens, known_words)
  end

  def score(%{title: title}, known_words) do
    title |> Tokenizer.tokenize() |> score_tokens(known_words)
  end

  def score(text, known_words) when is_binary(text) do
    text |> Tokenizer.tokenize() |> score_tokens(known_words)
  end

  defp score_tokens(tokens, known_words) do
    unique = Enum.uniq(tokens)

    case length(unique) do
      0 -> 1.0
      n -> Enum.count(unique, &MapSet.member?(known_words, &1)) / n
    end
  end
end
