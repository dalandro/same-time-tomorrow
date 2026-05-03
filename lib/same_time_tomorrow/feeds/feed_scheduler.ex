defmodule SameTimeTomorrow.Feeds.FeedScheduler do
  @moduledoc """
  Enqueues FetchFeedWorker jobs for all enabled RSS sources.
  Called on app startup and every hour via Oban cron.
  """
  alias SameTimeTomorrow.Feeds
  alias SameTimeTomorrow.Feeds.FetchFeedWorker

  def enqueue_all do
    Feeds.list_enabled_sources()
    |> Enum.each(fn source ->
      %{source_id: source.id}
      |> FetchFeedWorker.new()
      |> Oban.insert()
    end)
  end
end
