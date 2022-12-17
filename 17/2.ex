raw_jets = File.read!("input.txt")
|> String.trim_trailing |> String.graphemes
jets = raw_jets |> Stream.cycle
len_jets = length(raw_jets)

rocks = [
	fn {x, y} -> [{x, y}, {x+1, y}, {x+2, y}, {x+3, y}] end, # -
	fn {x, y} -> [{x+1, y}, {x, y+1}, {x+1, y+1}, {x+2, y+1}, {x+1, y+2}] end, # +
	fn {x, y} -> [{x, y}, {x+1, y}, {x+2, y}, {x+2, y+1}, {x+2, y+2}] end, # mirrored L
	fn {x, y} -> [{x, y}, {x, y+1}, {x, y+2}, {x, y+3}] end, # |
	fn {x, y} -> [{x, y}, {x+1, y}, {x, y+1}, {x+1, y+1}] end, # square
] |> Stream.cycle

is_collapse? = fn room, rock -> MapSet.disjoint?(room, MapSet.new(rock)) end
move_left = fn rock_pos, room ->
	case Enum.any?(for {x, _} <- rock_pos, do: x == 0) do
		true -> rock_pos
		false ->
			moved_rock = Enum.map(rock_pos, fn {x, y} -> {x-1, y} end)
			if is_collapse?.(room, moved_rock), do: moved_rock, else: rock_pos
	end
end
move_right = fn rock_pos, room ->
	case Enum.any?(for {x, _} <- rock_pos, do: x >= 6) do
		true -> rock_pos
		false ->
			moved_rock = Enum.map(rock_pos, fn {x, y} -> {x+1, y} end)
			if is_collapse?.(room, moved_rock), do: moved_rock, else: rock_pos
	end
end
move_down = fn rock_pos, room ->
	moved_rock = Enum.map(rock_pos, fn {x, y} -> {x, y-1} end)
	if is_collapse?.(room, moved_rock), do: moved_rock, else: rock_pos
end

target_rock = 1_000_000_000_000
room = 0..6 |> Enum.map(& {&1, -1}) |> MapSet.new
init_state = %{at: %{jet_idx: 0, rock_idx: 0, y: -1}, room: room, cache: Map.new()}

calculate_state_fn = fn _, state ->
	rock = Enum.at(rocks, state.at.rock_idx) |> apply([{2, state.at.y+4}])
	state_to_change = %{jet_idx: state.at.jet_idx, room: state.room, rock: rock}
	%{jet_idx: new_jet_idx, rock: new_rock} = Stream.repeatedly(fn -> nil end)
	|> Enum.reduce_while(state_to_change, fn _, fall_state ->
		# push by jet
		jet_direction = Enum.at(jets, fall_state.jet_idx)
		new_fall_state = update_in(fall_state, [:jet_idx], & &1+1)
		push_result = case jet_direction do
			">" -> move_right.(fall_state.rock, fall_state.room)
			"<" -> move_left.(fall_state.rock, fall_state.room)
		end
		# fall down
		fall_result =  move_down.(push_result, fall_state.room)
		new_fall_state = update_in(new_fall_state, [:rock], fn _ -> fall_result end)
		# check if stop
		case fall_result == push_result do
			true -> {:halt, new_fall_state}
			false -> {:cont, new_fall_state}
		end
	end)

	step = {rem(state.at.jet_idx + 1, len_jets), rem(state.at.rock_idx + 1, 5)}
	new_cache = Map.update(state.cache, step,
		[{state.at.y+1, state.at.rock_idx}],
		& &1 ++ [{state.at.y+1, state.at.rock_idx}])

	max_y = Enum.max_by(new_rock, &elem(&1, 1)) |> elem(1)
	res = update_in(state, [:at, :rock_idx], & &1+1)
	|> update_in([:at, :jet_idx], fn _ -> new_jet_idx end)
	|> update_in([:at, :y], &max(&1, max_y))
	|> update_in([:room], &MapSet.union(&1, MapSet.new(new_rock)))
	|> update_in([:cache], fn _ -> new_cache end)

	case Map.has_key?(res.cache, step) and length(res.cache[step]) == 3 do
		false -> {:cont, res}
		true ->
			{result, calculated_row} = res.cache[step]
			|> Enum.slice(-2..-1)
			|> (fn [{y1, rock1}, {y2, rock2}] ->
				calculated_row = div(target_rock - rock1, rock2 - rock1) # cycle amnt
				result = calculated_row
				|> Kernel.*(y2 - y1) # tallness per cycle
				|> Kernel.+(y1) # add height before cycle
				# calculate target_rock (for finding remain loop)
				{result, calculated_row * (rock2 - rock1) + rock1}
			end).()
			{:halt, {res, result, calculated_row}}
	end
end

{cycle_state, cycle_result, calculated_row} = Stream.repeatedly(fn -> nil end)
|> Enum.reduce_while(init_state, calculate_state_fn)

cycle_state = Map.put(cycle_state, :cache, Map.new())
final_state = Enum.reduce_while((calculated_row+1)..target_rock, # loop for remain rock
	cycle_state, calculate_state_fn)
extra_y = final_state.at.y - cycle_state.at.y
# plus 1 as y from state isn't tallness but y position
IO.puts(cycle_result + (extra_y + 1))
