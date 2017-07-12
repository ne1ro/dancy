defmodule VK.Worker do
  use GenStage

  alias VK.QueueManager
  alias VK.RateLimiter
  alias VK.Wrapper

  defdelegate check_rate, to: RateLimiter

  def start_link(options \\ []), do: GenStage.start_link(__MODULE__, [], options)

  def init(_), do: {:consumer, %{subscription: nil}, subscribe_to: [QueueManager]}

  def handle_subscribe(:producer, _options, from, state) do
    GenStage.ask(from, 1)
    {:manual, %{state | subscription: from}}
  end

  def handle_events([request], _from, state) do
    handle_request(request, state)
    {:noreply, [], state}
  end

  def handle_info({:timeout_request, request}, state) do
    handle_request(request, state)
    {:noreply, [], state}
  end

  defp handle_request({request_type, args, request_from} = request, state) do
    case check_rate() do
      {:ok, _, _, _} ->
        GenStage.reply(request_from, apply(Wrapper, request_type, [args]))
        GenStage.ask(state.subscription, 1)
      {:error, _, _, timeout} ->
        Process.send_after(self(), {:timeout_request, request}, timeout)
      _ -> nil
    end
  end
end
