defmodule Shuffling do
  @moduledoc """
  Optimized implementation of the deck shuffling that just
  treats the operations as modular linear functions,
  and returns the coefficients.
  This way, they can be easily composed
  """

  def reverse(size), do: {-1, size-1}
  def cut(_size, n), do: {1, -n}
  def deal(_size, n), do: {n, 0}
  def undo_reverse(size), do: reverse(size)
  def undo_cut(_size, n), do: {1, n}
  def undo_deal(size, n), do: {ModularArithmetic.inverse(n, size), 0}

  def exec(size, "deal into new stack") do
    reverse(size)
  end
  def exec(size, "cut " <> n) do
    n = String.to_integer(n)
    cut(size, n)
  end
  def exec(size, "deal with increment " <> n) do
    n = String.to_integer(n)
    deal(size, n)
  end
  def undo_exec(size, "deal into new stack") do
    undo_reverse(size)
  end
  def undo_exec(size, "cut " <> n) do
    n = String.to_integer(n)
    undo_cut(size, n)
  end
  def undo_exec(size, "deal with increment " <> n) do
    n = String.to_integer(n)
    undo_deal(size, n)
  end
end


defmodule ModularArithmetic do
  def inverse(n, modulo) do
    {_, _, _, _, _, tb} = extended_euclidean(modulo, n, 1, 0, 0, 1)
    tb
  end

  @doc """
  Fast implementation of b^e (mod m) using exponentiation-by-squaring
  (aka binary exponentiation)
  """
  def pow(b, 1, m), do: rem(b, m)
  def pow(b, e, m) when rem(e, 2) == 0 do
    pow(rem(b*b, m) , div(e, 2), m) |> rem(m)
  end
  def pow(b, e, m) when rem(e, 2) == 1 do
    r = b * pow(b, e-1, m)
    rem(r, m)
  end

  def geometric_sum(base, terms, modulo) do
    numerator = pow(base, terms, modulo) - 1
    denominator = base - 1
    invden = inverse(denominator, modulo)
    Integer.mod(numerator * invden, modulo)
  end

  defp extended_euclidean(a, b, sa, sb, ta, tb) when rem(a, b) == 0 do
    {a, b, sa, sb, ta, tb}
  end

  defp extended_euclidean(a, b, sa, sb, ta, tb) do
    q = div(a, b)
    extended_euclidean(b, a - q*b, sb, sa - q*sb, tb, ta - q*tb)
  end

end


defmodule Day22Part2 do
  @position 2020
  @size 119315717514047
  @iterations 101741582076661

  def main() do
    # Coefficients after applying the entire shuffling procedure once
    {m, a} = IO.stream(:stdio, :line)
    |> Stream.map(&String.trim/1)
    |> Enum.reverse()
    |> Enum.reduce({1, 0}, fn command, {mul, add} ->
      {m, a} = Shuffling.undo_exec(@size, command)
      {Integer.mod(mul * m, @size), Integer.mod(add * m + a, @size)}
    end)

    # Calculate coefficient of applying it @iterations times
    # using modular arithmetic and squaring
    a = Integer.mod(a * ModularArithmetic.geometric_sum(m, @iterations, @size), @size)
    m = ModularArithmetic.pow(m, @iterations, @size)

    result = Integer.mod(@position * m + a, @size)
    IO.puts("Card at position #{@position} is #{result}")
  end

end

Day22Part2.main()

