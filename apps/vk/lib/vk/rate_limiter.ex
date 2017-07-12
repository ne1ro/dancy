defmodule VK.RateLimiter do
  use GenServer

  def start_link(interval, rate) do
    GenServer.start_link(__MODULE__, %{interval: interval, rate: rate}, name: __MODULE__)
  end

  def init(%{interval: interval, rate: rate}) do
    {:ok, %{interval: interval, rate: rate, remaining: rate, count: 0, start_at: nil}}
  end

  def check_rate(), do: GenServer.call(__MODULE__, :check_rate)

  def handle_call(:check_rate, _from, %{start_at: nil} = state) do
    Process.send_after(self(), :refresh, state.interval)
    new_state = %{state |
      start_at: system_time(),
      remaining: state.remaining - 1,
      count: state.count + 1
    }
    {:reply, check_request(new_state), new_state}
  end

  def handle_call(:check_rate, _from, %{remaining: 0} = state) do
    new_state = %{state | count: state.count + 1}
    {:reply, check_request(new_state), new_state}
  end

  def handle_call(:check_rate, _from, state) do
    new_state = %{state | remaining: state.remaining - 1, count: state.count + 1}
    {:reply, check_request(new_state), new_state}
  end

  def handle_info(:refresh, state) do
    {:noreply, %{state | start_at: nil, remaining: state.rate, count: 0}}
  end

  def handle_info(_message, state), do: {:noreply, state}

  defp check_request(%{count: count, rate: rate} = state) when count > rate do
    {:error, state.count, 0, timeout(state)}
  end

  defp check_request(state), do: {:ok, state.count, state.remaining, timeout(state)}

  defp timeout(state), do: state.start_at + state.interval - system_time()

  defp system_time(), do: System.system_time(:milliseconds)
end
