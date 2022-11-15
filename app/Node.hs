{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Control.Concurrent
import Control.Monad
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BSC
import qualified Data.ByteString.Lazy.UTF8 as LBU8
import qualified Lib as ACT
import qualified Network.WebSockets as WS
import System.Random
import System.ZMQ4.Monadic
import Text.Printf

-- this is handle for cli
chandle :: WS.Connection -> IO ()
chandle conn = forever $ do
  (msg :: BS.ByteString) <- WS.receiveData conn
  -- loads actor msg
  -- ACT.sendToActor msg
  WS.sendTextData conn $ LBU8.fromString "resp"

-- threadDelay 1000000 -- microseconds

-- this handle for nodes
chandle2 :: WS.Connection -> IO ()
chandle2 conn = forever $ do
  (msg :: BS.ByteString) <- WS.receiveData conn
  WS.sendTextData conn $ LBU8.fromString "resp"

-- threadDelay 1000000 -- microseconds
-- store nodes list, recorsivle run with updated nodes list

publ :: IO ()
publ = runZMQ $ do
  -- Prepare our publisher
  publisher <- socket Pub
  bind publisher "tcp://*:5556"
  forever $ do
    -- Get values that will fool the boss
    zipcode :: Int <- liftIO $ randomRIO (0, 100000)
    temperature :: Int <- liftIO $ randomRIO (-30, 135)
    relhumidity :: Int <- liftIO $ randomRIO (10, 60)

    -- Send message to all subscribers
    -- let update = printf "%05d %d %d" zipcode temperature relhumidity
    let update = "123"
    liftIO $ print "send"    
    send publisher [] (BSC.pack update)
    liftIO $ threadDelay 1000000

main = do
  print "binding publisher"
  forkIO $ publ
  print "serving 8080"
  WS.runServer "127.0.0.1" 8080 $ \pending -> do
    conn <- WS.acceptRequest pending
    print "accept conn"
    chandle conn
