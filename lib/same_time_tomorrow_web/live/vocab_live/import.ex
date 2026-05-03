defmodule SameTimeTomorrowWeb.VocabLive.Import do
  use SameTimeTomorrowWeb, :live_view
  alias SameTimeTomorrow.Vocab

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: "Vocabulary", lists: Vocab.list_vocab_lists(), upload_result: nil)
     |> allow_upload(:pleco_file, accept: ~w(.txt), max_entries: 1, max_file_size: 10_000_000)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-lg mx-auto p-4">
      <div class="flex items-center justify-between mb-6">
        <h1 class="text-xl font-bold">Vocabulary</h1>
        <a href="/" class="text-sm text-blue-600 hover:underline">← Articles</a>
      </div>

      <ul class="space-y-2 mb-8">
        <li :for={list <- @lists}
            class="flex items-center justify-between border rounded px-4 py-3">
          <div>
            <span class={["font-medium", not list.active && "text-gray-400"]}>
              <%= list.name %>
            </span>
            <span class="text-xs text-gray-400 ml-2">
              <%= word_count(list) %> words
            </span>
          </div>
          <div class="flex gap-2">
            <button
              phx-click="toggle_list"
              phx-value-id={list.id}
              class={[
                "text-sm px-3 py-1 rounded border",
                list.active && "border-green-400 text-green-700 hover:bg-green-50",
                not list.active && "border-gray-300 text-gray-400 hover:bg-gray-50"
              ]}
            >
              <%= if list.active, do: "On", else: "Off" %>
            </button>
            <button
              phx-click="delete_list"
              phx-value-id={list.id}
              class="text-sm px-3 py-1 rounded border border-red-200 text-red-400 hover:bg-red-50"
            >
              Delete
            </button>
          </div>
        </li>
      </ul>

      <h2 class="text-base font-semibold mb-3">Upload Pleco export</h2>

      <form phx-submit="upload" phx-change="validate">
        <div class="mb-3">
          <input
            type="text"
            name="list_name"
            required
            class="border rounded px-3 py-2 w-full"
            placeholder="List name (e.g. My Pleco words)"
          />
        </div>
        <div class="mb-3">
          <.live_file_input upload={@uploads.pleco_file} class="w-full text-sm" />
          <p class="text-xs text-gray-400 mt-1">Tab-delimited .txt export from Pleco</p>
        </div>
        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 text-sm">
          Import
        </button>
      </form>

      <div :if={@upload_result} class="mt-4 p-3 bg-green-50 border border-green-200 rounded text-green-800 text-sm">
        Imported <%= @upload_result.word_count %> words into "<%= @upload_result.list.name %>".
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("validate", _params, socket), do: {:noreply, socket}

  @impl true
  def handle_event("toggle_list", %{"id" => id}, socket) do
    Vocab.toggle_list(String.to_integer(id))
    {:noreply, assign(socket, lists: Vocab.list_vocab_lists())}
  end

  @impl true
  def handle_event("upload", %{"list_name" => list_name}, socket) do
    result =
      consume_uploaded_entries(socket, :pleco_file, fn %{path: path}, _entry ->
        content = File.read!(path)
        {:ok, Vocab.import_pleco_export(list_name, content)}
      end)

    case result do
      [{:ok, {:ok, import_result}}] ->
        {:noreply,
         socket
         |> assign(upload_result: import_result, lists: Vocab.list_vocab_lists())}

      _ ->
        {:noreply, put_flash(socket, :error, "Import failed")}
    end
  end

  @impl true
  def handle_event("delete_list", %{"id" => id}, socket) do
    Vocab.get_list!(String.to_integer(id)) |> Vocab.delete_list()
    {:noreply, assign(socket, lists: Vocab.list_vocab_lists(), upload_result: nil)}
  end

  defp word_count(%{word_count: n}) when is_integer(n), do: n
  defp word_count(_), do: "?"
end
