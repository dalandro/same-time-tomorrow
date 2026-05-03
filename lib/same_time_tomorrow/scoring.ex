defmodule SameTimeTomorrow.Scoring do
  @moduledoc """
  Scores article titles against a known vocabulary set.

  Current implementation: character-level scoring — each CJK character
  is checked against the known headwords MapSet. Non-CJK characters
  (punctuation, numbers, latin) are ignored.

  TODO: replace with proper word segmentation (jieba-ex or Python service)
  so multi-character words are scored as units rather than individual chars.
  """

  @threshold 0.99

  @doc "Returns true if article title meets the known-% threshold."
  def known_enough?(%{title: title}, known_words) do
    score(title, known_words) >= @threshold
  end

  @doc "Returns float 0.0–1.0 representing % of CJK chars that are known."
  def score(text, known_words) when is_binary(text) do
    chars = cjk_chars(text)

    case length(chars) do
      0 -> 1.0
      n -> Enum.count(chars, &MapSet.member?(known_words, &1)) / n
    end
  end

  defp cjk_chars(text) do
    text
    |> String.graphemes()
    |> Enum.filter(&cjk?/1)
  end

  defp cjk?(<<cp::utf8>>) when cp in 0x4E00..0x9FFF, do: true
  defp cjk?(<<cp::utf8>>) when cp in 0x3400..0x4DBF, do: true
  defp cjk?(<<cp::utf8>>) when cp in 0x20000..0x2A6DF, do: true
  defp cjk?(_), do: false
end
