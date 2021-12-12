import Data.Array
import Data.List (sortBy)
import Data.List.Split (chunksOf)
import qualified Data.Set as Set
import System.Environment (getArgs)
import Text.Printf

type Coord = (Int, Int)

type Heightmap = Array Coord Int

readHeightmap :: IO Heightmap
readHeightmap = do
  lines <- lines <$> getContents
  let nRows = length lines
  let heights = concatMap (map toDigit) lines
  let n = length heights
  pure $ listArray ((0, 0), (nRows - 1, n `div` nRows - 1)) heights
  where
    toDigit = subtract (fromEnum '0') . fromEnum

adjacents :: Coord -> Coord -> [Coord]
adjacents (maxx, maxy) (x, y) = filter withinBounds candidates
  where
    candidates = [(x -1, y), (x, y + 1), (x + 1, y), (x, y -1)]
    withinBounds (x, y) = x >= 0 && x <= maxx && y >= 0 && y <= maxy

exploreBasin :: Heightmap -> Set.Set Coord -> [Coord] -> Set.Set Coord
exploreBasin heightmap visited [] = visited
exploreBasin heightmap visited (current : nexts)
  | (heightmap ! current == 9) || Set.member current visited = exploreBasin heightmap visited nexts
  | otherwise = exploreBasin heightmap (Set.insert current visited) (nexts ++ adjacents maxBounds current)
  where
    maxBounds = snd . bounds $ heightmap

exploreAllBasins :: Heightmap -> [Set.Set Coord]
exploreAllBasins heightmap = takeWhile (not . null) . drop 1 . map snd . iterate reducer $ (nonNines, Set.empty)
  where
    nonNines = Set.fromList . map fst . filter (\(i, e) -> e /= 9) . assocs $ heightmap
    -- We don't need the pass the previous basins, because basins are the connected components of the graph
    -- i.e. starting from an unexplored cell, it's impossible to end up in a cell that belongs to a previous basin
    reducer (unexplored, _)
      | null unexplored = (unexplored, Set.empty)
      | otherwise = (Set.difference unexplored basin, basin)
      where
        basin = exploreBasin heightmap Set.empty [Set.elemAt 0 unexplored]

showBasin :: Heightmap -> Set.Set Coord -> String
showBasin heightmap basin = unlines . map (unwords . map renderCell) . chunksOf (nCols + 1) . assocs $ heightmap
  where
    (nRows, nCols) = snd . bounds $ heightmap
    renderCell (coord, v)
      | coord `elem` basin = show v
      | otherwise = "·"

partOne = error "not implemented yet"

partTwo = do
  heightmap <- readHeightmap
  let largestBasins = take 3 . sortBy (\a b -> compare (length b) (length a)) . exploreAllBasins $ heightmap
  -- putStr $ unlines . map show $ largestBasins
  printf "The product of the sizes of the three largest basins is %d\n" $ product . map Set.size $ largestBasins

main = do
  args <- getArgs
  case args of
    ["part1"] -> partOne
    ["part2"] -> partTwo
    _ -> error "Expected a single argument: part1 | part2"
