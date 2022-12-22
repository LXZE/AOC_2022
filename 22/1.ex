move = fn
	pos, "U" -> Map.update!(pos, :y, & &1-1)
	pos, "R" -> Map.update!(pos, :x, & &1+1)
	pos, "D" -> Map.update!(pos, :y, & &1+1)
	pos, "L" -> Map.update!(pos, :x, & &1-1)
end
turn = fn
	dir, nil -> dir
	"U", "L" -> "L"; "U", "R" -> "R"
	"R", "L" -> "U"; "R", "R" -> "D"
	"D", "L" -> "R"; "D", "R" -> "L"
	"L", "L" -> "D"; "L", "R" -> "U"
end

[map, cmds] = File.read!("input.txt") |> String.trim_trailing |> String.split("\n\n")
map = String.split(map, "\n")
max_r = length(map)
max_c = Enum.reduce(map, 0, fn row, acc -> max(acc, String.length(row)) end)
map = Enum.map(map, fn row -> String.pad_trailing(row, max_c, " ") |> String.graphemes end)
map_T = Enum.zip(map) |> Enum.map(&Tuple.to_list/1)

find_row_min = fn col -> Enum.find_index(map, fn row -> Enum.at(row, col) in [".", "#"] end) end
find_row_max = fn col -> max_r - Enum.find_index(Enum.reverse(map), fn row -> Enum.at(row, col) in [".", "#"] end) -1 end
find_col_min = fn row -> Enum.find_index(map_T, fn col -> Enum.at(col, row) in [".", "#"] end) end
find_col_max = fn row -> max_c - Enum.find_index(Enum.reverse(map_T), fn col -> Enum.at(col, row) in [".", "#"] end) -1 end

lookup_map = Enum.with_index(map)
|> Enum.map(fn {row, y_idx} ->
	Enum.with_index(row) |> Enum.map(fn {col, x_idx} -> {{x_idx, y_idx}, col} end)
end) |> List.flatten |> Map.new

get_pos_map = fn %{x: x, y: y} -> Map.get(lookup_map, {x, y}, " ") end
warp = fn
	pos, "U" -> Map.update!(pos, :y, fn _ -> find_row_max.(pos.x) end) # find max row that in col contains "." or "#"
	pos, "R" -> Map.update!(pos, :x, fn _ -> find_col_min.(pos.y) end) # find min col that in row contains "." or "#"
	pos, "D" -> Map.update!(pos, :y, fn _ -> find_row_min.(pos.x) end) # find min row that in col contains "." or "#"
	pos, "L" -> Map.update!(pos, :x, fn _ -> find_col_max.(pos.y) end) # find max row that in col contains "." or "#"
end

start_col = Enum.find_index(Enum.at(map, 0), fn col -> col == "." end)
init_state = %{pos: %{x: start_col, y: 0}, dir: "R"} # !! Don't forget to +1 at x and y as problem start at 1,1
val_from_dir = %{U: 3, R: 0, D: 1, L: 2}

Regex.scan(~r/(\d+[LRX]?)/, cmds <> "X", capture: :all_but_first) |> List.flatten
|> Enum.map(fn cmd -> %{
	walk: String.slice(cmd, 0..-2) |> String.to_integer,
	turn: if(String.contains?(String.at(cmd, -1), ["L", "R"]), do: String.at(cmd, -1)) # turn will be nil at last
} end)
|> Enum.reduce(init_state, fn cmd, state ->
	Enum.reduce_while(1..cmd.walk, state, fn _step, current_pos ->
		next_pos = move.(current_pos.pos, current_pos.dir)
		case get_pos_map.(next_pos) do
			"#" -> {:halt, current_pos}
			"." -> {:cont, Map.update!(current_pos, :pos, fn _ -> next_pos end)}
			" " ->
				next_pos = warp.(current_pos.pos, current_pos.dir)
				case get_pos_map.(next_pos) do
					"#" -> {:halt, current_pos}
					"." -> {:cont, Map.update!(current_pos, :pos, fn _ -> next_pos end)}
				end
		end
	end)
	|> Map.update!(:dir, fn cur_dir -> turn.(cur_dir, cmd.turn) end)
end)
|> then(fn %{dir: dir, pos: %{x: x, y: y}} ->
	(y+1) * 1000
	|> Kernel.+((x+1) * 4)
	|> Kernel.+(val_from_dir[String.to_atom(dir)])
end) |> IO.puts
