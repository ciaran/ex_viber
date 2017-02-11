defmodule ExViberTest do
  use ExUnit.Case
  doctest ExViber
  import BypassRoutes

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

    assert {:ok, %{"status" => 0}} = ExViber.set_webhook("http://example.com")
  end

  def send_file(conn, file),
    do: Plug.Conn.send_resp(conn, 200, File.read!("test/fixtures/response/" <> file))
end
