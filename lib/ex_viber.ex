defmodule ExViber do
  require Logger

  defp get_endpoint,
    do: Application.get_env(:ex_viber, :endpoint, "https://chatapi.viber.com/pa")

  defp get_token,
    do: Application.get_env(:ex_viber, :token)

  defp get_sender,
    do: Application.get_env(:ex_viber, :sender)

  @doc """
  Set the webhook for the bot, receiving all event types.
  """
  def set_webhook(url) do
    post "/set_webhook", %{url: url}
  end

  @doc """
  Set the webhook for the bot, receiving only the event types specified.
  """
  def set_webhook(url, event_types, is_inline \\ false) when is_list(event_types) do
    post "/set_webhook", %{url: url, event_types: event_types, is_inline: is_inline}
  end

  def send_inline_response(receiver, chat_id, keyboard) do
    data =
      %{
        chat_id: chat_id,
        keyboard: keyboard,
        min_api_version: 3,
        receiver: receiver
      }
    post "/send_message", data
  end

  def send_message(profile = %ExViber.UserProfile{}, message) do
    data =
      message
      |> Map.from_struct
      |> Map.merge(%{
        min_api_version: 3,
        receiver: profile.id,
        sender: get_sender(),
      })
    post "/send_message", data
  end

  def post(path, data) do
    headers = %{"X-Viber-Auth-Token" => get_token(), "Content-Type" => "application/json"}
    body = Poison.encode!(data)

    {:ok, response} = HTTPoison.post(get_endpoint() <> path, body, headers)
    result = Poison.decode!(response.body, keys: :atoms)

    case result do
      %{status: 0} ->
        {:ok, result}
      _ ->
        {:error, result}
    end
  end
end
