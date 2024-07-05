defmodule KsWeb.Sidenote do
  use GenServer

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
