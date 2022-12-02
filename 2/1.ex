# Rock [A, X], Paper[B, Y], Scissors[C, Z]
selected_shape_point = %{"X" => 1, "Y" => 2, "Z" => 3}
win_result = ["A Y", "B Z", "C X"]
draw_result = ["A X", "B Y", "C Z"]

File.stream!('input.txt')
|> Enum.map(&String.trim/1)
|> Enum.map(&({ String.at(&1, 0), String.at(&1, 2) }))
|> Enum.map(fn {a, b} ->
	cond do
		Enum.find_index(win_result, &(&1 == "#{a} #{b}")) != nil ->
			selected_shape_point[b] + 6
		Enum.find_index(draw_result, &(&1 == "#{a} #{b}")) != nil ->
			selected_shape_point[b] + 3
		true -> selected_shape_point[b]
	end
end)
|> Enum.sum
|> IO.puts
