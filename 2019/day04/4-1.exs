defmodule Day4Part1 do

  def non_decreasing?(password) do
    digits = Integer.digits(password)
    Stream.zip(digits, Enum.drop(digits, 1))
      |> Stream.map(fn {a, b} -> a <= b end)
      |> Enum.all?()
  end

  def has_adjacent_pair?(password) do
    digits = Integer.digits(password)
    Stream.zip(digits, Enum.drop(digits, 1))
      |> Stream.map(fn {a, b} -> a == b end)
      |> Enum.any?()
  end

  def valid?(password) do
    non_decreasing?(password) and has_adjacent_pair?(password)
  end

  def main(from, to) do
      from..to
        |> Stream.map(&valid?/1)
        |> Enum.count(fn x -> x end)
  end

end

Day4Part1.main(246540, 787419) |> IO.puts()
