# Rock [A, X, 1], Paper[B, Y, 2], Scissors[C, Z, 3]
point = [1, 2, 3] # Rock, Paper, Scissors
# {idx_to_select, match_point}
strategy = %{"X" => {0, 0}, "Y" => {1, 3}, "Z" => {2, 6}}
rotate = fn [head | tail] -> tail ++ [head] end
to_play = %{ # opponent -> lose, Draw, Win
	"A" => point |> rotate.() |> rotate.(), # Rock -> Scissors, Rock, Paper
	"B" => point, # Paper -> Rock, Paper, Scissors
	"C" => point |> rotate.() # Scissors -> Paper, Scissors, Rock
}

File.stream!('input.txt')
|> Enum.map(&String.trim/1)
|> Enum.map(&({ String.at(&1, 0), String.at(&1, 2) }))
|> Enum.map(fn {a, b} ->
	{idx, match_point} = strategy[b]
	my_point = to_play[a] |> Enum.at(idx)
	match_point + my_point
end)
|> Enum.sum
|> IO.puts
