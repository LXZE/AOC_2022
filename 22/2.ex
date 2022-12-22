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
max_c = Enum.reduce(map, 0, fn row, acc -> max(acc, String.length(row)) end)
map = Enum.map(map, fn row -> String.pad_trailing(row, max_c, " ") |> String.graphemes end)

lookup_map = Enum.with_index(map)
|> Enum.map(fn {row, y_idx} ->
	Enum.with_index(row) |> Enum.map(fn {col, x_idx} -> {{x_idx, y_idx}, col} end)
end) |> List.flatten |> Map.new

get_pos_map = fn %{x: x, y: y} -> Map.get(lookup_map, {x, y}, " ") end

# !!WARNING!!
# this zone finding works with actual input data only, not the test case
get_zone = fn %{x: x, y: y} -> cond do
	y in 0..49 and x in 50..99 -> 1
	y in 0..49 and x in 100..149 -> 2
	y in 50..99 and x in 50..99 -> 3
	y in 100..149 and x in 50..99 -> 4
	y in 100..149 and x in 0..49 -> 5
	y in 150..199 and x in 0..49 -> 6
end end

# params
# - current depended position in range_from
# - range_from for reference
# - range_to to find where to go from calculated index
get_warp_pos = fn pos, range_from, range_to ->
	Enum.find_index(range_from, & &1 == pos)
	|> (fn idx -> Enum.at(range_to, idx) end).()
end

warp = fn pos, dir ->
	cond do
		# zone 1 L = to zone 5
		get_zone.(pos) == 1 and dir == "L" ->
			{%{x: 0, y: get_warp_pos.(pos.y, 0..49, 149..100)}, "R"}
		# zone 1 U = to zone 6
		get_zone.(pos) == 1 and dir == "U" ->
			{%{x: 0, y: get_warp_pos.(pos.x, 50..99, 150..199)}, "R"}
		# zone 2 U = to zone 6
		get_zone.(pos) == 2 and dir == "U" ->
			{%{x: get_warp_pos.(pos.x, 100..149, 0..49), y: 199}, "U"}
		# zone 2 R = to zone 4
		get_zone.(pos) == 2 and dir == "R" ->
			{%{x: 99, y: get_warp_pos.(pos.y, 0..49, 149..100)}, "L"}
		# zone 2 D = to zone 3
		get_zone.(pos) == 2 and dir == "D" ->
			{%{x: 99, y: get_warp_pos.(pos.x, 100..149, 50..99)}, "L"}
		# zone 3 L = to zone 5
		get_zone.(pos) == 3 and dir == "L" ->
			{%{x: get_warp_pos.(pos.y, 50..99, 0..49), y: 100}, "D"}
		# zone 3 R = to zone 2
		get_zone.(pos) == 3 and dir == "R" ->
			{%{x: get_warp_pos.(pos.y, 50..99, 100..149), y: 49}, "U"}
		# zone 4 R = to zone 2
		get_zone.(pos) == 4 and dir == "R" ->
			{%{x: 149, y: get_warp_pos.(pos.y, 100..149, 49..0)}, "L"}
		# zone 4 D = to zone 6
		get_zone.(pos) == 4 and dir == "D" ->
			{%{x: 49, y: get_warp_pos.(pos.x, 50..99, 150..199)}, "L"}
		# zone 5 U = to zone 3
		get_zone.(pos) == 5 and dir == "U" ->
			{%{x: 50, y: get_warp_pos.(pos.x, 0..49, 50..99)}, "R"}
		# zone 5 L = to zone 1
		get_zone.(pos) == 5 and dir == "L" ->
			{%{x: 50, y: get_warp_pos.(pos.y, 100..149, 49..0)}, "R"}
		# zone 6 R = to zone 4
		get_zone.(pos) == 6 and dir == "R" ->
			{%{x: get_warp_pos.(pos.y, 150..199, 50..99), y: 149}, "U"}
		# zone 6 D = to zone 2
		get_zone.(pos) == 6 and dir == "D" ->
			{%{x: get_warp_pos.(pos.x, 0..49, 100..149), y: 0}, "D"}
		# zone 6 L = to zone 1
		get_zone.(pos) == 6 and dir == "L" ->
			{%{x: get_warp_pos.(pos.y, 150..199, 50..99), y: 0}, "D"}
	end
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
				{next_pos, next_dir} = warp.(current_pos.pos, current_pos.dir)
				case get_pos_map.(next_pos) do
					"#" -> {:halt, current_pos}
					"." -> {:cont,
						Map.update!(current_pos, :pos, fn _ -> next_pos end)
						|> Map.update!(:dir, fn _ -> next_dir end)
					}
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

