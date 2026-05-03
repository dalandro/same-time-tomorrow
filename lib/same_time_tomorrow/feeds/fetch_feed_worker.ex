defmodule SameTimeTomorrow.Feeds.FetchFeedWorker do
  use Oban.Worker, queue: :feeds, max_attempts: 3

  require Logger
  alias SameTimeTomorrow.Feeds

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"source_id" => source_id}}) do
    source = Feeds.list_sources() |> Enum.find(&(&1.id == source_id))

    if is_nil(source) do
      {:error, "source #{source_id} not found"}
    else
      fetch_and_store(source)
    end
  end

  defp fetch_and_store(source) do
    case Req.get(source.url, receive_timeout: 10_000) do
      {:ok, %{status: 200, body: body}} ->
        articles = parse_rss(body, source.id)
        inserted = Enum.count(articles, fn attrs -> match?({:ok, _}, Feeds.insert_article(attrs)) end)
        Logger.info("Fetched #{source.name}: #{inserted} new articles")
        :ok

      {:ok, %{status: status}} ->
        Logger.warning("Feed #{source.name} returned HTTP #{status}")
        {:error, "http_#{status}"}

      {:error, reason} ->
        Logger.warning("Feed #{source.name} fetch failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp parse_rss(body, source_id) when is_binary(body) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    case SameTimeTomorrow.Feeds.RssParser.parse(body) do
      {:ok, items} ->
        Enum.map(items, fn item ->
          %{
            source_id: source_id,
            title: item.title,
            url: item.url,
            published_at: item.published_at,
            fetched_at: now
          }
        end)

      {:error, reason} ->
        Logger.warning("RSS parse failed for source #{source_id}: #{inspect(reason)}")
        []
    end
  end
end
