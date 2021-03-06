{-# LANGUAGE CPP #-}
#if __GLASGOW_HASKELL__ >= 702
{-# LANGUAGE Trustworthy #-}
#endif

-- |
-- Module      : Data.ByteString.Base64.URL
-- Copyright   : (c) 2012 Deian Stefan
--
-- License     : BSD-style
-- Maintainer  : deian@cs.stanford.edu
-- Stability   : experimental
-- Portability : GHC
--
-- Fast and efficient encoding and decoding of base64url-encoded strings.

module Data.ByteString.Base64.URL
    (
      encode
    , encodeUnpadded
    , decode
    , decodeLenient
    , joinWith
    ) where

import Data.ByteString.Base64.Internal
import qualified Data.ByteString as B
import Data.ByteString.Internal (ByteString(..))
import Data.Word (Word8)
import Foreign.ForeignPtr (ForeignPtr)

-- | Encode a string into base64url form.  The result will always be a
-- multiple of 4 bytes in length.
encode :: ByteString -> ByteString
encode = encodeWith Padded (mkEncodeTable alphabet)

-- | Encode a string into unpadded base64url form.
encodeUnpadded :: ByteString -> ByteString
encodeUnpadded = encodeWith Unpadded (mkEncodeTable alphabet)

-- | Decode a base64url-encoded string applying padding if necessary.
-- This function follows the specification in <http://tools.ietf.org/rfc/rfc4648 RFC 4648>
-- and in <https://tools.ietf.org/html/rfc7049#section-2.4.4.2 RFC 7049 2.4>
decode :: ByteString -> Either String ByteString
decode = decodeWithTable Padded decodeFP

-- | Decode a base64url-encoded string.  This function is lenient in
-- following the specification from
-- <http://tools.ietf.org/rfc/rfc4648 RFC 4648>, and will not
-- generate parse errors no matter how poor its input.
decodeLenient :: ByteString -> ByteString
decodeLenient = decodeLenientWithTable decodeFP


alphabet :: ByteString
alphabet = B.pack $ [65..90] ++ [97..122] ++ [48..57] ++ [45,95]
{-# NOINLINE alphabet #-}

decodeFP :: ForeignPtr Word8
PS decodeFP _ _ = B.pack $ replicate 45 x ++ [62,x,x] ++ [52..61] ++ [x,x,
  x,done,x,x,x] ++ [0..25] ++ [x,x,x,x,63,x] ++ [26..51] ++ replicate 133 x
{-# NOINLINE decodeFP #-}

x :: Integral a => a
x = 255
{-# INLINE x #-}
