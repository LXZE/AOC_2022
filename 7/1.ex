cmd_regex = ~r/\$ (?<cmd>.{2})\s?(?<target>.*)?/
file_regex = ~r/(?<size>\d+) (?<name>.+)/
dir_regex = ~r/(?<dir>dir) (?<name>.+)/

defmodule Utils do
	# return {current_dir_size, map[path, size]}
	def check_size(tree, path, mem) do
		{size, acc_mem} = get_in(tree, path)
		|> Enum.reduce({0, %{}}, fn {key, val}, {acc_size, acc_mem} ->
			cond do
				is_map(val) ->
					{dir_size, new_mem} = check_size(tree, path ++ [key], mem)
					{acc_size + dir_size, Map.merge(acc_mem, new_mem)}
				true -> {acc_size + String.to_integer(val), acc_mem}
			end
		end)
		dir_mem = %{Enum.join(path, "/") => size}
		{ size, Enum.reduce([dir_mem, acc_mem, mem], &Map.merge/2)}
	end
end

tree = %{/: %{}, pwd: [] }
File.stream!("input.txt")
|> Enum.map(&String.trim_trailing/1)
|> Enum.map(fn output ->
	Enum.find([cmd_regex, file_regex, dir_regex],
		&Regex.match?(&1, output))
	|> Regex.named_captures(output)
end)
|> Enum.reduce(tree, fn output, acc_tree ->
	if Map.has_key?(output, "cmd") do
		update_fn = case output do
			%{"target" => ".."} -> &tl/1
			%{"cmd" => "cd"} -> &[output["target"] | &1]
			_ -> & &1
		end
		Map.update!(acc_tree, :pwd, update_fn)
	else
		cwd = Enum.reverse(acc_tree[:pwd]) |> Enum.map(&String.to_atom/1)
		{path, val} = case output do
			%{"name" => name, "size" => size} -> {name, size}
			%{"name" => name, "dir" => _} -> {name, %{}}
		end
		update_in(acc_tree, cwd, &Map.put(&1, String.to_atom(path), val))
	end
end)
|> Utils.check_size([:/], %{}) |> elem(1)
|> Map.values |> Enum.filter(& &1 <= 100000) |> Enum.sum |> IO.puts
