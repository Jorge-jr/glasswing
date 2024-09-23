defmodule GlasswingWeb.Auth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    username = System.get_env("DASHBOARD_USERNAME") || Application.get_env(:glasswing, :dashboard_auth)[:username]
    password = System.get_env("DASHBOARD_PASSWORD") || Application.get_env(:glasswing, :dashboard_auth)[:password]

    if username && password do
      Plug.BasicAuth.basic_auth(conn, username: username, password: password)
    else
      error_message = "Dashboard authentication not configured properly. " <>
                      "Username: #{inspect(username)}, " <>
                      "Password: #{if password, do: "[REDACTED]", else: "nil"}"
      conn
      |> send_resp(500, error_message)
      |> halt()
    end
  end
end
