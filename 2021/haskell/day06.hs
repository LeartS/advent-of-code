{-# LANGUAGE ScopedTypeVariables #-}
import System.Environment (getArgs)
import Text.Printf
import Data.List.Split (splitOn)

type LanternFish = Int

tick :: [LanternFish] -> [LanternFish]
tick = concatMap progress
  where progress 0 = [6, 8]
        progress n = [n - 1]

partOne = do
  lanternFishes :: [LanternFish] <- map read . splitOn "," <$> getContents
  let c = length . (!! 80) . iterate tick $ lanternFishes
  printf "After 80 days there are %d lantern fish" c 

partTwo = error "not implemented yet"

main = do
  args <- getArgs
  case args of
    ["part1"] -> partOne
    ["part2"] -> partTwo
    _ -> error "Expected a single argument: part1 | part2"
