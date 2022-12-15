defmodule Solver do
	def gen_range([{sx, sy}, {bx, by}], select_row) do
		dist = abs(sx - bx) + abs(sy - by)
		if select_row in (sy-dist)..(sy+dist) do
			cond do
				select_row < sy -> dist - (sy - select_row)
				select_row > sy -> dist - (select_row - sy)
				true -> dist # select_row == sy
			end |> (&(sx-&1)..(sx+&1)).()
		end
	end
	def subtract_range(fa..la, fb..lb) do
		cond do
			Range.disjoint?(fa..la, fb..lb) -> fa..la
			fa >= fb and la <= lb -> []
			fa <= fb and lb <= la -> [fa..(fb-1), (lb+1)..la]
				|> Enum.reject(&Range.size(&1) == 0)
			lb in fa..la and fb not in fa..la -> (lb+1)..la
			fb in fa..la and lb not in fa..la -> fa..(fb-1)
		end
	end
	def find_beacon(find_range, observeds) do
		Enum.reduce_while(observeds, [find_range], fn observed, acc ->
			res = Enum.map(acc, &subtract_range(&1, observed)) |> List.flatten
			case res do
				[] -> {:halt, []}
				_ -> {:cont, res}
			end
		end) |> Enum.at(0)
	end
	def solve(info, accept_range, range_to_find) do
		res = Enum.reduce_while(range_to_find, {}, fn observe_row, _ ->
			# if rem(observe_row, 100000) == 0, do: IO.puts(observe_row)
			found = Enum.reduce(info, [], fn pair, acc ->
				case gen_range(pair, observe_row) do
					nil -> acc
					range -> acc ++ [range]
				end
			end)
			case find_beacon(accept_range, found) do
				nil -> {:cont, {}}
				x.._ -> {:halt, {x, observe_row}}
			end
		end)
		case res do
			{} -> {:ng, nil}
			{x, y} -> {:ok, (x*4000000) + y}
		end
	end
end

defmodule Tasks do
	def spawn_tasks(data, accept_range) do
		chunk_size = div(Enum.at(accept_range, -1), 4)
		tasks = Enum.chunk_every(accept_range, chunk_size)
		|> Enum.map(fn range ->
			Task.async(fn ->
				scoped_range = Range.new(Enum.at(range, 0), Enum.at(range, -1))
				Solver.solve(data, accept_range, scoped_range)
			end)
		end)
		Stream.repeatedly(fn-> nil end)
		|> Enum.reduce_while(nil, fn _,_ ->
			result = Task.yield_many(tasks, 500)
			|> Enum.map(fn {_task, result} ->
				case result do
					{:ok, {:ok, res}} -> res
					_ -> nil
				end
			end) |> Enum.filter(& &1) # get only valid result
			case length(result) do
				0 -> {:cont, nil}
				_ -> {:halt, Enum.at(result, 0)}
			end
		end)
	end
end

File.stream!("input.txt")
|> Enum.map(&String.trim/1)
|> Enum.map(fn row ->
	Regex.scan(~r/(-?\d+)/, row, capture: :all_but_first)
	|> List.flatten
	|> Enum.map(&String.to_integer/1)
	|> Enum.chunk_every(2)
	|> Enum.map(&List.to_tuple/1)
end)
|> Tasks.spawn_tasks(1..4000000) |> IO.puts
