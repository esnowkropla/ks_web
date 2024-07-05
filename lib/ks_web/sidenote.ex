defmodule KsWeb.Sidenote do
  use GenServer

  @sidenote_pattern ~r/\^\^SIDENOTE{(.+?)}\^\^/

  def pattern(id), do: "^^SIDENOTE{#{id}}^^"

  def replace_all_marks(text) do
    get_marks(text)
    |> Enum.reduce(text, fn mark, acc -> replace_mark(mark, acc) end)
  end

  def get_marks(text) do
    Regex.scan(@sidenote_pattern, text, capture: :all_but_first)
    |> Enum.map(&Enum.at(&1, 0))
  end

  def replace_mark(id, text) do
    case get(id) do
      nil -> text
      sidenote -> String.replace(text, pattern(id), sidenote)
    end
  end

  # Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def store(id, text) do
    GenServer.call(__MODULE__, {:store, id, text})
  end

  def get(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  # Server

  @impl true
  def init([]) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:store, id, text}, _from, state) do
    {:reply, :ok, Map.put(state, id, text)}
  end

  @impl true
  def handle_call({:get, id}, _from, state) do
    {:reply, Map.get(state, id), state}
  end
end
