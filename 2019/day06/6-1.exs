defmodule Tree do
  defstruct nodes: %{}

  def new(), do: %Tree{}

  def add_node(tree, parent, node) do
    parent_children = Map.get(tree.nodes, parent, [])
    new_nodes = Map.put(tree.nodes, parent, [node | parent_children])
    %Tree{tree | nodes: new_nodes}
  end

  defimpl Collectable do
    def into(original) do
      collector = fn
        tree, {:cont, {parent, node}} -> Tree.add_node(tree, parent, node)
        tree, :done -> tree
        tree, :halt -> tree
      end
      {original, collector}
    end
  end

  def bfs(tree, node) do
    Stream.unfold([node], fn
      [] -> nil
      [head] -> {head, Map.get(tree.nodes, head, [])}
      [head | tail] -> {head, tail ++ Map.get(tree.nodes, head, [])}
    end)
  end

  def orbit_count(tree, node, height) do
    c = Map.get(tree.nodes, node, [])
    |> Enum.reduce(0, fn node, total -> total + orbit_count(tree, node, height + 1) end)
    c + height
  end
end


defmodule Day6 do
  def main() do
    tree = for line <- IO.stream(:stdio, :line), into: Tree.new() do
      [parent, node] = line |> String.trim() |> String.split(")")
      {parent, node}
    end
    Tree.orbit_count(tree, "COM", 0) |> IO.puts()
  end
end

Day6.main()
