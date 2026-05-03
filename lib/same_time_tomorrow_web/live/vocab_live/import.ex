defmodule SameTimeTomorrowWeb.VocabLive.Import do
  use SameTimeTomorrowWeb, :live_view
  alias SameTimeTomorrow.Vocab

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: "Import Vocab", lists: Vocab.list_vocab_lists(), result: nil)
     |> allow_upload(:pleco_file, accept: ~w(.txt), max_entries: 1, max_file_size: 10_000_000)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-lg mx-auto p-4">
      <h1 class="text-xl font-bold mb-4">Import Pleco Vocab List</h1>

      <form phx-submit="upload" phx-change="validate">
        <div class="mb-4">
          <label class="block text-sm font-medium mb-1">List name</label>
          <input type="text" name="list_name" required class="border rounded px-3 py-2 w-full" placeholder="e.g. HSK 3" />
        </div>

        <div class="mb-4">
          <label class="block text-sm font-medium mb-1">Pleco export (.txt, tab-delimited)</label>
          <.live_file_input upload={@uploads.pleco_file} class="w-full" />
        </div>

        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
          Import
        </button>
      </form>

      <div :if={@result} class="mt-4 p-3 bg-green-50 border border-green-200 rounded text-green-800">
        Imported <%= @result.word_count %> words into "<%= @result.list.name %>".
      </div>

      <div :if={@lists != []} class="mt-8">
        <h2 class="text-lg font-semibold mb-2">Existing Lists</h2>
        <ul class="space-y-2">
          <li :for={list <- @lists} class="flex items-center justify-between border rounded px-3 py-2">
            <span><%= list.name %> <span class="text-gray-400 text-sm">(<%= length(list.words) %> words)</span></span>
            <button phx-click="delete_list" phx-value-id={list.id} class="text-red-500 text-sm hover:underline">
              Delete
            </button>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("validate", _params, socket), do: {:noreply, socket}

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
         |> assign(result: import_result, lists: Vocab.list_vocab_lists())}

      _ ->
        {:noreply, put_flash(socket, :error, "Import failed")}
    end
  end

  @impl true
  def handle_event("delete_list", %{"id" => id}, socket) do
    list = Vocab.get_list!(String.to_integer(id))
    Vocab.delete_list(list)
    {:noreply, assign(socket, lists: Vocab.list_vocab_lists(), result: nil)}
  end
end
