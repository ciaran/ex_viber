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
  def send_inline_response(receiver, chat_id, keyboard, opts \\ []) do
    send_message(%ExViber.KeyboardMessage{keyboard: keyboard}, receiver: receiver, chat_id: chat_id, opts: opts)
  end

  def send_message(message, receiver: receiver, chat_id: chat_id) do
    send_message(message, receiver: receiver, chat_id: chat_id, opts: [])
  end

  def send_message(message, receiver: receiver = %ExViber.UserProfile{}, chat_id: chat_id, opts: opts) do
    send_message(message, receiver: receiver.id, chat_id: chat_id, opts: opts)
  end

  def send_message(message, receiver: receiver, chat_id: chat_id, opts: opts) do
    data = construct_message(message, opts)

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

  def broadcast_message(message, broadcast_list) when is_list(broadcast_list) do
    data =
      message
      |> construct_message()
      |> Map.put(:broadcast_list, broadcast_list)

    post "/broadcast_message", data
  end

  defp construct_message(message, opts \\ []) do
    opts = default_options(opts)

    message
    |> remove_struct()
    |> Map.delete(:chat_id)
    |> Map.merge(%{
      min_api_version: opts[:api_version],
      sender: get_sender(),
    })
  end

  def post(path, data) do
    headers = %{"X-Viber-Auth-Token" => get_token(), "Content-Type" => "application/json"}
    body = Poison.encode!(data)

    HTTPoison.post(get_endpoint() <> path, body, headers)
    |> handle_result()
  end

  defp handle_result({:ok, response}) do
    case Poison.decode(response.body, keys: :atoms) do
      {:ok, result} ->
        case result do
          %{status: 0} ->
            {:ok, result}
          %{status: status, status_message: message} ->
            {:error, status, message}
        end
      {:error, _error} ->
        {:error, "Viber responded with an invalid JSON object: #{inspect response.body}"}
    end
  end

  defp handle_result({:error, %HTTPoison.Error{reason: error}}) do
    {:error, "Request to Viber failed: #{inspect error}"}
  end

  defp default_options(options) do
    [
      api_version: min_api_version(),
    ] |> Keyword.merge(options)
  end

  defp remove_struct(struct = %_{}),
    do: Map.from_struct(struct)
  defp remove_struct(map) when is_map(map),
    do: map
end
