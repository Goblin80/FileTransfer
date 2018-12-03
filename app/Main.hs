module Main where

import System.Environment
import ServerLib
import ClientLib

main :: IO ()
main = do
    args <- getArgs
    progname <- getProgName
    case safehead args of
        "server" -> server
        "client" -> client (safehead $ tail args)
        _ -> putStrLn $ "Usage: " ++ progname ++ " [server | client host]"

safehead :: [String] -> String
safehead [] = ""
safehead (x:xs) = x