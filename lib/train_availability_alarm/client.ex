defmodule TrainAvailabilityAlarm.Client do
  use HTTPoison.Base
  alias HTTPoison.Response, as: Resp

  @branch_id 6

  def process_url(path),
    do: Path.join "https://ventas.sofse.gob.ar/ventas", path

  @doc """
  Returns possible trip dates from origin to destiny
  """
  def possible_trip_dates(%{origin_id: origin_id, destiny_id: destiny_id}) do
    %Resp{body: raw_dates_string} =
      get!("/ajax_obtener_fechas.php", [], params: %{
        origen:   origin_id,
        destino:  destiny_id,
        id_ramal: @branch_id
      })

    raw_dates_string
    |> String.split(~r/\s*,\s*/)
    |> Enum.map(&date_from_string/1)
  end

  @doc """
  Returns possible services for a given
  origin, destiny_id, date and trip type
  """
  def train_services(%{
    type:       type,
    date:       date,
    origin_id:  origin_id,
    destiny_id: destiny_id
  }) do
    %Resp{body: html} =
      get!("/widget/cargar_servicios.php", [], params: %{
        tipo:       type,
        id_ramal:   @branch_id,
        fecha:      date,
        id_origen:  origin_id,
        id_destino: destiny_id
      })

    html
    |> Floki.find("option")
    |> Floki.attribute("value")
    |> Enum.reject(&(&1 == "0"))
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Returns availability for the given date,
  service, origin, destiny and trip type
  """
  def get_available_seats(%{
    type:       type,
    date:       date,
    service_id: service_id,
    origin_id:  origin_id,
    destiny_id: destiny_id
  }) do
    %Resp{body: html} =
      get!("/widget/consultar_disponibilidad.php", [], params: %{
        tipo:        type,
        id_servicio: service_id,
        id_ramal:    @branch_id,
        fecha:       date,
        id_origen:   origin_id,
        id_destino:  destiny_id
      })

    html
    |> Floki.find("option")
    |> Enum.map(&extract_availability_info/1)
    |> Enum.reject(fn
      {_seat_type, availability} -> availability == 0
      nil -> true
    end)
  end

  defp extract_availability_info(floki_node) do
    with \
      [title]           <- Floki.attribute(floki_node, "title"),
      [_, availability] <- Regex.run(~r/Disponibles: (\d+)/, title),
      availability      <- String.to_integer(availability)
    do
      seat_type = Floki.text(floki_node)
      {seat_type, availability}
    else
      _ -> nil
    end
  end

  defp date_from_string(string) do
    [_, day, month, year] = Regex.run(~r|(\d{2})/(\d{2})/(\d{4})|, string)

    [year, month, day]
    |> Enum.map(&String.to_integer&1)
    |> List.to_tuple
    |> Date.from_erl!
  end
end
