# ExViber

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_viber` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:ex_viber, "~> 0.1.0"}]
end
```

## Configuration

You must give your authentication token provided in the Viber mobile app:

```elixir
config :ex_viber,
	token: "YOUR-AUTH-TOKEN",
	sender: %{
		name: "Bot Name",
		avatar: "Optional Avatar URL"
	}
```


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_viber](https://hexdocs.pm/ex_viber).

