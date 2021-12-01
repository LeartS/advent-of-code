import System.Environment (getArgs)
countIncreasing :: [Int] -> Int
countIncreasing (a:b:rest) | b > a = 1 + countIncreasing (b:rest)
countIncreasing (a:b:rest) = countIncreasing (b:rest)
countIncreasing _ = 0

windows size list | length list < size = []
windows size list@(_:rest) = take size list : windows size rest

genericSolution windowSize = do
  contents <- getContents
  let numbers = fmap read . lines $ contents
  print . countIncreasing . map sum . windows windowSize $ numbers

partOne = genericSolution 1

partTwo = genericSolution 3

main = do
  args <- getArgs
  case args of
    ("part1":[]) -> partOne
    ("part2":[]) -> partTwo
    _ -> error "Expected a single argument: part1 | part2"
