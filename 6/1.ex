File.read!("input.txt")
|> String.trim_trailing
|> String.graphemes
|> Stream.chunk_every(4, 1, :discard)
|> Enum.find_index(& length(Enum.uniq(&1)) == 4)
|> Kernel.+(4)
|> IO.puts
