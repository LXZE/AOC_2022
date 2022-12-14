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

	def is_above_all(check_fn, {y, x}) do
		[{y-1, x-1}, {y-1, x}, {y-1, x+1}]
		|> Enum.all?(fn above -> check_fn.(above) end)
	end

	def solve(rocks) do
		base = Enum.max_by(rocks, &elem(&1, 0)) |> elem(0) |> Kernel.+(1)
		Enum.reduce(1..base, MapSet.new([{0, 500}]), fn y, acc ->
			Enum.reduce((500-y)..(500+y), acc, fn x, acc_sands ->
				cond do
					MapSet.member?(rocks, {y, x}) -> acc_sands
					is_above_all(&MapSet.member?(rocks, &1), {y, x}) -> acc_sands
					is_above_all(&(not MapSet.member?(acc_sands, &1)), {y, x}) -> acc_sands
					true -> MapSet.put(acc_sands, {y, x})
				end
			end)
		end)
		|> MapSet.size
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
