int_regex = ~r/(\d+)/
init_state = File.read!("input.txt")
|> String.trim_trailing |> String.split("\n\n")
|> Enum.map(fn row ->
	[_, items, ops | conds ] = String.split(row, "\n")
		|> Enum.map(&String.trim/1)
	items = Regex.scan(int_regex, items, capture: :all_but_first)
		|> List.flatten |> Enum.map(&String.to_integer/1)
	ops = String.split(ops, " = ") |> Enum.at(1)
		|> String.replace("old", "&1")
		|> (&Code.eval_string("& div((#{&1}), 3)")).() |> elem(0)
	[condition, t_target, f_target] = Enum.map(conds, fn code ->
		Regex.scan(int_regex, code, capture: :all_but_first)
			|> List.flatten |> Enum.at(0) |> String.to_integer()
	end)
	%{ count: 0, items: items, ops: ops,
		condition: condition, t_target: t_target, f_target: f_target }
end)
|> Enum.with_index(fn val, idx -> {idx, val} end) |> Map.new

max_monkey = Map.keys(init_state) |> Enum.max
Enum.reduce(1..20, init_state, fn _, acc -> #round
	Enum.reduce(0..max_monkey, acc, fn idx, monkeys -> # turn
		Enum.map(monkeys[idx][:items], fn item ->
			worry = monkeys[idx][:ops].(item)
			case rem(worry, monkeys[idx][:condition]) == 0 do
				true -> {monkeys[idx][:t_target], worry}
				false -> {monkeys[idx][:f_target], worry}
			end
		end)
		|> Enum.reduce(monkeys, fn {target, val}, current_monkeys ->
			update_in(current_monkeys, [target, :items], & &1 ++ [val])
				|> update_in([idx, :count], & &1 + 1)
		end)
		|> update_in([idx, :items], fn _ -> [] end)
	end)
end)
|> Map.to_list |> Enum.map(&elem(&1, 1)) |> Enum.map(& &1[:count])
|> Enum.sort(:desc) |> Enum.take(2) |> Enum.product |> IO.puts
