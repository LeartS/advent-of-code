{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TupleSections #-}

import Data.List.Split
import System.Environment (getArgs)
import Text.Printf

-- Function composition and application in human order
infixl 1 .>
(|>) = flip (.)
(.>) = flip ($)

partOne = do
  error "not implemented"

partTwo = do
  error "not implemented"

main = do
  args <- getArgs
  case args of
    ["part1"] -> partOne
    ["part2"] -> partTwo
    _ -> error "Expected a single argument: part1 | part2"
