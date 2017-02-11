defmodule ExViber do
  require Logger

  defp get_endpoint,
    do: Application.get_env(:ex_viber, :endpoint, "https://chatapi.viber.com/pa")

  defp get_token,
    do: Application.get_env(:ex_viber, :token)

  @doc """
  Set the webhook for the bot, receiving all event types.
  """
  def set_webhook(url) do
    post "/set_webhook", %{url: url}
  end

  @doc """
  Set the webhook for the bot, receiving only the event types specified.
  """
  def set_webhook(url, event_types) when is_list(event_types) do
    post "/set_webhook", %{url: url, event_types: event_types}
  end

  def send_message(message) do
    post "/send_message", message
  end

  defp post(path, data) do
    headers = %{"X-Viber-Auth-Token" => get_token(), "Content-Type" => "application/json"}
    body = Poison.encode!(data)

    {:ok, response} = HTTPoison.post(get_endpoint() <> path, body, headers)
    result = Poison.decode!(response.body)

    case result do
      %{"status" => 0} ->
        {:ok, result}
      _ ->
        {:error, result}
    end
  end
end
