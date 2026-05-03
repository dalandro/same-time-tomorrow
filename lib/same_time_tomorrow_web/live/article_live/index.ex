defmodule SameTimeTomorrowWeb.ArticleLive.Index do
  use SameTimeTomorrowWeb, :live_view
  alias SameTimeTomorrow.Feeds

  def mount(_params, _session, socket) do
    articles = Feeds.list_articles(limit: 50)
    {:ok, assign(socket, articles: articles, page_title: "同时明天")}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto p-4">
      <h1 class="text-2xl font-bold mb-6">同时明天</h1>

      <div :if={@articles == []} class="text-gray-500 text-center py-12">
        No articles yet. Upload your Pleco vocab list to get started.
      </div>

      <ul class="space-y-4">
        <li :for={article <- @articles} class="border rounded p-4 hover:bg-gray-50">
          <a href={article.url} target="_blank" rel="noopener" class="text-blue-600 hover:underline font-medium">
            <%= article.title %>
          </a>
          <div class="text-sm text-gray-400 mt-1">
            <%= article.source.name %> · <%= format_date(article.published_at) %>
          </div>
        </li>
      </ul>
    </div>
    """
  end

  defp format_date(nil), do: "unknown date"

  defp format_date(%DateTime{} = dt) do
    Calendar.strftime(dt, "%Y-%m-%d %H:%M")
  end
end
