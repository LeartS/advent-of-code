import Data.List (find, findIndex, minimumBy, transpose)
import Data.List.Split
import System.Environment (getArgs)
import Text.Printf

parseRow :: String -> [Int]
parseRow = map read . words

data Cell = Marked Int | Unmarked Int

instance Show Cell where
  show (Marked n) = printf "%02d(X)" n
  show (Unmarked n) = printf "%02d(O)" n

type Line = [Cell]

type Board = [Line]

boardFromMatrix :: [[Int]] -> Board
boardFromMatrix matrix = map (map Unmarked) $ matrix ++ transpose matrix

isMarked (Marked _) = True
isMarked (Unmarked _) = False

mark :: Int -> Board -> Board
mark n = map (map markIfEqual)
  where
    markIfEqual :: Cell -> Cell
    markIfEqual (Marked m) = Marked m
    markIfEqual (Unmarked m) | m == n = Marked m
    markIfEqual (Unmarked m) = Unmarked m

playRound :: Int -> [Board] -> [Board]
playRound drawnNumber = map (mark drawnNumber)

bingo :: [Int] -> [Board] -> [[Board]]
bingo draws boards = scanl (flip playRound) boards draws

won :: Board -> Bool
won = any (all isMarked)

showBoard :: Board -> String
showBoard = unlines . map (unwords . map show)

score :: Int -> Board -> Int
score lastDrawn = (* lastDrawn) . (foldr reducer 0) . concat . take 5
  where
    reducer (Unmarked n) s = s + n
    reducer (Marked _) s = s

readBingoSetup :: IO ([Int], [Board])
readBingoSetup = do
  draws <- fmap (map (read :: String -> Int) . splitOn [',']) getLine
  contents <- fmap (filter (/= "") . lines) getContents
  let boards = (map boardFromMatrix) . chunksOf 5 . map parseRow $ contents
  pure (draws, boards)

partOne = do
  (draws, boards) <- readBingoSetup
  -- play until first winner
  let game = zip draws (tail (bingo draws boards))
  let (lastDraw, endBoards) = head . dropWhile (\(n, boards) -> not (any won boards)) $ game
  let (Just winningBoard) = find won endBoards
  putStrLn "THE WINNING BOARD IS:"
  putStr $ showBoard winningBoard
  printf "With score %d\n" (score lastDraw winningBoard)

partTwo = do
  (draws, boards) <- readBingoSetup
  let game = zip draws (tail (bingo draws boards))
  let nonFinalRounds = takeWhile (\(n, boards) -> not (all won boards)) game
  let (Just i) = findIndex (not . won) . snd . last $ nonFinalRounds
  let (lastDraw, endBoards) = head . drop (length nonFinalRounds) $ game
  let lastWinningBoard = (!!) endBoards i
  putStrLn "THE LAST WINNING BOARD IS:"
  putStrLn $ showBoard lastWinningBoard
  printf "With score %d\n" (score lastDraw lastWinningBoard)

main = do
  args <- getArgs
  case args of
    ["part1"] -> partOne
    ["part2"] -> partTwo
    _ -> error "Expected a single argument: part1 | part2"

-- Alternative draft: Optimized implementation that doesn't "simulate the game",
-- but uses a map of number -> draw instant to know when a "line" will complete.
-- import qualified Data.Map as Map
-- winningBoard :: [Int] -> [Board] -> Board
-- winningBoard draw boards =
--   minimumBy winTimeOrdering $ boards
--   where
--     -- a map of <drawn number> => when it was drawn
--     drawsMap = Map.fromList . zipWith (\i n -> (n, i)) [1 ..] $ draw
--     -- returns the Just x where x is when the provided number is drawn,
--     -- or Nothing if the number is never drawn
--     drawTime :: Int -> Maybe Int
--     drawTime = (flip Map.lookup) drawsMap
--     -- Return the time the entire line is drawn
--     -- which is just the time its latest-drawn number is drawn
--     lineDrawTime :: Line -> Maybe Int
--     lineDrawTime = (fmap maximum) . mapM drawTime
--     boardWinTime :: Board -> Maybe Int
--     boardWinTime = (fmap minimum) . mapM lineDrawTime
--     winTimeOrdering :: Board -> Board -> Ordering
--     winTimeOrdering a b = case (boardWinTime a, boardWinTime b) of
--       (Just _, Nothing) -> LT
--       (Nothing, Just _) -> GT
--       (Nothing, Nothing) -> EQ
--       (Just winTimeA, Just winTimeB) -> compare winTimeA winTimeB
