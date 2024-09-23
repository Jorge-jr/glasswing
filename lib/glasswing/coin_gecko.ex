defmodule Glasswing.CoinGecko do
  use HTTPoison.Base
  alias Glasswing.Mongo
  require Logger

  @base_url "https://api.coingecko.com/api/v3"

  def get_prices(coins) when is_list(coins) do
    Logger.info("Fetching prices for #{inspect(coins)}")
    case fetch_prices_from_api(coins) do
      {:ok, prices} ->
        Enum.each(prices, fn {coin, data} ->
          upsert_price(coin, data["usd"])
        end)
        {:ok, prices}
      {:error, reason} ->
        Logger.error("Failed to fetch prices from API: #{inspect(reason)}")
        get_prices_from_db(coins)
    end
  end

  defp fetch_prices_from_api(coins) do
    coin_ids = Enum.join(coins, ",")
    url = "#{@base_url}/simple/price?ids=#{coin_ids}&vs_currencies=usd"

    case get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("Unexpected status code: #{status_code}, body: #{body}")
        {:error, :unexpected_response}
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTP request failed: #{inspect(reason)}")
        {:error, reason}
      unexpected ->
        Logger.error("Unexpected error: #{inspect(unexpected)}")
        {:error, :unexpected_error}
    end
  end

  defp get_prices_from_db(coins) do
    Logger.info("Fetching prices from DB for #{inspect(coins)}")
    prices = Mongo.find("crypto_prices", %{coin_id: %{"$in" => coins}})
    formatted_prices = format_prices(prices)
    Logger.info("DB prices: #{inspect(formatted_prices)}")
    {:ok, formatted_prices}
  end

  defp upsert_price(coin_id, price_usd) do
    Logger.info("Upserting price for #{coin_id}: #{price_usd}")
    result = Mongo.update_one("crypto_prices",
      %{coin_id: coin_id},
      %{"$set" => %{
        coin_id: coin_id,
        price_usd: price_usd,
        last_updated: DateTime.utc_now()
      }},
      upsert: true
    )
    Logger.info("Upsert result: #{inspect(result)}")
  end

  defp format_prices(prices) do
    Enum.reduce(prices, %{}, fn price, acc ->
      Map.put(acc, price["coin_id"], %{"usd" => price["price_usd"]})
    end)
  end
end
