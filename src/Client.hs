{-# LANGUAGE OverloadedStrings #-}
module Main(main) where

import           Control.Monad
import           Network.WebSockets

import qualified Data.ByteString       as B
import qualified Data.ByteString.Char8 as C8

main :: IO ()
main = runClient "127.0.0.1" 3000 "/" app

app :: Connection -> IO ()
app c = forever $ do B.getLine >>= sendBinaryData c
                     bs <- receiveData c :: IO B.ByteString
                     C8.putStrLn $ B.append "> " bs
