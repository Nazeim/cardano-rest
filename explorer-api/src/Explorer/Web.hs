module Explorer.Web
  ( runServer
  , WebserverConfig(..)

  -- For testing.
  , CAddress (..)
  , CTxAddressBrief (..)
  , CAddressSummary (..)
  , CCoin (..)
  , CGenesisAddressInfo (..)
  , CHash (..)
  , CTxBrief (..)
  , CTxHash (..)
  , queryAddressSummary
  , queryAllGenesisAddresses
  , queryBlocksTxs
  , queryChainTip
  , runQuery
  ) where

import Explorer.Web.Api.Legacy.AddressSummary (queryAddressSummary)
import Explorer.Web.Api.Legacy.BlocksTxs (queryBlocksTxs)
import Explorer.Web.Api.Legacy.GenesisAddress (queryAllGenesisAddresses)
import Explorer.Web.Api.Legacy.Util (runQuery)
import Explorer.Web.ClientTypes (CAddress (..), CTxAddressBrief (..), CAddressSummary (..),
        CCoin (..), CGenesisAddressInfo (..), CHash (..), CTxBrief (..), CTxHash (..))
import Explorer.Web.Query (queryChainTip)
import Explorer.Web.Server (runServer, WebserverConfig(..))
