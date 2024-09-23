defmodule GlasswingWeb.CryptoLive do
  use GlasswingWeb, :live_view
  alias Glasswing.CoinGecko
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: send(self(), :update)
    {:ok, assign(socket, prices: %{}, loading: true)}
  end

  @impl true
  def handle_info(:update, socket) do
    Logger.info("Updating prices")
    case CoinGecko.get_prices(["bitcoin", "ethereum", "dogecoin"]) do
      {:ok, prices} ->
        Logger.info("Prices received: #{inspect(prices)}")
        schedule_update()
        {:noreply, assign(socket, prices: prices, loading: false)}
      {:error, reason} ->
        Logger.error("Error fetching prices: #{inspect(reason)}")
        schedule_update(5000) # Retry after 5 seconds on error
        {:noreply, assign(socket, error: reason)}
    end
  end

  defp schedule_update(interval \\ 60000) do
    Process.send_after(self(), :update, interval)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-4">Cryptocurrency Prices</h1>
      <%= if @loading do %>
        <p>Loading...</p>
      <% else %>
        <%= if Map.get(assigns, :error) do %>
          <p class="text-red-500">Error: <%= @error %></p>
        <% else %>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <%= for {coin, data} <- @prices do %>
              <div class="bg-white shadow rounded-lg p-6">
                <h2 class="text-xl font-semibold mb-2"><%= String.capitalize(coin) %></h2>
                <%= if data["usd"] do %>
                  <p class="text-2xl font-bold text-green-600">$<%= format_price(data["usd"]) %></p>
                <% else %>
                  <p class="text-red-600">Price unavailable</p>
                <% end %>
              </div>
            <% end %>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  defp format_price(price) when is_float(price), do: :erlang.float_to_binary(price, [decimals: 2])
  defp format_price(price), do: price
end
