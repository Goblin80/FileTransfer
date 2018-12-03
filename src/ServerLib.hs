{-# LANGUAGE OverloadedStrings #-}

module ServerLib (server) where

import           Control.Concurrent (forkIO)
import           Control.Monad
import qualified Data.ByteString.Char8 as B
import qualified Network.Simple.TCP as S
import System.Directory as DIR

server :: IO ()
server = S.withSocketsDo $ do
  S.listen "*" "9000" $ \(lsock, laddr) -> do
    putStrLn $ "Listening for TCP connections at " ++ show laddr
    forever . S.acceptFork lsock $ \(csock, caddr) -> do
      putStrLn $ "Accepted incoming connection from " ++ show caddr
      echoloop csock
      where
        echoloop sock = do
          flist <- (DIR.listDirectory ".")
          let myfiles = flattenFilePath flist $ length flist
          S.send sock (B.pack myfiles)
          mbs <- S.recv sock 4096
          case mbs of
            Just bs -> do 
                let f = B.unpack bs
                putStrLn $ "Looking for " ++ f
                content <- B.readFile $ f
                S.send sock content
                S.closeSock sock
                return ()
            Nothing -> return ()


flattenFilePath :: [FilePath] -> Int -> String
flattenFilePath [] 0 = ""
flattenFilePath (x:xs) n = "[*] " ++ show x ++ "\n" ++ flattenFilePath xs (n-1)