defmodule ExViberParserTest do
  use ExUnit.Case
  alias ExViber.UserProfile

  test "parse respopnse" do
    assert %{user: %UserProfile{name: "John McClane"}} = parse_fixture("callbacks/conversation_started.json")
  end

  test "works with binary keys" do
    assert %{foo: %{bar: "baz"}, sender: %UserProfile{}} == ExViber.Parser.parse(%{"foo" => %{"bar" => "baz"}, "sender" => %{}})
  end

  def parse_fixture(file) do
    File.read!("test/fixtures/" <> file)
    |> Poison.decode!(keys: :atoms)
    |> ExViber.Parser.parse
  end
end
