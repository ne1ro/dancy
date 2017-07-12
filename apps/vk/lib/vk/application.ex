defmodule VK.Application do
  use Application

  alias VK.Api
  alias VK.RateLimiter
  alias VK.QueueManager
  alias VK.Worker

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {:ok, interval} = Application.fetch_env(:vk, :interval)
    {:ok, rate} = Application.fetch_env(:vk, :rate)

    children = [
      worker(Api, []),
      worker(RateLimiter, [interval, rate]),
      worker(QueueManager, [])
    ]

    workers = Enum.map(1..rate, fn (id)-> worker(Worker, [], id: id) end)

    opts = [strategy: :one_for_one, name: VK.Supervisor]
    Supervisor.start_link(children ++ workers, opts)
  end
end
