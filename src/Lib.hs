{-# LANGUAGE DuplicateRecordFields #-}

module Lib (someFunc) where

import Control.Concurrent
import Control.Concurrent.Chan
import Data.Map

someFunc :: IO ()
someFunc = putStrLn "someFunc"

data TActor = Session | User | RegUsers | UserProfile deriving (Show)

type AID = String

data AStorage = Events | Custom | NotPersitent
-- unmovable actors ?
-- for migrated actors with custom storage nned implement some logic for migration

data Actor = Actor
  { t :: TActor,
    aid :: AID,
    code :: IO ()
  }

data UsersActorMessage
  = MsgReg
      { username :: String,
        email :: String
      }
  | MsgLogin
      { email :: String
      }
  deriving (Show)

data ActorMessage p = ActorMessage
  { to :: AID,
    from :: AID,
    payload :: p
  }


-- how to store state ? uniformly via event or special case ???
usersActorCode :: Chan (ActorMessage UsersActorMessage) -> IO ()
usersActorCode chan = do
  -- wait for action
  (ActorMessage to from mess) <- readChan chan
  case mess of
    (MsgReg _ _) -> do
      print "Reg message recived!"
      print "send to requester"
      sendToActor undefined -- send that reg is done!
    (MsgLogin _) -> do
      print "Reg message recived!"
      print "send to requester"
      sendToActor undefined -- send login with token!
  usersActorCode chan


-- separate actor with event source and custom state storage

-- CENTRILIZED ACTOR
-- create Actor with email -> actorid, locked, reged
---- this actor can recive messages: 
------- lock - reply with err or ok 
------- reged aid - repl with err or ok
------- getAID email

-- TASK actor - do some work - and DIE!
-- actor for CREATING USERS (NO STATE) just creatin logic here
-- TASK actor need some params: for ex: CREATE_USER email username pwd
-- 0. send email confirm link (skip)
-- 1. try to lock email
-- 2. Create persitent actor with user (and first event inside)
-- 3. unlock email with user actor_id
-- 4. send notifyes, update stats data etc.. (can skip for now)
-- 5. send to creator - actor created 

-- Login actor - do some work - and DIE
-- login email pwd (resp with token or err) 
-- send aid = "getAID email"
-- on success send "login email pwd" to aid an wait for token or error
-- send user aid and token to user (or delegate to user actor)

-- User actor have some commands: 
----  login email pwd | create_chat token | update username token | update age token
-- events calculated to state

-- WORK WITH USER - need message accesable\unaceesable for user(client) or not ?
-- HIDE AID's
-- SESSION ACTOR - hold user aid and token, proxy user messages (create chat etc)






-- create actor Record in DB
createActor :: Actor -> IO ()
createActor a = do
  -- push to db
  runActor a

sendToActor :: ActorMessage a -> IO ()
sendToActor msg = do
  print "send!"
-- get by AID actor channel
-- if there is no such a channel (check db)
-- if there is no in DB -- send this message to othernode (add this not to path)
-- after message found correct node - node send message with updated actor location to
-- all path nodes 
-- writeChan :: Chan a -> a -> IO ()
-- USE ZMQ PUB SUB HERE ?

runActor :: Actor -> IO ()
runActor a = do
  print $ "start actor" ++ (show $ aid a)
  thid <- forkIO $ code a
  print $ "actor forked "
  return ()

actorloop = do
  print "hi"
  -- 1. recv message
  -- 2. process message
  actorloop

-- Actor is 3 things: Type,id,function
-- Node - is haskell process wich runs many actors
-- Node has a storege (mysql) for storing actors state
-- Actors state is a set of event
-- I can run many Nodes on different ports in one machine
-- Nodes search for each other via gossip
-- On start of node i can provide the set of other nodes
-- User connects to networks with some cli and can create Session actor
-- Session actor can process authentication and communicate with corrsponding User actor
-- Actors can create other actors
-- The message subsystem responsible for transparent delivery of action from  actor to actor (discover node etc)
-- Then creating an actor at first we need to select node with lowest load
---- then node is selected, we generate actor uid and put into node database type, uid
---- also we fork the actor IO action
---- now actor waits for messages https://hackage.haskell.org/package/base-4.7.0.2/docs/Control-Concurrent-Chan.html
---- each node start server, it listen for actor messages and put them into actor channel
---- then some actor holds some other actor id and whant to send message, the mess. subsystem need's to
---- know the distant node id
-- Actor message subsystem holds for mapping from "actor id" to Node holder
---- if where is no mapping for such an actor id or it outdated
---- the reponse message send some extra info about actual actor location
---- this extra info can update mapping with new information
----- So if we send message for actor to wrong node, this node will resend message to other node
----- (we can breadcambs nodes apth to try new ones )
-- Messages can contain info about reply destination (actor id)

-- Nodes communication
-- nodes open socket conection and send messages each other
-- nodes sends info about it's loading

-- If we don't know node we can send broadcast UPD to all nodes
-- with searchable ACTOR_ID and SEARCHER actor id , node which contain it will responde

-- if msg recieved by actor we can send info about this

-- all actor possible message types strongly predefined

-- message has uuid for idempotency

-- we can connect with cli to node to see session actor incoming message flow

-- if node fails, then we restart we take incomed messages (their actors)
-- and start them

-- serialization libs
-- https://hackage.haskell.org/package/cborg
-- https://hackage.haskell.org/package/cborg-json
-- https://hackage.haskell.org/package/serialise

-- https://stackoverflow.com/questions/38913670/what-is-an-erlang-node
-- https://stackoverflow.com/questions/5135598/in-erlang-is-it-possible-to-send-a-running-process-to-a-different-node
-- https://elixirforum.com/t/migrating-actors-or-processes-from-one-node-to-another-within-a-cluster/23918/2
-- https://www.quora.com/How-are-Erlang-processes-different-from-Golang-goroutines
-- https://www.infoworld.com/article/2077999/understanding-actor-concurrency--part-1--actors-in-erlang.html

-- In migrating there are 3 things you need to consider:
-- process state
-- process registered name aka how do other processes still contact it
-- messages in queue

-- https://hackage.haskell.org/package/distributed-process
-- https://yager.io/Distributed/Distributed.html
-- https://www.youtube.com/watch?v=PWS0Whf6-wc
-- https://www.youtube.com/results?search_query=distributed+haskell
-- https://softwareengineering.stackexchange.com/questions/338847/what-is-the-difference-between-actor-model-and-microservices
-- https://garba.org/article/general/event-sourcing/event-sourcing.html
-- https://chrisdone.com/posts/measuring-duration-in-haskell/
-- http://www.serpentine.com/criterion/tutorial.html
-- https://hackage.haskell.org/package/eventsourcing
-- https://www.ahri.net/2019/07/practical-event-driven-and-sourced-programs-in-haskell/
-- https://www.youtube.com/watch?v=ICzFIoJLTc4
-- https://www.axoniq.io/blog/event-sourcing-vs-blockchain