# test case for each zone
# zone 1 L
# warp.(%{x: 50, y: 0}, "L") |> dbg
# warp.(%{x: 50, y: 1}, "L") |> dbg
# warp.(%{x: 50, y: 48}, "L") |> dbg
# warp.(%{x: 50, y: 49}, "L") |> dbg
# zone 1 U
# warp.(%{x: 50, y: 0}, "U") |> dbg
# warp.(%{x: 51, y: 0}, "U") |> dbg
# warp.(%{x: 98, y: 0}, "U") |> dbg
# warp.(%{x: 99, y: 0}, "U") |> dbg
# zone 2 U
# warp.(%{x: 100, y: 0}, "U") |> dbg
# warp.(%{x: 101, y: 0}, "U") |> dbg
# warp.(%{x: 148, y: 0}, "U") |> dbg
# warp.(%{x: 149, y: 0}, "U") |> dbg
# zone 2 R
# warp.(%{x: 149, y: 0}, "R") |> dbg
# warp.(%{x: 149, y: 1}, "R") |> dbg
# warp.(%{x: 149, y: 48}, "R") |> dbg
# warp.(%{x: 149, y: 49}, "R") |> dbg
# zone 2 D
# warp.(%{x: 100, y: 49}, "D") |> dbg
# warp.(%{x: 101, y: 49}, "D") |> dbg
# warp.(%{x: 148, y: 49}, "D") |> dbg
# warp.(%{x: 149, y: 49}, "D") |> dbg
# zone 3 L
# warp.(%{x: 50, y: 50}, "L") |> dbg
# warp.(%{x: 50, y: 51}, "L") |> dbg
# warp.(%{x: 50, y: 98}, "L") |> dbg
# warp.(%{x: 50, y: 99}, "L") |> dbg
# zone 3 R
# warp.(%{x: 99, y: 50}, "R") |> dbg
# warp.(%{x: 99, y: 51}, "R") |> dbg
# warp.(%{x: 99, y: 98}, "R") |> dbg
# warp.(%{x: 99, y: 99}, "R") |> dbg
# zone 4 R
# warp.(%{x: 99, y: 100}, "R") |> dbg
# warp.(%{x: 99, y: 101}, "R") |> dbg
# warp.(%{x: 99, y: 148}, "R") |> dbg
# warp.(%{x: 99, y: 149}, "R") |> dbg
# zone 4 D
# warp.(%{x: 50, y: 149}, "D") |> dbg
# warp.(%{x: 51, y: 149}, "D") |> dbg
# warp.(%{x: 98, y: 149}, "D") |> dbg
# warp.(%{x: 99, y: 149}, "D") |> dbg
# zone 5 U
# warp.(%{x: 0, y: 100}, "U") |> dbg
# warp.(%{x: 1, y: 100}, "U") |> dbg
# warp.(%{x: 48, y: 100}, "U") |> dbg
# warp.(%{x: 49, y: 100}, "U") |> dbg
# zone 5 L
# warp.(%{x: 0, y: 100}, "L") |> dbg
# warp.(%{x: 0, y: 101}, "L") |> dbg
# warp.(%{x: 0, y: 148}, "L") |> dbg
# warp.(%{x: 0, y: 149}, "L") |> dbg
# zone 6 R
# warp.(%{x: 49, y: 150}, "R") |> dbg
# warp.(%{x: 49, y: 151}, "R") |> dbg
# warp.(%{x: 49, y: 198}, "R") |> dbg
# warp.(%{x: 49, y: 199}, "R") |> dbg
# zone 6 D
# warp.(%{x: 0, y: 199}, "D") |> dbg
# warp.(%{x: 1, y: 199}, "D") |> dbg
# warp.(%{x: 48, y: 199}, "D") |> dbg
# warp.(%{x: 49, y: 199}, "D") |> dbg
# zone 6 L
# warp.(%{x: 0, y: 150}, "L") |> dbg
# warp.(%{x: 0, y: 151}, "L") |> dbg
# warp.(%{x: 0, y: 198}, "L") |> dbg
# warp.(%{x: 0, y: 199}, "L") |> dbg
