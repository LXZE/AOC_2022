defmodule Solver do
	def direction(a, b) when a < b, do: 1
	def direction(_, _), do: -1
	def get_range({ax, ay}, {bx, by}) when ax == bx do
		Range.new(ay, by, direction(ay, by))
		|> Enum.map(&{ax, &1})
	end
	def get_range({ax, ay}, {bx, by}) when ay == by do
		Range.new(ax, bx, direction(ax, bx))
		|> Enum.map(&{&1, ay})
	end

	def solve(rocks) do
		abyss = Enum.max_by(rocks, &elem(&1, 0)) |> elem(0) |> Kernel.+(1)
		Stream.repeatedly(fn -> {0, 500} end)
		|> Enum.reduce_while(MapSet.new(), fn pos, sands ->
			case find_end_pos(pos, rocks, sands, abyss) do
				{:stop, _} -> {:halt, sands}
				{:ok, end_pos} -> {:cont, MapSet.put(sands, end_pos)}
			end
		end)
		|> MapSet.size
	end

	def find_end_pos({y, x}, rocks, sands, abyss) do
		case y == abyss do
			true -> {:stop, nil}
			_ ->
				blockers = MapSet.union(rocks, sands)
				next_pos = [{y+1, x}, {y+1, x-1}, {y+1, x+1}]
				|> Enum.find_value(fn next_pos ->
					if not MapSet.member?(blockers, next_pos), do: next_pos
				end)
				case next_pos do
					nil -> {:ok, {y, x}}
					_ -> find_end_pos(next_pos, rocks, sands, abyss)
				end
		end
	end
end

File.stream!("input.txt")
|> Enum.map(&String.trim/1)
|> Enum.map(&String.split(&1, " -> "))
|> Enum.map(fn rock ->
	Enum.map(rock, fn paths ->
		String.split(paths, ",")
		|> Enum.map(&String.to_integer/1)
		|> (fn [hrz, vtc] -> {vtc, hrz} end).()
	end)
end)
|> Enum.reduce(MapSet.new(), fn rock, acc ->
	Enum.chunk_every(rock, 2, 1, :discard)
	|> Enum.flat_map(fn [from, to] ->
		Solver.get_range(from, to)
	end) |> Enum.uniq()
	|> Enum.reduce(acc, fn pos, acc ->
		MapSet.put(acc, pos)
	end)
end)
|> Solver.solve |> IO.puts
