import Data.List
import System.Environment (getArgs)
import Text.Printf

type BinaryNumber = [Bool]

type Report = [BinaryNumber]

parseBinaryNumber :: String -> BinaryNumber
parseBinaryNumber = map bit
  where
    bit '0' = False
    bit '1' = True
    bit _ = error "Invalid digit in report number"

sumBits :: Enum a => [[a]] -> [Int]
sumBits = map (sum . map fromEnum) . transpose

toInt :: BinaryNumber -> Int
toInt = foldl' (\n b -> n * 2 + fromEnum b) 0

gammaRate report = toInt . map (> threshold) . sumBits $ report
  where
    threshold = length report `div` 2

epsilonRate report = toInt . map (<= threshold) . sumBits $ report
  where
    threshold = length report `div` 2

partOne = do
  contents <- getContents
  let report = map parseBinaryNumber . lines $ contents
  let γ = gammaRate report
  let ε  = epsilonRate report
  printf "γ = %d, ε = %d, solution = %d\n" γ ε (γ * ε)

partTwo = error "not implemented yet"

main = do
  args <- getArgs
  case args of
    ["part1"] -> partOne
    ["part2"] -> partTwo
    _ -> error "Expected a single argument: part1 | part2"
