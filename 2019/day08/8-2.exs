defmodule Day8Part1 do
  @layer_width 25
  @layer_height 6

  def merge_layers(l1, l2) do
    Stream.zip(l1, l2)
    |> Enum.map(fn {l1px, l2px} -> if l1px == ?2, do: l2px, else: l1px end)
  end
  def merge_layers([l]), do: l
  def merge_layers([l1, l2 | tail]) do
    merge_layers([merge_layers(l1, l2) | tail])
  end

  def render_px(?2), do: ' '
  def render_px(?1), do: '■'
  def render_px(?0), do: '□'

  def print(image) do
    image
    |> Stream.map(&render_px/1)
    |> Stream.chunk_every(@layer_width)
    |> Stream.map(&to_string/1)
    |> Enum.map(&IO.puts/1)
  end

  def main() do
    layers = IO.read(:all)
    |> String.trim()
    |> String.to_charlist()
    |> Enum.chunk_every(@layer_height * @layer_width)
    merge_layers(layers)
    |> print()
  end

end

Day8Part1.main()

