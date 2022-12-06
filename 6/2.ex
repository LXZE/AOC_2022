target = 14
File.read!("input.txt")
|> String.trim_trailing
|> String.graphemes
|> Stream.chunk_every(target, 1, :discard)
|> Enum.find_index(& length(Enum.uniq(&1)) == target)
|> Kernel.+(target)
|> IO.puts
