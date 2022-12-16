nodes = File.stream!("input.txt")
|> Enum.map(fn row ->
	[valve | target] = Regex.scan(~r/([A-Z]{2})/, row, capture: :all_but_first)
		|> List.flatten
	flow_rate = Regex.scan(~r/(\d+)/, row, capture: :all_but_first)
	|> List.flatten |> Enum.at(0) |> String.to_integer
	Map.new([{valve, %{flow: flow_rate, next: target, is_opened: false}}])
end)
|> Enum.reduce(%{}, fn map, acc -> Map.merge(acc, map) end)

# node that increase flow rate or not just being a path (edge != 2)
special_nodes = for {k, d} <- nodes, d.flow > 0 or length(d.next) != 2, do: k

# generate length between each special node
follow_path = fn node, next ->
	# follow the way of destination node until found another special node
	Stream.iterate([next, node], fn [h | t] ->
		if h not in special_nodes, do: [hd(nodes[h].next -- t), h | t]
	end)
	|> Enum.take_while(& &1) |> List.last
end
pair_node_len = for node <- special_nodes, dest <- nodes[node].next, into: %{} do
	[end_node | path] = follow_path.(node, dest)
	{{node, end_node}, length(path)}
end
gen_pairs = fn known_distances ->
	for {l, dist_l} <- known_distances,
		{r, dist_r} <- known_distances, l != r,
		MapSet.intersection(l, r) |> MapSet.size() == 1,
		new_pair = MapSet.difference(MapSet.union(l, r), MapSet.intersection(l, r)),
		not is_map_key(known_distances, new_pair) do
		{new_pair, dist_l + dist_r}
	end
	|> Enum.uniq |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
	|> Map.new(fn {pair, distance} -> {pair, Enum.min(distance)} end)
	|> Map.merge(known_distances)
end
initial = for {pair, length} <- pair_node_len,
	into: %{}, do: {MapSet.new(Tuple.to_list(pair)), length}
all_distances_from = Stream.repeatedly(fn -> nil end)
|> Enum.reduce_while(initial, fn _, pair_dist ->
	case gen_pairs.(pair_dist) do
		^pair_dist -> {:halt, pair_dist}
		updated_pair -> {:cont, updated_pair}
	end
end)
|> Enum.flat_map(fn {pair, distance} ->
	[left, right] = Enum.to_list(pair)
	[{left, right, distance}, {right, left, distance}]
end)
|> Enum.reduce(%{}, fn {left, right, distance}, acc ->
	Map.update(acc, left, %{right => distance}, &Map.put(&1, right, distance))
end)

solve = fn max_time ->
	init_state = %{path: ["AA"], time: max_time, flow: 0, total: 0}
	queue = :queue.new() |> (&:queue.in(init_state, &1)).()
	Stream.resource(
		fn -> queue end,
		fn queue ->
			case :queue.out(queue) do
				{:empty, _} -> {:halt, nil}
				{{:value, current_state}, next_queue} ->
					%{path: [current_node | traversed_nodes], time: current_time} = current_state
					# dbg({current_node, traversed_nodes, time})
					# open current node's valve
					opened = Map.update!(current_state, :time, & &1-1)
					|> Map.update!(:flow, & &1+nodes[current_node].flow)
					|> Map.update!(:total, & &1+current_state.flow)
					# dbg(opened)
					# go to next node and calculate used time
					next_nodes = for {next_node, distance} <- all_distances_from[current_node],
						distance < current_time, # be able to go in time
						next_node not in traversed_nodes do # have not been there yet
							Map.update!(opened, :path, & [next_node | &1])
							|> Map.update!(:time, & &1 - distance)
							|> Map.update!(:total, & &1 + (distance*opened.flow))
						end
					# calculate for moving to next node
					result = Map.update!(opened, :flow, & &1 + nodes[hd(opened.path)].flow)
					|> Map.update!(:total, & &1 + ((opened.time + 1) * opened.flow))
					# dbg(result)
					# return current state result
					{[result], Enum.reduce(next_nodes, next_queue, &:queue.in/2)}
			end
		end,
		& &1
	)
end

solve.(30) |> Enum.max_by(& &1.total) |> (& &1.total).() |> IO.puts
