defmodule Tree do
  defstruct nodes: %{}

  def new(), do: %Tree{}

  def add_node(tree, parent, node) do
    new_nodes = Map.put(tree.nodes, node, parent)
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

  def path_to_root(tree, node) do
    case Map.fetch(tree.nodes, node) do
      {:ok, parent} -> [node | path_to_root(tree, parent)]
      :error -> [node]
    end
  end

  def shortest_path(tree, from, to) do
    path1 = Tree.path_to_root(tree, from) |> Enum.reverse()
    path2 = Tree.path_to_root(tree, to) |> Enum.reverse()
    shared_path = Enum.zip(path1, path2)
    |> Enum.take_while(fn {a, b} -> a == b end)
    |> Enum.map(fn {a, _b} -> a end)
    length(path1) + length(path2) - 2 * length(shared_path) - 2
  end
end


defmodule Day6 do
  def main() do
    tree = for line <- IO.stream(:stdio, :line), into: Tree.new() do
      [parent, node] = line |> String.trim() |> String.split(")")
      {parent, node}
    end
    Tree.shortest_path(tree, "YOU", "SAN") |> IO.inspect()
  end
end

Day6.main()
