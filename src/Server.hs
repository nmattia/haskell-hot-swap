{-# LANGUAGE MagicHash, UnboxedTuples #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}

module Main(main) where

import Control.Concurrent.MVar
import Control.Concurrent (threadDelay)
import Control.Monad (forever, void)
import qualified Data.ByteString as B
import GHC.Exts         ( addrToAny# )
import GHC.Prim (Addr#)
import GHC.Ptr          ( Ptr(..) )
import System.Info      ( os, arch )
import Encoding
import ObjLink
import Network.WebSockets
import Unsafe.Coerce (unsafeCoerce)

type Responder = (B.ByteString -> B.ByteString)

main :: IO ()
main = do
   initObjLinker
   responder <- loadResponder
   mvar <- newMVar responder
   runServer "127.0.0.1" 3000 (app mvar)

app :: (MVar Responder) -> ServerApp
app res pc = acceptRequest pc >>= loop
  where
    loop conn = forever $ do
      d <- receiveData conn :: IO B.ByteString
      case d of
        ":reload" -> do modifyMVar_ res (\_ -> reloadResponder)
                        sendBinaryData conn ("ok" :: B.ByteString)
        x -> readMVar res >>= \f -> sendBinaryData conn $ f x

-------------------------------- ULGY STUFF -----------------------------------

loadResponder :: IO Responder
loadResponder = do
  loadObj "Processing.o"
  _ret <- resolveObjs
  ptr <- lookupSymbol (mangleSymbol Nothing "Processing" "f")
  case ptr of
    Nothing -> putStrLn "Could not load" >> undefined
    Just (Ptr (addr)) -> case addrToAny# addr of
      (# hval #) -> return hval

reloadResponder :: IO Responder
reloadResponder = do
  unloadObj "Processing.o"
  loadResponder

mangleSymbol :: Maybe String -> String -> String -> String
mangleSymbol pkg module' valsym =
  prefixUnderscore ++
  maybe "" (\p -> zEncodeString p ++ "_") pkg ++
  zEncodeString module' ++ "_" ++ zEncodeString valsym ++ "_closure"

prefixUnderscore :: String
prefixUnderscore =
  case (os,arch) of
    ("mingw32","x86_64") -> ""
    ("cygwin","x86_64") -> ""
    ("mingw32",_) -> "_"
    ("darwin",_) -> "_"
    ("cygwin",_) -> "_"
    _ -> ""
