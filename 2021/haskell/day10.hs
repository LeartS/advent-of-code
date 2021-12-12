import Control.Monad
import Data.List (sort)
import System.Environment (getArgs)
import Text.Printf

data ParseResult = Ok | Incomplete [Char] | Corrupted Char

parse :: String -> ParseResult
parse line = case foldM match [] line of
  Left char -> Corrupted char
  Right [] -> Ok
  Right unclosed -> Incomplete unclosed
  where
    match :: [Char] -> Char -> Either Char [Char]
    match opens c | c `elem` ['(', '[', '{', '<'] = Right (c : opens)
    match ('(' : rest) ')' = Right rest
    match ('[' : rest) ']' = Right rest
    match ('{' : rest) '}' = Right rest
    match ('<' : rest) '>' = Right rest
    match opens char = Left char

value ')' = 3
value ']' = 57
value '}' = 1197
value '>' = 25137
value _ = error "unexpected error token"

points '(' = 1
points '[' = 2
points '{' = 3
points '<' = 4
points _ = error "unexpected missing token"

autoCompletionScore = foldl (\score u -> score * 5 + points u) 0

partOne = do
  lines_ <- fmap lines getContents
  let errorScore = sum [value c | (Corrupted c) <- map parse lines_] :: Int
  printf "Total error score: %d\n" errorScore

partTwo = do
  lines_ <- fmap lines getContents
  let scores = sort [autoCompletionScore unclosed | (Incomplete unclosed) <- map parse lines_] :: [Int]
  printf "The middle autocompletion score is: %d\n" $ scores !! div (length scores) 2

main = do
  args <- getArgs
  case args of
    ["part1"] -> partOne
    ["part2"] -> partTwo
    _ -> error "Expected a single argument: part1 | part2"
