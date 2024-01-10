defmodule KsWeb.Config do
  use GenServer

  def start_link(file) do
    GenServer.start_link(__MODULE__, file, name: __MODULE__)
  end

  def get(elem) do
    GenServer.call(__MODULE__, {:get, elem})
  end

  @impl true
  def init(file) do
    {:ok, File.read!(file) |> Toml.decode!(keys: :atoms)}
  end

  @impl true
  def handle_call({:get, elem}, _from, state) do
    {:reply, Map.get(state, elem), state}
  end
end
