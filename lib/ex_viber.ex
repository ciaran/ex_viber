defmodule ExViber do
  require Logger

  def min_api_version,
    do: Application.get_env(:ex_viber, :api_version, 3.1)

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

  # There are three variations to send messages. Variations 2 and 3 are relevant for Chat Extensions.
  # 1 - “receiver” only - for use with Public Accounts only. (Requires subscription to the PA).
  # 2 - “chat_id” only - message sent to all participants in the inline conversation,
  #     requires “reply_type” message.
  # 3 - “chat_id” and “receiver” - message is sent to the sender of the message in the specific conversation,
  #     requires “reply_type” query (Keyboard only).
  def send_inline_response(receiver, chat_id, keyboard) do
    send_message(%ExViber.KeyboardMessage{keyboard: keyboard}, receiver: receiver, chat_id: chat_id)
  end

  def send_message(message, receiver: receiver = %ExViber.UserProfile{}, chat_id: chat_id) do
    send_message(message, receiver: receiver.id, chat_id: chat_id)
  end

  def send_message(message, receiver: receiver, chat_id: chat_id) do
    data =
      message
      |> Map.from_struct
      |> Map.delete(:chat_id)
      |> Map.merge(%{
        min_api_version: min_api_version(),
        sender: get_sender(),
      })

    data =
      if !is_nil(receiver),
        do: Map.put(data, :receiver, receiver),
        else: data

    data =
      if !is_nil(chat_id),
        do: Map.put(data, :chat_id, chat_id),
        else: data

    post "/send_message", data
  end

  def post(path, data) do
    headers = %{"X-Viber-Auth-Token" => get_token(), "Content-Type" => "application/json"}
    body = Poison.encode!(data)

    HTTPoison.post(get_endpoint() <> path, body, headers)
    |> handle_result(data)
  end

  defp handle_result({:ok, response}, data) do
    result = Poison.decode!(response.body, keys: :atoms)

    case result do
      %{status: 0} ->
        {:ok, result}
      %{status: status, status_message: message} ->
        Logger.error("Viber responded with status #{inspect status}, error: #{inspect message}", data: data)
        {:error, result}
    end
  end

  defp handle_result({:error, %HTTPoison.Error{reason: error}}, _data) do
    Logger.error("Request to Viber failed: #{inspect error}")
    {:error, error}
  end
end
