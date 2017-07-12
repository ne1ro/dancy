defmodule VK.QueueManager do
  use GenStage

  def start_link, do: GenStage.start_link(__MODULE__, [], name: __MODULE__)

  def init(_), do: {:producer, %{queue: :queue.new, pending_demand: 0}}

  def enqueue_request(request), do: GenStage.cast(__MODULE__, {:enqueue_request, request})

  def handle_cast({:enqueue_request, request}, state) do
    GenStage.async_info(self(), :dispatch_requests)
    {:noreply, [], %{state | queue: :queue.in(request, state.queue)}}
  end

  def handle_demand(demand, state) do
    GenStage.async_info(self(), :dispatch_requests)
    {:noreply, [], %{state | pending_demand: state.pending_demand + demand}}
  end

  def handle_info(:dispatch_requests, %{pending_demand: pending_demand} = state) when pending_demand > 0 do
    {queue, requests} = dequeue_requests(state.queue, state.pending_demand)
    {:noreply, requests, %{state | pending_demand: state.pending_demand - length(requests), queue: queue}}
  end

  def handle_info(_message, state), do: {:noreply, [], state}

  defp dequeue_requests(queue, 0), do: {queue, []}

  defp dequeue_requests(queue, count) do
    case :queue.out(queue) do
      {{:value, request}, next_queue} ->
        {new_queue, requests} = dequeue_requests(next_queue, count - 1)
        {new_queue, [request | requests]}
      {:empty, _} -> {queue, []}
      _ -> nil
    end
  end
end
