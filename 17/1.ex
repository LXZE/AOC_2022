_draw = fn list_pos ->
	max_y = Enum.max_by(list_pos, &elem(&1, 1)) |> elem(1)
	for y <- max_y..-1//-1 do
		Enum.reduce(0..6, "", fn x, acc ->
			acc <> if {x, y} in list_pos, do: "#", else: "."
		end)
		|> IO.puts
	end
	IO.puts("__________________________________________")
end

jets = File.read!("input.txt")
|> String.trim_trailing |> String.graphemes
|> Stream.cycle

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

room = 0..6 |> Enum.map(& {&1, -1}) |> MapSet.new
init_state = %{at: %{jet_idx: 0, rock_idx: 0, y: -1}, room: room}
Enum.reduce(1..2022, init_state, fn _, state ->
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

	max_y = Enum.max_by(new_rock, &elem(&1, 1)) |> elem(1)
	update_in(state, [:at, :rock_idx], & &1+1)
	|> update_in([:at, :jet_idx], fn _ -> new_jet_idx end)
	|> update_in([:at, :y], &max(&1, max_y))
	|> update_in([:room], &MapSet.union(&1, MapSet.new(new_rock)))
end)
# |> (& &1.room).()
# |> draw.()
|> (& &1.at.y + 1).()
|> IO.puts
