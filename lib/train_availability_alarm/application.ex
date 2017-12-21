defmodule TrainAvailabilityAlarm.Application do
  def start(_type, _args) do
    import Supervisor.Spec

    Supervisor.start_link(
      [TrainAvailabilityAlarm],
      strategy: :one_for_one,
      name: TrainAvailabilityAlarm.Supervisor
    )
  end
end
