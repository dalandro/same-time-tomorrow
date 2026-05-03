defmodule SameTimeTomorrow.Feeds.RssParser do
  @doc """
  Parses RSS/Atom XML body into a list of %{title, url, published_at} maps.
  Uses simple regex extraction — good enough for known well-formed feeds.
  """
  def parse(body) when is_binary(body) do
    items =
      cond do
        String.contains?(body, "<item") -> parse_rss2(body)
        String.contains?(body, "<entry") -> parse_atom(body)
        true -> []
      end

    {:ok, items}
  rescue
    e -> {:error, Exception.message(e)}
  end

  defp parse_rss2(body) do
    ~r/<item[^>]*>(.*?)<\/item>/s
    |> Regex.scan(body, capture: :all_but_first)
    |> Enum.map(fn [block] ->
      %{
        title: extract_text(block, "title"),
        url: extract_link_rss(block),
        published_at: extract_date(block, ["pubDate", "dc:date"]),
        body: extract_body_rss(block)
      }
    end)
    |> Enum.reject(&(is_nil(&1.title) or is_nil(&1.url)))
  end

  defp parse_atom(body) do
    ~r/<entry[^>]*>(.*?)<\/entry>/s
    |> Regex.scan(body, capture: :all_but_first)
    |> Enum.map(fn [block] ->
      %{
        title: extract_text(block, "title"),
        url: extract_atom_link(block),
        published_at: extract_date(block, ["published", "updated"]),
        body: extract_body_atom(block)
      }
    end)
    |> Enum.reject(&(is_nil(&1.title) or is_nil(&1.url)))
  end

  defp extract_body_rss(block) do
    extract_text(block, "content:encoded") || extract_text(block, "description")
  end

  defp extract_body_atom(block) do
    extract_text(block, "content") || extract_text(block, "summary")
  end

  defp extract_text(block, tag) do
    case Regex.run(~r/<#{tag}[^>]*>(?:<!\[CDATA\[)?(.*?)(?:\]\]>)?<\/#{tag}>/s, block,
           capture: :all_but_first
         ) do
      [text] -> String.trim(text)
      _ -> nil
    end
  end

  defp extract_link_rss(block) do
    # Try <link>url</link> first, then <link href="url"/>
    case Regex.run(~r/<link[^>]*>(?:<!\[CDATA\[)?(https?:\/\/[^\s<\]]+)(?:\]\]>)?<\/link>/s, block,
           capture: :all_but_first
         ) do
      [url] ->
        String.trim(url)

      _ ->
        case Regex.run(~r/<link[^>]+href="(https?:\/\/[^"]+)"/s, block, capture: :all_but_first) do
          [url] -> String.trim(url)
          _ -> nil
        end
    end
  end

  defp extract_atom_link(block) do
    case Regex.run(~r/<link[^>]+href="(https?:\/\/[^"]+)"/s, block, capture: :all_but_first) do
      [url] -> String.trim(url)
      _ -> extract_link_rss(block)
    end
  end

  defp extract_date(block, tags) do
    Enum.find_value(tags, fn tag ->
      case Regex.run(~r/<#{tag}[^>]*>(.*?)<\/#{tag}>/s, block, capture: :all_but_first) do
        [date_str] -> parse_date(String.trim(date_str))
        _ -> nil
      end
    end)
  end

  defp parse_date(str) do
    # Try RFC2822 (RSS) and ISO8601 (Atom)
    formats = [
      &parse_rfc2822/1,
      &parse_iso8601/1
    ]

    Enum.find_value(formats, fn f -> f.(str) end)
  end

  defp parse_iso8601(str) do
    case DateTime.from_iso8601(str) do
      {:ok, dt, _} -> DateTime.truncate(dt, :second)
      _ -> nil
    end
  end

  @months ~w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
  defp parse_rfc2822(str) do
    # e.g. "Mon, 03 May 2026 12:00:00 +0000" or "03 May 2026 12:00:00 +0000"
    pattern = ~r/(\d{1,2})\s+(\w{3})\s+(\d{4})\s+(\d{2}):(\d{2}):(\d{2})\s+([+-]\d{4}|GMT|UTC)/

    case Regex.run(pattern, str, capture: :all_but_first) do
      [day, mon, year, h, m, s, tz] ->
        month = Enum.find_index(@months, &(&1 == mon))

        if month do
          offset_secs = parse_tz_offset(tz)

          case NaiveDateTime.new(
                 String.to_integer(year),
                 month + 1,
                 String.to_integer(day),
                 String.to_integer(h),
                 String.to_integer(m),
                 String.to_integer(s)
               ) do
            {:ok, ndt} ->
              ndt
              |> DateTime.from_naive!("Etc/UTC")
              |> DateTime.add(-offset_secs, :second)
              |> DateTime.truncate(:second)

            _ ->
              nil
          end
        end

      _ ->
        nil
    end
  end

  defp parse_tz_offset(tz) when tz in ["GMT", "UTC"], do: 0

  defp parse_tz_offset(<<"+"::utf8, rest::binary>>) do
    {h, m} = {String.slice(rest, 0, 2), String.slice(rest, 2, 2)}
    String.to_integer(h) * 3600 + String.to_integer(m) * 60
  end

  defp parse_tz_offset(<<"-"::utf8, rest::binary>>) do
    {h, m} = {String.slice(rest, 0, 2), String.slice(rest, 2, 2)}
    -(String.to_integer(h) * 3600 + String.to_integer(m) * 60)
  end

  defp parse_tz_offset(_), do: 0
end
