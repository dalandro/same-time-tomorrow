defmodule SameTimeTomorrow.Feeds.ScheduleFeedsWorker do
  use Oban.Worker, queue: :feeds, max_attempts: 1

  @impl Oban.Worker
  def perform(_job) do
    SameTimeTomorrow.Feeds.FeedScheduler.enqueue_all()
    :ok
  end
end
