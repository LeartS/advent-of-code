import Data.List
import System.Environment (getArgs)
import Text.Printf

type BinaryNumber = [Bool]

parseBinaryNumber :: String -> BinaryNumber
parseBinaryNumber = map bit
  where
    bit '0' = False
    bit '1' = True
    bit _ = error "Invalid digit in report number"

toInt :: BinaryNumber -> Int
toInt = foldl' (\n b -> n * 2 + fromEnum b) 0

-- | Given a list of bits (boolean values), returns the most common one.
-- In case of a tie, True (i.e. 1) is returned.
modeBit :: [Bool] -> Bool
modeBit bits
  | ones >= threshold = True
  | ones < threshold = False
  where
    ones = (sum . map fromEnum) bits
    n = length bits
    threshold = (n + 1) `div` 2

-- |
-- Given a list of same-length binary numbers,
-- returns a binary number where each bit is set to the most common bit value
-- in that position between all the binary numbers
modeBits :: [BinaryNumber] -> BinaryNumber
modeBits = map modeBit . transpose

gammaRate = toInt . modeBits

epsilonRate = toInt . map not . modeBits

-- |
-- Iteratively filters binary numbers based on the n-th bit, left-to-right,
-- until only one binary number remains. Returns the decimal value of that number.
--
-- At each iteration, i.e. for each n, the "winning" bit is selected by applying
-- the provided function to a list of the n-th bits of the binary numbers
-- that are still standing. The function must have therefore type [Bool] -> Bool.
-- All the binary numbers that have their n-th bit equal to the selected winning bit
-- survive and go to the next round. The next round will work on the n+1 bit, and so on.
findRating :: ([Bool] -> Bool) -> [BinaryNumber] -> Int
findRating winningBitFn = findRating' []
  where
    findRating' :: BinaryNumber -> [BinaryNumber] -> Int
    findRating' prefix [suffix] = toInt (prefix ++ suffix)
    findRating' prefix suffixes = findRating' (prefix ++ [bit]) (map tail survivors)
      where
        bit = winningBitFn . map head $ suffixes
        survivors = filter ((== bit) . head) suffixes

oxygenGeneratorRating = findRating modeBit

carbonDioxideScrubberRating = findRating (not . modeBit)

partOne = do
  contents <- getContents
  let report = map parseBinaryNumber . lines $ contents
  let γ = gammaRate report
  let ε = epsilonRate report
  printf "γ = %d, ε = %d, solution = %d\n" γ ε (γ * ε)

partTwo = do
  contents <- getContents
  let report = map parseBinaryNumber . lines $ contents
  let oxygen = oxygenGeneratorRating report
  let co2 = carbonDioxideScrubberRating report
  printf "O2 = %d, CO2 = %d, solution = %d\n" oxygen co2 (oxygen * co2)

main = do
  args <- getArgs
  case args of
    ["part1"] -> partOne
    ["part2"] -> partTwo
    _ -> error "Expected a single argument: part1 | part2"
