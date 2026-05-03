defmodule SameTimeTomorrow.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SameTimeTomorrowWeb.Telemetry,
      SameTimeTomorrow.Repo,
      {DNSCluster, query: Application.get_env(:same_time_tomorrow, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SameTimeTomorrow.PubSub},
      {OpenCC, built_in: :t2s, name: :opencc_t2s},
      {Oban, Application.fetch_env!(:same_time_tomorrow, Oban)},
      SameTimeTomorrowWeb.Endpoint,
      {Task, &SameTimeTomorrow.Feeds.FeedScheduler.enqueue_all/0}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SameTimeTomorrow.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SameTimeTomorrowWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
