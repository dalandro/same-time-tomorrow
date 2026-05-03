defmodule PlecoParser do
  @moduledoc """
  Parses Pleco tab-delimited flashcard export files.
  Format per line: headword[TAB]definition[TAB]...
  Lines starting with // are comments. Blank lines skipped.
  Returns list of headword strings (simplified Chinese).
  TODO: consider richer data (definitions, pinyin, score) from export
  """

  def parse(content) when is_binary(content) do
    content
    |> String.split(["\r\n", "\n"])
    |> Enum.reject(&skip?/1)
    |> Enum.map(&extract_headword/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  defp skip?(""), do: true
  defp skip?(<<"//", _::binary>>), do: true
  defp skip?(_), do: false

  defp extract_headword(line) do
    case String.split(line, "\t", parts: 2) do
      [hw | _] ->
        hw = String.trim(hw)
        if hw == "", do: nil, else: hw

      _ ->
        nil
    end
  end
end
