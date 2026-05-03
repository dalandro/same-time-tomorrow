defmodule SameTimeTomorrow.Repo do
  use Ecto.Repo,
    otp_app: :same_time_tomorrow,
    adapter: Ecto.Adapters.Postgres
end
