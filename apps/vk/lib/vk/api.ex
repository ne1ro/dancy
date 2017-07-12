defmodule VK.Api do
  use GenServer

  alias VK.QueueManager

  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def make_request(request_type, args, timeout \\ 5_000) do
    GenServer.call(__MODULE__, {:make_request, request_type, args}, timeout)
  end

  def init(_), do: {:ok, []}

  def handle_call({:make_request, request_type, args}, from, state) do
    QueueManager.enqueue_request({request_type, args, from})
    {:noreply, state}
  end
end
