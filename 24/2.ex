defmodule Solver do
	def move_blizz({{r, c}, "^"}), do: {r-1, c}
	def move_blizz({{r, c}, ">"}), do: {r, c+1}
	def move_blizz({{r, c}, "v"}), do: {r+1, c}
	def move_blizz({{r, c}, "<"}), do: {r, c-1}

	def update_blizz(blizz, %{maxr: maxr, maxc: maxc}) do
		Enum.map(blizz, fn {pos, dir} ->
			case move_blizz({pos, dir}) do
				{0, c} -> {{maxr-1, c}, dir}
				{^maxr, c} -> {{1, c}, dir}
				{r, 0} -> {{r, maxc-1}, dir}
				{r, ^maxc} -> {{r, 1}, dir}
				new_pos -> {new_pos, dir}
			end
		end)
	end

	def new_position({r, c}, %{maxr: maxr, maxc: maxc, wall: wall}) do
		[{r, c}, {r-1, c}, {r, c+1}, {r+1, c}, {r, c-1}]
		|> Enum.filter(fn {r, c} -> r in 0..maxr and c in 0..maxc and {r, c} not in wall end)
	end

	def solve(player_poss, blizz, step, vars) do
		cond do
			vars.exit_pos in player_poss -> {step, blizz}
			true ->
				new_blizz = update_blizz(blizz, vars)
				invalid_pos = Enum.map(new_blizz, &elem(&1, 0)) |> MapSet.new
				new_poss = Enum.flat_map(player_poss, &new_position(&1, vars))
				|> Enum.reject(&MapSet.member?(invalid_pos, &1))
				|> Enum.uniq
				solve(new_poss, new_blizz, step+1, vars)
		end
	end
end

map = File.stream!("input.txt")
|> Enum.map(&(String.trim(&1) |> String.graphemes))

start_pos = {0, 1}
exit_pos = {length(map)-1, Enum.find_index(Enum.at(map, -1), & &1==".")}

indexed_map = Enum.with_index(map) |> Enum.flat_map(fn {row, ridx} ->
	Enum.with_index(row) |> Enum.map(fn {item, cidx} -> {{ridx, cidx}, item} end)
end)
filter = fn map, to_chk ->
	Enum.filter(map, fn {_, val} -> String.contains?(val, to_chk) end)
end
blizz = filter.(indexed_map, ["^", ">", "v", "<"])
wall = filter.(indexed_map, "#") |> Enum.map(&elem(&1, 0)) |> MapSet.new

maxr = length(map)-1
maxc = length(Enum.at(map, 1))-1

vars = %{maxr: maxr, maxc: maxc, exit_pos: exit_pos, wall: wall}
{step1, blizz} = Solver.solve([start_pos], blizz, 0, %{vars | exit_pos: exit_pos})
{step2, blizz} = Solver.solve([exit_pos], blizz, 0, %{vars | exit_pos: start_pos})
{step3, _} = Solver.solve([start_pos], blizz, 0, %{vars | exit_pos: exit_pos})
IO.puts(step1 + step2 + step3)
