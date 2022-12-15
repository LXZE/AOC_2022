gen_row = fn
	pos, pad_size when pad_size == 0 -> [pos]
	{x, y}, pad_size ->
		Enum.map((x-pad_size)..(x+pad_size), & {&1, y})
end

gen_map = fn {sx, sy}, {bx, by}, select_row ->
	dist = abs(sx - bx) + abs(sy - by)
	case select_row in (sy-dist)..(sy+dist) do
		false -> []
		true ->
			cond do
				select_row < sy ->
					offset_y = sy - select_row
					gen_row.({sx, sy - offset_y}, dist - offset_y) -- [{bx, by}]
				select_row == sy ->
					gen_row.({sx, sy}, dist) -- [{sx, sy}, {bx, by}]
				select_row > sy ->
					offset_y = select_row - sy
					gen_row.({sx, sy + offset_y}, dist - offset_y) -- [{bx, by}]
			end
	end
end

target = 2000000
File.stream!("input.txt")
|> Enum.map(&String.trim/1)
|> Enum.map(fn row ->
	Regex.scan(~r/(-?\d+)/, row, capture: :all_but_first)
	|> List.flatten
	|> Enum.map(&String.to_integer/1)
	|> Enum.chunk_every(2)
	|> Enum.map(&List.to_tuple/1)
end)
|> Enum.map(fn [sensor, beacon] ->
	gen_map.(sensor, beacon, target)
end)
|> List.flatten |> Enum.uniq |> length |> IO.puts
