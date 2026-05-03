defmodule SameTimeTomorrowWeb.ArticleLive.Index do
  use SameTimeTomorrowWeb, :live_view
  alias SameTimeTomorrow.{Feeds, Vocab, Scoring}

  @closest_count 5
  @default_threshold 80

  @impl true
  def mount(_params, _session, socket) do
    vocab_lists = Vocab.list_vocab_lists()
    active_list_ids = Enum.map(vocab_lists, & &1.id)
    known_words = Vocab.known_headwords(active_list_ids)

    {articles, closest} =
      Feeds.list_articles(limit: 200)
      |> score_and_partition(known_words, @default_threshold)

    {:ok,
     assign(socket,
       articles: articles,
       closest: closest,
       vocab_lists: vocab_lists,
       known_words: known_words,
       known_word_count: MapSet.size(known_words),
       threshold: @default_threshold,
       page_title: "同时明天"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto p-4">
      <div class="flex items-center justify-between mb-4">
        <h1 class="text-2xl font-bold">同时明天</h1>
        <div class="flex gap-4">
          <a href="/sources" class="text-sm text-blue-600 hover:underline">Sources</a>
          <a href="/words" class="text-sm text-blue-600 hover:underline">Words</a>
          <a href="/vocab/import" class="text-sm text-blue-600 hover:underline">
            Vocab (<%= @known_word_count %>)
          </a>
        </div>
      </div>

      <div class="flex items-center gap-3 mb-6">
        <label class="text-sm text-gray-500">Threshold</label>
        <input
          type="range"
          min="50" max="100" step="5"
          value={@threshold}
          phx-change="set_threshold"
          name="threshold"
          class="w-32"
        />
        <span class="text-sm font-medium w-10"><%= @threshold %>%</span>
      </div>

      <div :if={@vocab_lists == []} class="text-amber-600 bg-amber-50 border border-amber-200 rounded p-4 mb-4">
        No vocab lists yet. <a href="/vocab/import" class="underline">Import your Pleco export</a> to start filtering articles.
      </div>

      <ul :if={@articles != []} class="space-y-4 mb-8">
        <li :for={article <- @articles} class="border rounded p-4 hover:bg-gray-50">
          <a href={article.url} target="_blank" rel="noopener" class="text-blue-600 hover:underline font-medium">
            <%= article.title %>
          </a>
          <div class="text-sm text-gray-400 mt-1">
            <%= article.source.name %> · <%= format_date(article.published_at) %>
          </div>
        </li>
      </ul>

      <div :if={@articles == [] and @vocab_lists != []} class="text-gray-500 text-center py-8">
        No articles match your vocabulary level yet.
      </div>

      <div :if={@closest != []}>
        <h2 class="text-sm font-semibold text-gray-400 uppercase tracking-wide mb-3">
          Closest matches
        </h2>
        <ul class="space-y-3">
          <li :for={{score, article} <- @closest} class="border border-dashed rounded p-4 hover:bg-gray-50">
            <a href={article.url} target="_blank" rel="noopener" class="text-gray-700 hover:underline font-medium">
              <%= article.title %>
            </a>
            <div class="text-sm text-gray-400 mt-1">
              <%= article.source.name %> · <%= format_date(article.published_at) %>
              · <span class="text-gray-500"><%= score %>% known</span>
            </div>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("set_threshold", %{"threshold" => t}, socket) do
    threshold = String.to_integer(t)

    {articles, closest} =
      Feeds.list_articles(limit: 200)
      |> score_and_partition(socket.assigns.known_words, threshold)

    {:noreply, assign(socket, threshold: threshold, articles: articles, closest: closest)}
  end

  defp score_and_partition(articles, known_words, threshold) do
    scored =
      articles
      |> Enum.map(fn a -> {round(Scoring.score(a, known_words) * 100), a} end)
      |> Enum.sort_by(fn {s, _} -> -s end)

    passing =
      scored
      |> Enum.filter(fn {s, _} -> s >= threshold end)
      |> Enum.map(fn {_, a} -> a end)
      |> Enum.take(50)

    closest =
      scored
      |> Enum.reject(fn {s, _} -> s >= threshold end)
      |> Enum.take(@closest_count)

    {passing, closest}
  end

  defp format_date(nil), do: "unknown date"

  defp format_date(%DateTime{} = dt) do
    Calendar.strftime(dt, "%Y-%m-%d %H:%M")
  end
end
