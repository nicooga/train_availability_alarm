defmodule TrainAvailabilityAlarm.Mailer do
  use Bamboo.Mailer, otp_app: :train_availability_alarm
  import Bamboo.Email

  def send_notification(availability_info) do
    new_email
    |> to("2112.oga@gmail.com")
    |> from("info@train_availability_alarm.com")
    |> subject("Train Availability Alarm")
    |> put_body(availability_info)
    |> deliver_now
  end

  defp put_body(mail, availability_info) do
    template =
      "./lib/train_availability_alarm/mail.slim"
      |> Path.expand
      |> File.read!

    html_body(mail, Slime.render(template, sections: sections(availability_info)))
  end

  defp sections(availability_info) do
    [
      %{
        title: "Possible departure trips",
        services: services(availability_info.departure_services)
      },
      %{
        title: "Possible return trips",
        services: services(availability_info.return_services)
      }
    ]
  end

  defp services(services) do
    Enum.map(services, fn service ->
      Map.update!(service, :available_seats, &available_seats_to_string/1)
    end)
  end

  defp available_seats_to_string(available_seats) do
    available_seats
    |> Enum.map(&(&1 |> Tuple.to_list |> Enum.join(": ")))
    |> Enum.join(" | ")
  end
end
