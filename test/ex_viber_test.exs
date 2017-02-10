defmodule ExViberTest do
  use ExUnit.Case
  doctest ExViber

  setup do
    bypass = Bypass.open
    :ok = Application.put_env(:ex_viber, :endpoint, "http://localhost:#{bypass.port}")

    {:ok, bypass: bypass}
  end

  test "set webhook", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn = %{request_path: "/set_webhook"} ->
      send_file(conn, "response/set_webhook.json")
    end)

    ExViber.set_webhook("http://example.com")
  end

  defp send_file(conn, file),
    do: Plug.Conn.resp(conn, 200, File.read!("test/fixtures/" <> file))
end
