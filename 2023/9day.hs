prevgen :: [Int] -> [(Int, Int)]
prevgen [] = []
prevgen l@(x : xs) = (x, last xs) : (if all (== 0) diffs then [] else prevgen diffs)
  where
    diffs = zipWith (-) xs l

reducer :: (Int, Int) -> (Int, Int) -> (Int, Int)
reducer (x1, y1) (x2, y2) = (x1 - x2, y1 + y2)

reduce' :: [(Int, Int)] -> (Int, Int)
reduce' [] = (0, 0)
reduce' (x : xs) = foldl reducer x xs

parseLine :: String -> [Int]
parseLine line = map read $ words line

processLine :: String -> (Int, Int)
processLine line = reduce' $ prevgen $ parseLine line

addTuple :: (Int, Int) -> (Int, Int) -> (Int, Int)
addTuple (x1, y1) (x2, y2) = (x1 + x2, y1 + y2)

eachLine :: (String -> (Int, Int)) -> (String -> String)
eachLine f = show . foldl addTuple (0, 0) . map f . lines

main = interact $ eachLine processLine