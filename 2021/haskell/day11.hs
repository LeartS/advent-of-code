{-# LANGUAGE TupleSections #-}

import Data.Array
import Data.List.Split (chunksOf)
import System.Environment (getArgs)
import Text.Printf

type Coord = (Int, Int)

type EnergyMap = Array Coord Int

readEnergyMap :: IO EnergyMap
readEnergyMap = do
  lines <- lines <$> getContents
  let nRows = length lines
  let heights = concatMap (map toDigit) lines
  let n = length heights
  pure $ listArray ((0, 0), (nRows - 1, n `div` nRows - 1)) heights
  where
    toDigit = subtract (fromEnum '0') . fromEnum

adjacents :: EnergyMap -> Coord -> [Coord]
adjacents energymap (x, y) = do
  xOffset <- [-1 .. 1]
  yOffset <- [-1 .. 1]
  let adj@(ax, ay) = (x + xOffset, y + yOffset)
  if adj /= (x, y) && ax >= minx && ax <= maxx && ay >= miny && ay <= maxy then [adj] else []
  where
    ((minx, miny), (maxx, maxy)) = bounds energymap

flash :: EnergyMap -> Coord -> EnergyMap
flash energymap coord =
  foldr (flip flash) updatedEnergyMap $ filter (\c -> updatedEnergyMap ! c == 10) neighbors
  where
    neighbors = adjacents energymap coord
    updatedEnergyMap = accum (+) energymap (map (,1) neighbors)

step :: EnergyMap -> EnergyMap
step energymap = fmap (\x -> if x > 9 then 0 else x) flashedMap
  where
    updatedEnergyMap = fmap (+ 1) energymap
    toFlash = map fst . filter (\(i, e) -> e == 10) . assocs $ updatedEnergyMap
    flashedMap = foldr (flip flash) updatedEnergyMap toFlash

showEnergyMap heightmap = unlines . map (unwords . map show) . chunksOf (nCols + 1) . elems $ heightmap
  where
    (nRows, nCols) = snd . bounds $ heightmap

uniq [] = True
uniq [_] = True
uniq (a : b : rest) = a == b && uniq (b : rest)

partOne = do
  energyMap <- readEnergyMap
  let a = take 101 . iterate step $ energyMap
  putStr $ unlines . map showEnergyMap $ a
  print $ sum . map (length . filter (== 0) . elems) $ a

partTwo = do
  energyMap <- readEnergyMap
  let a = head . dropWhile (not . uniq . elems . snd) . zip ([0 ..] :: [Int]) . iterate step $ energyMap
  printf "After %d steps:\n" $ fst a
  putStr $ showEnergyMap $ snd a

main = do
  args <- getArgs
  case args of
    ["part1"] -> partOne
    ["part2"] -> partTwo
    _ -> error "Expected a single argument: part1 | part2"
