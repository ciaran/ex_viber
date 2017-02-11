defmodule BypassRoutes do
  defmacro bypass_routes(bypass, [do: block]) do
    quote do
      Bypass.expect(unquote(bypass), fn conn ->
        Bypass.pass(unquote(bypass))

        defmodule BypassRouter do
          use Plug.Builder
          plug Plug.Parsers, parsers: [:json], json_decoder: Poison
          use Trot.Router

          unquote(block)
        end

        opts = BypassRouter.init([])
        conn = BypassRouter.call(conn, opts)

        conn
      end)
    end
  end
end
