import System.Environment (getArgs)

data Command = Up Int | Down Int | Forward Int deriving (Eq, Show)
type Position = (Int, Int)

parseCommand :: String -> Command
parseCommand commandStr =
  case words commandStr of
    ["forward", i] -> Forward (read i)
    ["up", i] -> Up (read i)
    ["down", i] -> Down (read i)
    _ -> error "invalid command"

combine :: Position -> Command -> Position
combine (h, depth) (Up n) = (h, depth - n)
combine (h, depth) (Down n) = (h, depth + n)
combine (h, depth) (Forward n) = (h + n, depth)

partOne = do
  contents <- getContents
  let commands = (map parseCommand) . lines $ contents
  let (h, depth) = foldl combine (0, 0) commands
  print (h * depth)

partTwo = error "not implemented yet"

main = do
  args <- getArgs
  case args of
    ["part1"] -> partOne
    ["part2"] -> partTwo
    _ -> error "Expected a single argument: part1 | part2"
