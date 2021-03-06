{- Consider the problem of encoding a string using caesar cipher. Write a program to crack a given string encoded using the caesar's cipher -}

module CaesarCipher where

import Data.Char
import Data.List

-- Encoder Helper functions

-- Map a given character to the index [0..25]
-- For example, a -> index 0 ,   z -> index 25

char2indexL :: Char -> Int
char2indexL ch = ord ch - ord 'a'

-- Convert a given index in the list [0..25] to the respective characters
-- For example, index 7 -> 'h'

index2charL :: Int -> Char
index2charL n = chr (n + ord 'a')

-- Map a given character to the index [0..25]
-- For example, A -> index 0 ,   Z -> index 25

char2indexU :: Char -> Int
char2indexU ch = ord ch - ord 'A' 


-- Convert a given index in the list [25..51] to the respective characters
-- For example, index 1 -> 'B'

index2charU :: Int -> Char
index2charU n = chr (n + ord 'A') 


-- Shift a given character with the given shift factor
-- +ve num means shifting right and -ve num means shifting left.

shift :: Int -> Char -> Char
shift n ch  | isLower ch = index2charL ((char2indexL ch + n) `mod` 26)
            | otherwise = index2charU((char2indexU ch + n ) `mod` 26) 


-- Encoder function - given a shift factor and a string, encoder outputs the newly encoded string

encode :: Int -> String -> String
encode n xs = [ shift n x | x <- xs]


-- Crack the caesar cipher

-- First define a table function which contains the percentage of frequency of all letters analyzed over a large volume of texts 
table :: [Float]
table = [8.2, 1.5, 2.8, 4.3, 12.7, 2.2, 2.0, 6.1, 7.0, 0.2, 0.8, 4.0, 2.4,
        6.7, 7.5, 1.9, 0.1, 6.0, 6.3, 9.1, 2.8, 1.0, 2.4, 0.2, 2.0, 0.1]


-- Calculate relative percentage of one number to another number
relativepercent :: Int -> Int -> Float
relativepercent m n = ( fromIntegral m / fromIntegral n) * 100  


-- freqs function analyses of each letter frequency in a given string

-- Helper functions

-- Count the number of characters in a given string
count :: Char -> String -> Int
count ch xs = length[ x | x <- xs, x == ch]

-- Display only the lower-case letters in a given string
lowers :: String -> String
lowers xs = [ x | x <- xs, isAsciiLower x]

-- Display the positions of a given character in the string
positions :: Eq a => a -> [a] -> [Int]
positions x xs = [i | (x', i)  <- zip xs [0 ..], x == x']


-- Contruct a table analyzing the frequency of each letter from 'a' to 'z' in the given string
freqs :: String -> [Float]
freqs xs = [relativepercent (count x xsl) nl | x <- ['a'..'z']]  
            where 
                xsl = lowers xs
                nl = length xsl
              
-- Establish a method to choose the potenial shift factor with minimum error and maximum possibility
-- chi-square statistic metod. simlilar to least-squares method

chisqr :: [Float]->[Float]->Float
chisqr os es =   sum[ (o^2 - e^2) / e | (o, e) <- zip os es ]


-- Rotate rotates each letter in a given string by the factor
rotate :: Int -> [a] -> [a]
rotate n xs = drop n xs ++ take n xs 


-- crackL decodes the given encoded string by first converting the string to all lower case letters
crackL :: String -> String
crackL xs = encode (-factor) xsl
           where 
               xsl = [toLower x | x <- xs]
               factor =  head (positions (minimum chisqrDifftable) chisqrDifftable ) 
               chisqrDifftable = [chisqr (rotate n table') table | n <- [0..25]] 
               table' = freqs xs 


-- make the characters in string uppercase at a given set of indices
uppercaseAt :: [Int] -> String -> String
uppercaseAt ns xs = [ if i `elem` ns then toUpper x else x | (x,i) <- zip xs [0..] ]

-- Display the positions of the uppercase characters in the string
positionsUp ::  String -> [Int]
positionsUp  xs = [i | (x, i)  <- zip xs [0 ..], isAsciiUpper x]


--  CRACK function decodes the potential original string with the given encoded string

crack :: String -> String
crack xs = uppercaseAt (positionsUp xs) $ crackL xs     