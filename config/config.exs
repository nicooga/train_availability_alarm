use Mix.Config

config :train_availability_alarm, TrainAvailabilityAlarm.Mailer,
  adapter:  Bamboo.SMTPAdapter,
  server:   "smtp.gmail.com",
  hostname: "smtp.gmail.com",
  port:     587,
  username: "2112.oga@gmail.com",
  password: "perro3416",
  tls: :always

# import_config "#{Mix.env}.exs"
