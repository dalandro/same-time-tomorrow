defmodule SameTimeTomorrowWeb.SourcesLive.Index do
  use SameTimeTomorrowWeb, :live_view
  alias SameTimeTomorrow.Feeds

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, sources: Feeds.list_sources(), page_title: "RSS Sources")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-lg mx-auto p-4">
      <div class="flex items-center justify-between mb-6">
        <h1 class="text-xl font-bold">RSS Sources</h1>
        <a href="/" class="text-sm text-blue-600 hover:underline">← Articles</a>
      </div>

      <ul class="space-y-2">
        <li :for={source <- @sources}
            class="flex items-center justify-between border rounded px-4 py-3">
          <div>
            <span class={["font-medium", not source.enabled && "text-gray-400"]}>
              <%= source.name %>
            </span>
            <div class="text-xs text-gray-400 truncate max-w-xs"><%= source.url %></div>
          </div>
          <button
            phx-click="toggle"
            phx-value-id={source.id}
            class={[
              "text-sm px-3 py-1 rounded border",
              source.enabled && "border-green-400 text-green-700 hover:bg-green-50",
              not source.enabled && "border-gray-300 text-gray-400 hover:bg-gray-50"
            ]}
          >
            <%= if source.enabled, do: "On", else: "Off" %>
          </button>
        </li>
      </ul>
    </div>
    """
  end

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    Feeds.toggle_source(String.to_integer(id))
    {:noreply, assign(socket, sources: Feeds.list_sources())}
  end
end
