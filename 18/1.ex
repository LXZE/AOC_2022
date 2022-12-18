is_connect? = fn a, b ->
	Enum.sort([a.x - b.x, a.y - b.y, a.z - b.z]) in [[-1, 0, 0], [0, 0, 1]]
end

File.stream!("input.txt")
|> Enum.map(&String.trim_trailing/1)
|> Enum.map(&String.split(&1, ",") |> Enum.map(fn e -> String.to_integer(e) end))
|> Enum.map(fn [x,y,z] -> %{x: x, y: y,z: z} end)
|> Enum.map(&%{pos: &1, rem: 6})
|> Enum.reduce([], fn cube, acc ->
	%{connect: to_subtract, rem: cube_rem} = Enum.reduce(Enum.with_index(acc),
		%{connect: [], rem: 6},
		fn {prev, idx}, state ->
			case is_connect?.(prev.pos, cube.pos) do
				true -> update_in(state, [:rem], & &1-1)
					|> update_in([:connect], & &1 ++ [idx])
				false -> state
			end
		end)
	Enum.map(Enum.with_index(acc), fn {prev, idx} ->
		case idx in to_subtract do
			true -> update_in(prev.rem, & &1-1)
			false -> prev
		end
	end) ++ [update_in(cube, [:rem], fn _ -> cube_rem end)]
end)
|> Enum.map(& &1.rem) |> Enum.sum |> IO.puts
