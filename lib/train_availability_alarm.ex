defmodule TrainAvailabilityAlarm do
  use Task
  require Logger
  alias __MODULE__.{Client, Mailer}

  @mitre_id 1
  @cordoba_id 5

  def start_link(_args) do
    Task.start_link(__MODULE__, :run, [])
  end

  defp set_interval(func, millisenconds) do
    Task.async(func)
    :timer.sleep(millisenconds)
    set_interval(func, millisenconds)
  end

  def run do
    Logger.info "Starting"
    set_interval(&do_run/0, 1 * 60 * 1000)
  end

  defp do_run do
    info = get_info

    if (
      Enum.any?(info.departure_services) &&
      Enum.any?(info.return_services)
    ) do
      Logger.info "Sending email"
      Mailer.send_notification(info)
    end
  end

  def get_info do
    Logger.info "Fetching info"

    departure_services = Task.async(fn ->
      get_train_services(%{
        type:       "ida",
        origin_id:  @mitre_id,
        destiny_id: @cordoba_id
      })
    end)

    return_services = Task.async(fn ->
      get_train_services(%{
        type:       "vuelta",
        origin_id:  @cordoba_id,
        destiny_id: @mitre_id
      })
    end)

    %{
      departure_services: Task.await(departure_services),
      return_services:    Task.await(return_services)
    }
  end

  def get_train_services(opts) do
    %{
      origin_id: opts.origin_id,
      destiny_id: opts.destiny_id
    }
    |> Client.possible_trip_dates
    |> Enum.map(&Task.async(fn ->
      opts = Map.put(opts, :date, &1)

      opts
      |> Client.train_services
      |> get_available_seats(opts)
    end))
    |> Enum.map(&Task.await/1)
    |> List.flatten
    |> Enum.reject(&(&1 == []))
  end

  def get_available_seats(service_ids, opts) do
    Enum.map(service_ids, &Task.async(fn ->
      available_seats =
        opts
        |> Map.put(:service_id, &1)
        |> Client.get_available_seats

      %{
        date:              opts.date,
        service_id:        &1,
        available_seats: available_seats
      }
    end))
    |> Enum.map(&Task.await/1)
    |> Enum.reject(&(&1.available_seats == []))
    |> Enum.sort(&(&1.date > &2.date))
  end
end
