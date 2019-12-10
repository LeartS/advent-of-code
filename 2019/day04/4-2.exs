defmodule Day4Part1 do

  def non_decreasing?(password) do
    digits = Integer.digits(password)
    Stream.zip(digits, Enum.drop(digits, 1))
      |> Stream.map(fn {a, b} -> a <= b end)
      |> Enum.all?()
  end

  def split_in_groups(list) do
    List.foldr(list, [], fn
      x, [] -> [{x, 1}]
      x, [{e, count} | tail] when x == e -> [{e, count + 1} | tail]
      x, acc -> [{x, 1} | acc]
    end)
  end

  def has_adjacent_pair?(password) do
    password
      |> Integer.digits()
      |> split_in_groups
      |> Enum.any?(fn {_, count} -> count == 2 end)
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
