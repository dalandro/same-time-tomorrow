defmodule SameTimeTomorrowWeb.WordsLive.Index do
  use SameTimeTomorrowWeb, :live_view
  alias SameTimeTomorrow.{Vocab, Vocab.WordAnalysis}

  @impl true
  def mount(_params, _session, socket) do
    vocab_lists = Vocab.list_vocab_lists()
    active_list_ids = Enum.map(vocab_lists, & &1.id)
    known_words = Vocab.known_headwords(active_list_ids)
    words = WordAnalysis.high_interest_words(known_words, limit: 30)

    {:ok,
     assign(socket,
       words: words,
       known_word_count: MapSet.size(known_words),
       page_title: "High-interest words"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-lg mx-auto p-4">
      <div class="flex items-center justify-between mb-6">
        <h1 class="text-xl font-bold">High-interest words</h1>
        <a href="/" class="text-sm text-blue-600 hover:underline">← Articles</a>
      </div>

      <p class="text-sm text-gray-500 mb-4">
        Unknown words appearing most across article titles. Learn these to unlock more articles.
        Based on <%= @known_word_count %> known words.
      </p>

      <div :if={@words == []} class="text-gray-400 text-center py-8">
        No data — import a vocab list first.
      </div>

      <ol class="space-y-2">
        <li :for={{word, count} <- @words} class="flex items-center justify-between border rounded px-4 py-2">
          <span class="text-lg font-medium"><%= word %></span>
          <span class="text-sm text-gray-400"><%= count %> article<%= if count != 1, do: "s" %></span>
        </li>
      </ol>
    </div>
    """
  end
end
