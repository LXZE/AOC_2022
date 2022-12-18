is_connect? = fn a, b ->
	Enum.sort([a.x - b.x, a.y - b.y, a.z - b.z]) in [[-1, 0, 0], [0, 0, 1]]
end

surrounded = fn %{x: x, y: y, z: z} ->
	[ 	%{x: x-1,y: y,  z: z},   %{x: x+1,y: y,  z: z},
		%{x: x,  y: y-1,z: z},   %{x: x,  y: y+1,z: z},
		%{x: x,  y: y,  z: z-1}, %{x: x,  y: y,  z: z+1}]
end

surface_calculate_fn = fn cube, acc ->
	%{connect: to_subtract, rem: cube_rem} = Enum.reduce(Enum.with_index(acc),
		%{connect: [], rem: surrounded.(cube.pos)},
		fn {prev, idx}, state ->
			case is_connect?.(prev.pos, cube.pos) do
				true -> update_in(state, [:rem], & &1 -- [prev.pos])
					|> update_in([:connect], & &1 ++ [idx])
				false -> state
			end
		end)
	Enum.map(Enum.with_index(acc), fn {prev, idx} ->
		case idx in to_subtract do
			true -> update_in(prev.rem, & &1 -- [cube.pos])
			false -> prev
		end
	end) ++ [update_in(cube, [:rem], fn _ -> cube_rem end)]
end

rocks = File.stream!("input.txt")
|> Enum.map(&String.trim_trailing/1)
|> Enum.map(&String.split(&1, ",") |> Enum.map(fn e -> String.to_integer(e) end))
|> Enum.map(fn [x,y,z] -> %{pos: %{x: x, y: y,z: z}} end)
|> Enum.reduce([], surface_calculate_fn)
rocks_pos = Enum.map(rocks, & &1.pos) |> MapSet.new
{dmin, dmax} = Enum.reduce(rocks_pos, {0, -1}, fn rock, acc -> {
	min(elem(acc, 0), Enum.min(Map.values(rock))),
	max(elem(acc, 1), Enum.max(Map.values(rock)))
} end)
world_range = dmin..dmax
world = for x <- world_range, y <- world_range, z <- world_range,
	into: [], do: %{x: x, y: y, z: z}
is_valid? = fn pos -> Enum.all?(Stream.map(Map.values(pos), & &1 in world_range)) end
init_state = %{queue: [%{x: 0, y: 0, z: 0}], cache: MapSet.new()}
# flood world
water = Stream.resource(
	fn -> init_state end,
	fn state when state.queue == [] -> {:halt, nil}
		state ->
			Map.update!(state, :queue, fn current_queue ->
				Enum.map(current_queue, &surrounded.(&1))
				|> List.flatten |> Enum.uniq
				|> Enum.filter(& is_valid?.(&1))
				|> Enum.reject(fn pos ->
					pos in state.cache or pos in rocks_pos
				end)
			end)
			|> Map.update!(:cache, &MapSet.union(&1, MapSet.new(state.queue)))
			|> (&{[state.queue], &1}).()
	end, & &1)
|> Enum.reduce(MapSet.new(), fn found, flooded ->
	MapSet.union(flooded, MapSet.new(found))
end)

rock_surface = Enum.map(rocks, &length(&1.rem)) |> Enum.sum

air_surface = (world -- MapSet.to_list(water))
|> Kernel.--(MapSet.to_list(rocks_pos))
|> Enum.map(fn e -> %{pos: e} end)
|> Enum.reduce([], surface_calculate_fn)
|> Enum.map(&length(&1.rem)) |> Enum.sum

IO.puts(rock_surface - air_surface)
