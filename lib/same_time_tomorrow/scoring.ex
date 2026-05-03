defmodule SameTimeTomorrow.Scoring do
  @moduledoc """
  Scores article titles against a known vocabulary set using jieba word segmentation.
  Each token from jieba is checked against the known headwords MapSet.
  Non-CJK tokens (punctuation, numbers, latin) are ignored.
  """

  @threshold 0.99

  @doc "Returns true if article title meets the known-% threshold."
  def known_enough?(%{title: title}, known_words) do
    score(title, known_words) >= @threshold
  end

  @doc "Returns float 0.0–1.0 representing % of CJK tokens that are known."
  def score(text, known_words) when is_binary(text) do
    tokens = text |> Jieba.cut() |> Enum.filter(&cjk_token?/1)

    case length(tokens) do
      0 -> 1.0
      n -> Enum.count(tokens, &MapSet.member?(known_words, &1)) / n
    end
  end

  defp cjk_token?(token) do
    String.graphemes(token)
    |> Enum.any?(fn <<cp::utf8>> ->
      cp in 0x4E00..0x9FFF or cp in 0x3400..0x4DBF
    end)
  rescue
    _ -> false
  end
end
