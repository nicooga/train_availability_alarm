defmodule TrainAvailabilityAlarm.Mixfile do
  use Mix.Project

  def project, do: [
    app: :train_availability_alarm,
    version: "0.1.0",
    elixir: "~> 1.5",
    start_permanent: Mix.env == :prod,
    deps: deps()
  ]

  # Run "mix help compile.app" to learn about applications.
  def application, do: [
    mod: {TrainAvailabilityAlarm.Application, []},
    extra_applications: [:logger, :bamboo, :bamboo_smtp]
  ]

  # Run "mix help deps" to learn about dependencies.
  defp deps, do: [
    {:httpoison, "~> 0.13"},
    {:poison, "~> 3.1"},
    {:floki, "~> 0.19.0"},
    {:bamboo, "~> 0.8"},
    {:bamboo_smtp, "~> 1.4.0"},
    {:slime, "~> 1.0.0"}
  ]
end
