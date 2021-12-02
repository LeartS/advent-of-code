import System.Environment (getArgs)

data Command = Up Int | Down Int | Forward Int deriving (Eq, Show)
type SubmarineState = (Int, Int, Int) -- (Horizontal, Depth, Aim)

parseCommand :: String -> Command
parseCommand commandStr =
  case words commandStr of
    ["forward", i] -> Forward (read i)
    ["up", i] -> Up (read i)
    ["down", i] -> Down (read i)
    _ -> error "invalid command"

absoluteNavigation :: SubmarineState -> Command -> SubmarineState
absoluteNavigation (h, depth, aim) (Up n) = (h, depth - n, aim)
absoluteNavigation (h, depth, aim) (Down n) = (h, depth + n, aim)
absoluteNavigation (h, depth, aim) (Forward n) = (h + n, depth, aim)

aimNavigation :: SubmarineState -> Command -> SubmarineState
aimNavigation (h, depth, aim) (Up n) = (h, depth, aim - n)
aimNavigation (h, depth, aim) (Down n) = (h, depth, aim + n)
aimNavigation (h, depth, aim) (Forward n) = (h + n, depth + n * aim, aim)

followCourse navigationFunction = do
  contents <- getContents
  let commands = (map parseCommand) . lines $ contents
  let (h, depth, _) = foldl navigationFunction (0, 0, 0) commands
  print (h * depth)

partOne = followCourse absoluteNavigation
partTwo = followCourse aimNavigation

main = do
  args <- getArgs
  case args of
    ["part1"] -> partOne
    ["part2"] -> partTwo
    _ -> error "Expected a single argument: part1 | part2"
