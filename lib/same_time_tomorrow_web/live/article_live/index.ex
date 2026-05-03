defmodule SameTimeTomorrowWeb.ArticleLive.Index do
  use SameTimeTomorrowWeb, :live_view
  alias SameTimeTomorrow.{Feeds, Vocab, Scoring}

  @impl true
  def mount(_params, _session, socket) do
    vocab_lists = Vocab.list_vocab_lists()
    active_list_ids = Enum.map(vocab_lists, & &1.id)
    known_words = Vocab.known_headwords(active_list_ids)

    articles =
      Feeds.list_articles(limit: 200)
      |> Enum.filter(&Scoring.known_enough?(&1, known_words))
      |> Enum.take(50)

    {:ok,
     assign(socket,
       articles: articles,
       vocab_lists: vocab_lists,
       active_list_ids: active_list_ids,
       known_word_count: MapSet.size(known_words),
       page_title: "同时明天"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto p-4">
      <div class="flex items-center justify-between mb-6">
        <h1 class="text-2xl font-bold">同时明天</h1>
        <a href="/vocab/import" class="text-sm text-blue-600 hover:underline">
          Manage vocab (<%= @known_word_count %> words)
        </a>
      </div>

      <div :if={@vocab_lists == []} class="text-amber-600 bg-amber-50 border border-amber-200 rounded p-4 mb-4">
        No vocab lists yet. <a href="/vocab/import" class="underline">Import your Pleco export</a> to start filtering articles.
      </div>

      <div :if={@articles == [] and @vocab_lists != []} class="text-gray-500 text-center py-12">
        No articles match your vocabulary level yet. Check back after the next fetch.
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
