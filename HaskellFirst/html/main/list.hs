printList :: (Num a, Show a) => [a] -> String
printList x = printList' x ""

printList' :: (Num a, Show a) => [a] -> String -> String
printList' [] r = r
printList' (x:xs) r = printList' xs $ r ++ show x

