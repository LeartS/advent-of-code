defmodule Deck do

  def reverse(cards) do
    Enum.reverse(cards)
  end

  def cut(cards, n) do
    {top, bottom} = Enum.split(cards, n)
    bottom ++ top
  end

  def deal(cards, n) do
    len = length(cards)
    Stream.iterate(0, fn prev -> prev + n |> rem(len) end)
    |> Enum.zip(cards)
    |> Enum.reduce(:array.new(len), fn {pos, card}, arr -> :array.set(pos, card, arr) end)
    |> :array.to_list()
  end

  def exec(cards, "deal into new stack"), do: reverse(cards)
  def exec(cards, "cut " <> n) do
    n = String.to_integer(n)
    cut(cards, n)
  end
  def exec(cards, "deal with increment " <> n) do
    n = String.to_integer(n)
    deal(cards, n)
  end
end


defmodule Day22Part1 do
  @deck_size 10007

  def main() do
    initial_deck = 0..@deck_size-1 |> Enum.to_list()
    IO.stream(:stdio, :line)
    |> Stream.map(&String.trim/1)
    |> Enum.reduce(initial_deck, fn line, deck -> Deck.exec(deck, line) end)
    |> Enum.find_index(&Kernel.==(&1, 2019))
    |> IO.puts()
  end

end

Day22Part1.main()
