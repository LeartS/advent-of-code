{-# LANGUAGE ScopedTypeVariables #-}
import Data.Function (fix)
import Data.List.Split (splitOn)
import System.Environment (getArgs)
import Text.Printf

-- The basic recursive definition
familySize' :: (Int -> Int) -> Int -> Int
familySize' f age = (+1) . sum . map (f . (age -)) $ [9,16..age]

-- Memoization black magic based on haskell lazyness
-- https://wiki.haskell.org/Memoization#Memoization_with_recursion
memoize f = (map f [0..] !!)
familySize = fix (memoize . familySize')

ageFromTimer = (8-)

partCommon days = do
  fishAges :: [Int] <- map (ageFromTimer . read) . splitOn "," <$> getContents
  let population = sum . map (familySize . (+days)) $ fishAges
  printf "After %d days there will be %d lantern fish" days population

partOne = partCommon 80
partTwo = partCommon 256

main = do
  args <- getArgs
  case args of
    ["part1"] -> partOne
    ["part2"] -> partTwo
    _ -> error "Expected a single argument: part1 | part2"
