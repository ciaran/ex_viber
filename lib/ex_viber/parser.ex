defmodule ExViber.Parser do
  def parse(data, model \\ nil) do
    data = Enum.map(data, &do_parse/1)

    if model do
      struct(model, data)
    else
      Map.new(data)
    end
  end

  defp do_parse({key, value}) when is_binary(key) do
    do_parse({String.to_atom(key), value})
  end

  defp do_parse({key, value}) when key in [:sender, :user] do
    {key, parse(value, ExViber.UserProfile)}
  end

  defp do_parse({key, value}) when is_map(value) do
    {key, parse(value)}
  end

  defp do_parse({key, value}) do
    {key, value}
  end
end
