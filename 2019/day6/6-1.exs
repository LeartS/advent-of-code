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
      [head] -> {head, Map.get(tree, head, [])}
      [head | tail] -> {head, [tail | Map.get(tree, head, [])]}
    end)
  end

end


defmodule Day6 do
  def main() do
    tree = for line <- IO.stream(:stdio, :line), into: Tree.new() do
      [parent, node] = line |> String.trim() |> String.split(")")
      {parent, node}
    end
    b = Tree.bfs(tree, "COM") |> Enum.to_list()
    IO.inspect(tree.nodes)
    IO.inspect(b)
  end
end

Day6.main()
