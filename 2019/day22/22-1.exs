defmodule Deck do
  @moduledoc """
  Real implementation of the deck shuffling algorithms,
  operates on the whole deck (list of cards)
  """

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


defmodule DeckOptimized do
  @moduledoc """
  Optimized implementation of the deck shuffling that just simulates
  where a card in a specific position ends ups after the step.
  """

  def reverse(size, position) do
    (position * -1) + (size - 1)
  end

  def cut(size, position, n) do
    Integer.mod(position - n, size)
  end

  def deal(size, position, n) do
    Integer.mod(position * n, size)
  end

  def exec(size, position, "deal into new stack"), do: reverse(size, position)
  def exec(size, position, "cut " <> n) do
    n = String.to_integer(n)
    cut(size, position, n)
  end
  def exec(size, position, "deal with increment " <> n) do
    n = String.to_integer(n)
    deal(size, position, n)
  end
end


defmodule Day22Part1 do
  @starting_position 2019
  @deck_size 10007

  def solve_trivial(commands) do
    initial_deck = 0..@deck_size-1 |> Enum.to_list()

    commands
    |> Enum.reduce(initial_deck, fn line, deck -> Deck.exec(deck, line) end)
    |> Enum.find_index(&Kernel.==(&1, @starting_position))
  end

  def solve_optimized(commands) do
    commands
    |> Enum.reduce(
      @starting_position,
      fn command, position ->
        DeckOptimized.exec(@deck_size, position, command)
      end
    )
  end

  def main() do
    initial_deck = 0..@deck_size-1 |> Enum.to_list()
    commands = IO.stream(:stdio, :line)
    |> Stream.map(&String.trim/1)
    solve_trivial(commands)
    # solve_optimized(commands)
    |> IO.puts()
  end

end

Day22Part1.main()
