Mix.install([:libgraph])
map = File.read!("input.txt")
|> String.trim |> String.split("\n")
|> Enum.map(fn row ->
	String.to_charlist(row)
	|> Enum.with_index(& {&2, &1}) |> Map.new
end)
|> Enum.with_index(& {&2, &1}) |> Map.new
max_row = Map.keys(map) |> length
max_col = Map.keys(map[0]) |> length

find_pos = fn map, target ->
	Enum.find_value(map, fn {idx_row, row} ->
		Enum.find_value(row, fn {idx_col, val} ->
			if val == target, do: {idx_row, idx_col}
		end)
	end)
end

start_pos = find_pos.(map, ?S)
end_pos = find_pos.(map, ?E)
map = put_in(map, Tuple.to_list(start_pos), ?a)
	|> put_in(Tuple.to_list(end_pos), ?z)

g = Enum.reduce(0..(max_row-1), Graph.new, fn r, acc ->
	Enum.reduce(0..(max_col-1), acc, fn c, g ->
		[{r-1, c}, {r+1, c}, {r, c-1} ,{r, c+1}]
			|> Enum.filter(fn {new_r, new_c} ->
				new_r in 0..(max_row-1) and new_c in 0..(max_col-1)
				and map[new_r][new_c]-1 <= map[r][c]
			end)
			|> Enum.reduce(g, fn reachable_pos, acc_g ->
				Graph.add_edge(acc_g, {r, c}, reachable_pos)
			end)
	end)
end)
Graph.dijkstra(g, start_pos, end_pos)
|> length |> Kernel.-(1)
|> IO.puts
