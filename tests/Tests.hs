{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Applicative
import Data.Byteable
import Data.ByteString (ByteString)
import qualified Data.ByteString as B
import Data.ByteString.Char8 ()
import Test.Tasty
import Test.Tasty.QuickCheck
import Test.Tasty.HUnit

import qualified Crypto.Cipher.ChaCha as ChaCha
import qualified Crypto.Cipher.Salsa as Salsa
import qualified Crypto.MAC.Poly1305 as Poly1305

import qualified KATSalsa
import qualified KATHash
import qualified KAT_HMAC
import qualified KAT_PBKDF2
import qualified KAT_Scrypt
import qualified KAT_RC4
import qualified KAT_Blowfish
import qualified BlockCipher

b8_128_k0_i0 = "\xe2\x8a\x5f\xa4\xa6\x7f\x8c\x5d\xef\xed\x3e\x6f\xb7\x30\x34\x86\xaa\x84\x27\xd3\x14\x19\xa7\x29\x57\x2d\x77\x79\x53\x49\x11\x20\xb6\x4a\xb8\xe7\x2b\x8d\xeb\x85\xcd\x6a\xea\x7c\xb6\x08\x9a\x10\x18\x24\xbe\xeb\x08\x81\x4a\x42\x8a\xab\x1f\xa2\xc8\x16\x08\x1b\x8a\x26\xaf\x44\x8a\x1b\xa9\x06\x36\x8f\xd8\xc8\x38\x31\xc1\x8c\xec\x8c\xed\x81\x1a\x02\x8e\x67\x5b\x8d\x2b\xe8\xfc\xe0\x81\x16\x5c\xea\xe9\xf1\xd1\xb7\xa9\x75\x49\x77\x49\x48\x05\x69\xce\xb8\x3d\xe6\xa0\xa5\x87\xd4\x98\x4f\x19\x92\x5f\x5d\x33\x8e\x43\x0d"

b12_128_k0_i0 =
    "\xe1\x04\x7b\xa9\x47\x6b\xf8\xff\x31\x2c\x01\xb4\x34\x5a\x7d\x8c\xa5\x79\x2b\x0a\xd4\x67\x31\x3f\x1d\xc4\x12\xb5\xfd\xce\x32\x41\x0d\xea\x8b\x68\xbd\x77\x4c\x36\xa9\x20\xf0\x92\xa0\x4d\x3f\x95\x27\x4f\xbe\xff\x97\xbc\x84\x91\xfc\xef\x37\xf8\x59\x70\xb4\x50\x1d\x43\xb6\x1a\x8f\x7e\x19\xfc\xed\xde\xf3\x68\xae\x6b\xfb\x11\x10\x1b\xd9\xfd\x3e\x4d\x12\x7d\xe3\x0d\xb2\xdb\x1b\x47\x2e\x76\x42\x68\x03\xa4\x5e\x15\xb9\x62\x75\x19\x86\xef\x1d\x9d\x50\xf5\x98\xa5\xdc\xdc\x9f\xa5\x29\xa2\x83\x57\x99\x1e\x78\x4e\xa2\x0f"

b20_128_k0_i0 =
    "\x89\x67\x09\x52\x60\x83\x64\xfd\x00\xb2\xf9\x09\x36\xf0\x31\xc8\xe7\x56\xe1\x5d\xba\x04\xb8\x49\x3d\x00\x42\x92\x59\xb2\x0f\x46\xcc\x04\xf1\x11\x24\x6b\x6c\x2c\xe0\x66\xbe\x3b\xfb\x32\xd9\xaa\x0f\xdd\xfb\xc1\x21\x23\xd4\xb9\xe4\x4f\x34\xdc\xa0\x5a\x10\x3f\x6c\xd1\x35\xc2\x87\x8c\x83\x2b\x58\x96\xb1\x34\xf6\x14\x2a\x9d\x4d\x8d\x0d\x8f\x10\x26\xd2\x0a\x0a\x81\x51\x2c\xbc\xe6\xe9\x75\x8a\x71\x43\xd0\x21\x97\x80\x22\xa3\x84\x14\x1a\x80\xce\xa3\x06\x2f\x41\xf6\x7a\x75\x2e\x66\xad\x34\x11\x98\x4c\x78\x7e\x30\xad"

b8_256_k0_i0 =
    "\x3e\x00\xef\x2f\x89\x5f\x40\xd6\x7f\x5b\xb8\xe8\x1f\x09\xa5\xa1\x2c\x84\x0e\xc3\xce\x9a\x7f\x3b\x18\x1b\xe1\x88\xef\x71\x1a\x1e\x98\x4c\xe1\x72\xb9\x21\x6f\x41\x9f\x44\x53\x67\x45\x6d\x56\x19\x31\x4a\x42\xa3\xda\x86\xb0\x01\x38\x7b\xfd\xb8\x0e\x0c\xfe\x42\xd2\xae\xfa\x0d\xea\xa5\xc1\x51\xbf\x0a\xdb\x6c\x01\xf2\xa5\xad\xc0\xfd\x58\x12\x59\xf9\xa2\xaa\xdc\xf2\x0f\x8f\xd5\x66\xa2\x6b\x50\x32\xec\x38\xbb\xc5\xda\x98\xee\x0c\x6f\x56\x8b\x87\x2a\x65\xa0\x8a\xbf\x25\x1d\xeb\x21\xbb\x4b\x56\xe5\xd8\x82\x1e\x68\xaa"

b12_256_k0_i0 =
    "\x9b\xf4\x9a\x6a\x07\x55\xf9\x53\x81\x1f\xce\x12\x5f\x26\x83\xd5\x04\x29\xc3\xbb\x49\xe0\x74\x14\x7e\x00\x89\xa5\x2e\xae\x15\x5f\x05\x64\xf8\x79\xd2\x7a\xe3\xc0\x2c\xe8\x28\x34\xac\xfa\x8c\x79\x3a\x62\x9f\x2c\xa0\xde\x69\x19\x61\x0b\xe8\x2f\x41\x13\x26\xbe\x0b\xd5\x88\x41\x20\x3e\x74\xfe\x86\xfc\x71\x33\x8c\xe0\x17\x3d\xc6\x28\xeb\xb7\x19\xbd\xcb\xcc\x15\x15\x85\x21\x4c\xc0\x89\xb4\x42\x25\x8d\xcd\xa1\x4c\xf1\x11\xc6\x02\xb8\x97\x1b\x8c\xc8\x43\xe9\x1e\x46\xca\x90\x51\x51\xc0\x27\x44\xa6\xb0\x17\xe6\x93\x16"

b20_256_k0_i0 =
    "\x76\xb8\xe0\xad\xa0\xf1\x3d\x90\x40\x5d\x6a\xe5\x53\x86\xbd\x28\xbd\xd2\x19\xb8\xa0\x8d\xed\x1a\xa8\x36\xef\xcc\x8b\x77\x0d\xc7\xda\x41\x59\x7c\x51\x57\x48\x8d\x77\x24\xe0\x3f\xb8\xd8\x4a\x37\x6a\x43\xb8\xf4\x15\x18\xa1\x1c\xc3\x87\xb6\x69\xb2\xee\x65\x86\x9f\x07\xe7\xbe\x55\x51\x38\x7a\x98\xba\x97\x7c\x73\x2d\x08\x0d\xcb\x0f\x29\xa0\x48\xe3\x65\x69\x12\xc6\x53\x3e\x32\xee\x7a\xed\x29\xb7\x21\x76\x9c\xe6\x4e\x43\xd5\x71\x33\xb0\x74\xd8\x39\xd5\x31\xed\x1f\x28\x51\x0a\xfb\x45\xac\xe1\x0a\x1f\x4b\x79\x4d\x6f"

instance Show Poly1305.Auth where
    show = show . toBytes

data Chunking = Chunking Int Int
    deriving (Show,Eq)

instance Arbitrary Chunking where
    arbitrary = Chunking <$> choose (1,34) <*> choose (1,2048)

tests = testGroup "cryptonite"
    [ testGroup "ChaCha"
        [ testCase "8-128-K0-I0"  (chachaRunSimple b8_128_k0_i0 8 16 8)
        , testCase "12-128-K0-I0" (chachaRunSimple b12_128_k0_i0 12 16 8)
        , testCase "20-128-K0-I0" (chachaRunSimple b20_128_k0_i0 20 16 8)
        , testCase "8-256-K0-I0"  (chachaRunSimple b8_256_k0_i0 8 32 8)
        , testCase "12-256-K0-I0" (chachaRunSimple b12_256_k0_i0 12 32 8)
        , testCase "20-256-K0-I0" (chachaRunSimple b20_256_k0_i0 20 32 8)
        ]
    , testGroup "Salsa"
        [ testGroup "KAT" $
              map (\(i,f) -> testCase (show (i :: Int)) f) $ zip [1..] $ map (\(r, k,i,e) -> salsaRunSimple e r k i) KATSalsa.vectors
        ]
    , testGroup "Poly1305"
        [ testCase "V0" $
            let key = "\x85\xd6\xbe\x78\x57\x55\x6d\x33\x7f\x44\x52\xfe\x42\xd5\x06\xa8\x01\x03\x80\x8a\xfb\x0d\xb2\xfd\x4a\xbf\xf6\xaf\x41\x49\xf5\x1b" :: ByteString
                msg = "Cryptographic Forum Research Group"
                tag = Poly1305.Auth "\xa8\x06\x1d\xc1\x30\x51\x36\xc6\xc2\x2b\x8b\xaf\x0c\x01\x27\xa9"
             in tag @=? Poly1305.auth key msg
        , testProperty "Chunking" $ \(Chunking chunkLen totalLen) ->
            let key = B.replicate 32 0
                msg = B.pack $ take totalLen $ concat (replicate 10 [1..255])
             in Poly1305.auth key msg == Poly1305.finalize (foldr (flip Poly1305.update) (Poly1305.initialize key) (chunks chunkLen msg))
        ]
    , KATHash.tests
    , KAT_HMAC.tests
    , KAT_PBKDF2.tests
    , KAT_Scrypt.tests
    , KAT_RC4.tests
    , KAT_Blowfish.tests
    ]
  where chachaRunSimple expected rounds klen nonceLen =
            let chacha = ChaCha.initialize rounds (B.replicate klen 0) (B.replicate nonceLen 0)
             in expected @=? fst (ChaCha.generate chacha (B.length expected))
        salsaRunSimple expected rounds key nonce =
            let salsa = Salsa.initialize rounds key nonce
             in map snd expected @=? salsaLoop 0 salsa expected

        salsaLoop _       _     [] = []
        salsaLoop current salsa (r@(ofs,expectBs):rs)
            | current < ofs  =
                let (_, salsaNext) = Salsa.generate salsa (ofs - current)
                 in salsaLoop ofs salsaNext (r:rs)
            | current == ofs =
                let (e, salsaNext) = Salsa.generate salsa (B.length expectBs)
                 in e : salsaLoop (current + B.length expectBs) salsaNext rs
            | otherwise = error "internal error in salsaLoop"

        chunks i bs
            | B.length bs < i = [bs]
            | otherwise       = let (b1,b2) = B.splitAt i bs in b1 : chunks i b2

main = defaultMain tests
