{-# LANGUAGE OverloadedStrings #-}

module Explorer.Web.Validate.GenesisAddress
  ( validateGenesisAddressPaging
  ) where

import Cardano.Db
    ( EntityField (..), LookupFail (..), listToMaybe )
import Control.Monad.IO.Class
    ( MonadIO, liftIO )
import Data.Text.ANSI
    ( green, red )
import Database.Esqueleto
    ( InnerJoin (..)
    , Value (..)
    , countRows
    , from
    , isNothing
    , on
    , select
    , where_
    , (==.)
    , (^.)
    )
import Database.Persist.Sql
    ( SqlPersistT )
import Explorer.Web
    ( CAddress (..), CGenesisAddressInfo (..), queryAllGenesisAddresses )
import Explorer.Web.Api.Legacy.Types
    ( PageNo (..), PageSize (..) )
import Explorer.Web.Validate.ErrorHandling
    ( handleLookupFail )
import System.Exit
    ( exitFailure )
import System.Random
    ( randomRIO )

import qualified Data.List as List
import qualified Data.Text.IO as Text

-- | Validate that all address have a balance >= 0.
validateGenesisAddressPaging :: MonadIO m => SqlPersistT m ()
validateGenesisAddressPaging = do
  (addr1, addr2) <- do
    pageSize <- genRandomPageSize
    pageNo <- handleLookupFail =<< genRandomPageNo pageSize
    page1 <- queryAllGenesisAddresses pageNo pageSize
    page2 <- queryAllGenesisAddresses (nextPageNo pageNo) pageSize
    pure (extractAddresses page1, extractAddresses page2)
  liftIO $ if length (List.nub $ addr1 ++ addr2) == length addr1 + length addr2
    then Text.putStrLn $ "  Adjacent pages for Genesis addresses do not overlap: " <> green "ok"
    else reportIntersectFail addr1 addr2


extractAddresses :: [CGenesisAddressInfo] -> [CAddress]
extractAddresses = List.map cgaiCardanoAddress

genRandomPageNo :: MonadIO m => PageSize -> SqlPersistT m (Either LookupFail PageNo)
genRandomPageNo (PageSize pageSize) = do
  res <- select . from $ \ (txOut `InnerJoin` tx `InnerJoin` blk) -> do
            on (blk ^. BlockId ==. tx ^. TxBlockId)
            on (tx ^. TxId ==. txOut ^. TxOutTxId)
            where_ (isNothing (blk ^. BlockPreviousId))
            pure countRows
  case listToMaybe res of
    Nothing -> pure $ Left (DbLookupMessage "genRandomPageNo: Empty Block table")
    Just (Value addrCount)
      | addrCount <= 3 * pageSize ->
          pure $ Left (DbLookupMessage "genRandomPageNo: Genesis address count is too low")
      | otherwise -> do
          offset <- max addrCount <$> liftIO (randomRIO (1, addrCount - 3 * pageSize))
          pure $ Right (PageNo $ offset `div` pageSize)

genRandomPageSize :: MonadIO m => SqlPersistT m PageSize
genRandomPageSize = PageSize <$> liftIO (randomRIO (2, 50))

nextPageNo :: PageNo -> PageNo
nextPageNo (PageNo x) = PageNo (x + 1)

reportIntersectFail :: [CAddress] -> [CAddress] -> IO ()
reportIntersectFail _addr1 _addr2 = do
  Text.putStrLn $ "  Adjacent pages for Genesis addresses do not overlap: " <> red "fail"
  exitFailure
