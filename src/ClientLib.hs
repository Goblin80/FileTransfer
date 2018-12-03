{-# LANGUAGE OverloadedStrings #-}

module ClientLib (client) where

import           Control.Concurrent (forkIO)
import           Control.Monad
import qualified Data.ByteString.Char8 as B
import qualified Network.Simple.TCP as S
import System.Directory as DIR

client :: String -> IO ()
client host = S.connect host "9000" $ \(connectionSocket, remoteAddr) -> do
  putStrLn $ "Connection established to " ++ show remoteAddr
  mblf <- S.recv connectionSocket 4096
  case mblf of 
    Just lf -> do
        putStr $ B.unpack lf
        input <- getLine
        S.send connectionSocket $ B.pack input
        mbf <- S.recv connectionSocket 4096
        case mbf of
            Just f -> B.writeFile input f
            Nothing -> return ()
    Nothing -> return ()