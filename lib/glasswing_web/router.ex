defmodule GlasswingWeb.Router do
  use GlasswingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GlasswingWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GlasswingWeb do
    pipe_through :browser

    live "/", CryptoLive
    # Remove any blockchain-related routes
  end

  # Other scopes may use custom stacks.
  # scope "/api", GlasswingWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:browser, :auth]
      live_dashboard "/dashboard", metrics: GlasswingWeb.Telemetry
    end
  end

  scope "/api", GlasswingWeb do
    pipe_through :api

    get "/prices", CryptoController, :prices
    get "/coin/:id", CryptoController, :coin_details
    get "/market_chart/:id", CryptoController, :market_chart
    get "/trending", CryptoController, :trending_coins
    get "/global", CryptoController, :global_data
    get "/exchanges", CryptoController, :exchanges_list
    get "/exchange_rates", CryptoController, :exchange_rates
    get "/search", CryptoController, :search_coins
    get "/markets", CryptoController, :coin_market_data
  end




  pipeline :auth do
    plug GlasswingWeb.Auth
  end
end
