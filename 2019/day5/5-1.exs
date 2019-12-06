defmodule Instruction do
  # @type t :: %Instruction{opcode: atom(), }
  defstruct opcode: nil, input_arity: 0, output_arity: 0, function: nil

  def new(opcode, input_arity, output_arity, function) do
    %Instruction{opcode: opcode, input_arity: input_arity, output_arity: output_arity, function: function}
  end

  def get_param(memory, address, '1'), do: elem(memory, address)
  def get_param(memory, address, '0'), do: elem(memory, elem(memory, address))

  def exec(instruction, memory, address) do
    input_values = elem(memory, address)
    |> String.slice(0..-3)  # remove opcode
    |> String.pad_leading(instruction.input_arity, "0")
    |> String.slice(0..instruction.input_arity-1)  # output is always in address mode
    |> String.to_charlist()
    |> Enum.map(& get_param(memory, address, &1))
    outputs = apply(instruction.function, input_values)
  end
end

defmodule InstructionSet do
  defstruct instructions: %{}

  def new(), do: %InstructionSet{}

  def register(set, instruction) do
    instructions = Map.put(set.instructions, instruction.opcode, instruction)
    %InstructionSet{set | instructions: instructions}
  end

  def get(set, opcode), do: Map.get(set.instructions, opcode)
end

defmodule Computer do
  def run(_, memory, address) when address >= tuple_size(memory), do: memory
  def run(instructionset, memory, address) do
    opcode = elem(memory, address)
    |> String.slice(-2..-1)
    |> String.to_atom()
    instruction = InstructionSet.get(instructionset, opcode)
    output = Instruction.exec(instruction, memory, address)
    run(instructionset, memory, address + 2)
  end
end

defmodule Day5 do
  s = InstructionSet.new()
  |> InstructionSet.register(Instruction.new(:"01", 2, 1, &*/2))
  |> InstructionSet.register(Instruction.new(:"02", 2, 1, &+/2))
  |> InstructionSet.register(Instruction.new(:"03", 0, 1,
    fn -> IO.gets("Inserisci") |> String.trim() |> String.to_integer() end
  ))
  |> InstructionSet.register(Instruction.new(:"04", 1, 0, &IO.puts/1))
  Computer.run(s, {"03", "10", "04", "10"}, 0)
  # Computer.run(s)

end
