defmodule SameTimeTomorrow.Tokenizer do
  @moduledoc """
  Extracts CJK word tokens from Chinese text.
  Normalizes traditional→simplified, segments with jieba, filters to CJK only.
  Used at article fetch time (stored in articles.tokens) and for scoring.
  """

  def tokenize(text) when is_binary(text) do
    text
    |> normalize()
    |> Jieba.cut()
    |> Enum.filter(&cjk_token?/1)
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
