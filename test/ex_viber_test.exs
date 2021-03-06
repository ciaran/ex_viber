defmodule ExViberTest do
  use ExUnit.Case
  doctest ExViber
  import BypassRoutes
  alias ExViber.{UserProfile, TextMessage}

  setup do
    bypass = Bypass.open
    :ok = Application.put_env(:ex_viber, :endpoint, "http://localhost:#{bypass.port}")

    {:ok, bypass: bypass}
  end

  test "set webhook", %{bypass: bypass} do
    bypass_routes(bypass) do
      plug Plug.Parsers, parsers: [:json], json_decoder: Poison

      post "/set_webhook" do
        ExViberTest.send_file conn, "set_webhook.json"
      end
    end

    assert {:ok, %{status: 0}} = ExViber.set_webhook("http://example.com")
  end

  test "sending a message", %{bypass: bypass} do
    bypass_routes(bypass) do
      plug Plug.Parsers, parsers: [:json], json_decoder: Poison

      post "/send_message" do
        assert conn.params["min_api_version"] == 7.2
        assert conn.params["receiver"] == "foo"
        assert conn.params["type"] == "text"
        assert conn.params["text"] == "hi"

        send_resp conn, 200, Poison.encode!(%{"status" => 0})
      end
    end

    assert {:ok, %{status: 0}} = ExViber.send_message(%TextMessage{text: "hi"}, receiver: %UserProfile{id: "foo"}, chat_id: nil, opts: [api_version: 7.2])
  end

  def send_file(conn, file),
    do: Plug.Conn.send_resp(conn, 200, File.read!("test/fixtures/response/" <> file))
end
