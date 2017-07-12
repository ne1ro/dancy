defmodule VK.Mixfile do
  use Mix.Project

  def project do
    [app: :vk,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [applications: [:httpoison, :logger],
     mod: {VK.Application, []}]
  end

  defp deps do
    [
      {:gen_stage, "~> 0.12"},
      {:httpoison, "~> 0.11.1"},
      {:poison, "~> 3.1"}
    ]
  end
end
