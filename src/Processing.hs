{-# LANGUAGE OverloadedStrings #-}

module Processing(f) where

import qualified Data.ByteString as B

f :: B.ByteString -> B.ByteString
f bs = "You said '" `B.append` bs `B.append` "'"
