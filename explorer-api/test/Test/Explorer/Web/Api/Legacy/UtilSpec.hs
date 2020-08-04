{-# LANGUAGE OverloadedStrings #-}

module Test.Explorer.Web.Api.Legacy.UtilSpec
    ( spec
    ) where

import Prelude

import Data.Either
    ( isLeft, isRight )
import Explorer.Web.Api.Legacy.Util
    ( decodeTextAddress )
import Test.Hspec
    ( Spec, describe, it, shouldSatisfy )

spec :: Spec
spec = do
    describe "decodeTextAddress" $ do
        it "x cannot decode arbitrary unicode" $ do
            decodeTextAddress
                "💩"
                `shouldSatisfy` isLeft

        it "x cannot decode gibberish base58" $ do
            decodeTextAddress
                "FpqXJLkgVhRTYkf5F7mh3q6bAv5hWYjhSV1gekjEJE8XFeZSganv"
                `shouldSatisfy` isLeft

        it "x cannot decode Jörmungandr address" $ do
            decodeTextAddress
                "addr1qdaa2wrvxxkrrwnsw6zk2qx0ymu96354hq83s0r6203l9pqe6677z5t3m7d"
                `shouldSatisfy` isLeft

        it "✓ can decode Base58 Byron address (Legacy Mainnet)" $ do
            decodeTextAddress
                "DdzFFzCqrhstkaXBhux3ALL9wqvP3Nkz8QE5qKwFbqkmTL6zyKpc\
                \FpqXJLkgVhRTYkf5F7mh3q6bAv5hWYjhSV1gekjEJE8XFeZSganv"
                `shouldSatisfy` isRight

        it "✓ can decode Base58 Byron address (Legacy Testnet)" $ do
            decodeTextAddress
                "37btjrVyb4KEgoGCHJ7XFaJRLBRiVuvcrQWPpp4HeaxdTxhKwQjXHNKL4\
                \3NhXaQNa862BmxSFXZFKqPqbxRc3kCUeTRMwjJevFeCKokBG7A7num5Wh"
                `shouldSatisfy` isRight

        it "✓ can decode Base58 Byron address (Icarus)" $ do
            decodeTextAddress
                "Ae2tdPwUPEZ4Gs4s2recjNjQHBKfuBTkeuqbHJJrC6CuyjGyUD44cCTq4sJ"
                `shouldSatisfy` isRight

        it "✓ can decode Bech32 Shelley address (basic)" $ do
            decodeTextAddress
                "addr1vpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5eg0yu80w"
                `shouldSatisfy` isRight

        it "✓ can decode Bech32 Shelley address (stake by value)" $ do
            decodeTextAddress
                "addr1qrejymax5dh6srcj3sehf6lt0czdj9uklffzhc3fqgglnl\
                \0nyfh6dgm04q839rpnwn47klsymyted7jj903zjqs3l87sutspf7"
                `shouldSatisfy` isRight

        it "✓ can decode Bech32 Shelley address (pointer)" $ do
            decodeTextAddress
                "addr1g8ejymax5dh6srcj3sehf6lt0czdj9uklffzhc3fqgglnlf2pcqqc69etp"
                `shouldSatisfy` isRight

        it "✓ can decode Base16 Byron address" $ do
            decodeTextAddress
                "82d818582183581c4ad651d1c6afe6b3483eac69ab9\
                \6575519376f136f024c35e5d27071a0001a453d0d11"
                `shouldSatisfy` isRight

        it "✓ can decode Base16 Shelley address" $ do
            decodeTextAddress
                "6079467c69a9ac66280174d09d62575ba955748b21dec3b483a9469a65"
                `shouldSatisfy` isRight
