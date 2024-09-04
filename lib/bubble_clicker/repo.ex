defmodule BubbleClicker.Repo do
  use Ecto.Repo,
    otp_app: :bubble_clicker,
    adapter: Ecto.Adapters.SQLite3
end
