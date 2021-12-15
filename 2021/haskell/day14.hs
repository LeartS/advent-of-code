{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TupleSections #-}

import Data.Foldable (maximumBy, minimumBy)
import Data.List.Split (splitOn)
import qualified Data.Map as Map
import System.Environment (getArgs)
import Text.Printf (printf)

-- Function composition and application in human order
infixl 1 .>
(|>) = flip (.)
(.>) = flip ($)

type Pair = (Char, Char)
type Rule = (Pair, (Pair, Pair))
type RuleBook = Map.Map Pair (Pair, Pair)
type State = Map.Map Pair Int

parseRule :: String -> Rule
parseRule ruleStr = ((left, right), ((left, middle), (middle, right)))
  where
    [[left, right], [middle]] = splitOn " -> " ruleStr

readInput :: IO (String, [Rule])
readInput = do
  template <- getLine
  _ <- getLine
  rules <- map parseRule . lines <$> getContents
  pure (template, rules)

pairToList (a, b) = [a, b]

insertion :: RuleBook -> (Pair, Int) -> [(Pair, Int)]
insertion rulebook (pair, count) =
  pair
    .> (rulebook Map.!)
    |> pairToList
    |> map (,count)

nextState :: RuleBook -> State -> State
nextState rulebook =
  Map.assocs
    |> concatMap (insertion rulebook)
    |> Map.fromListWith (+)

templateToState :: String -> State
templateToState [] = error "Empty template"
templateToState s@(_ : rest) =
  rest
    .> zipWith (curry (,1)) s
    |> Map.fromListWith (+)

countElements :: State -> Map.Map Char Int
countElements =
  Map.assocs
    |> concatMap (\((l, r), c) -> [(l, c), (r, c)])
    |> Map.fromListWith (+)
    -- all elements are in two pairs, except for the extremes which are in 1
    -- and therefore are the only the only elements with an odd count.
    |> Map.map (\n -> if odd n then (n + 1) `div` 2 else n `div` 2)

commonPart n = do
  (template, rules) <- readInput
  let firstElement = head template
  let lastElement = last template
  let rulebook = Map.fromList rules
  let generations = (!! n) . iterate (nextState rulebook) . templateToState $ template
  let counts = countElements generations
  let (le, lc) = minimumBy (\(e1, c1) (e2, c2) -> compare c1 c2) . Map.assocs $ counts
  let (me, mc) = maximumBy (\(e1, c1) (e2, c2) -> compare c1 c2) . Map.assocs $ counts
  printf "After %d iterations\nMost common: %c = %d\nLeast common: %c = %d\nResult: %d\n" n me mc le lc (mc - lc)

partOne = commonPart 10

partTwo = commonPart 40

main = do
  args <- getArgs
  case args of
    ["part1"] -> partOne
    ["part2"] -> partTwo
    _ -> error "Expected a single argument: part1 | part2"
