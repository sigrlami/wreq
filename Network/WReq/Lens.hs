{-# LANGUAGE RankNTypes, TemplateHaskell #-}
{-# OPTIONS_GHC -fno-warn-missing-signatures #-}

module Network.WReq.Lens
    (
      Types.Options
    , manager
    , proxy
    , auth
    , header
    , headers
    , param
    , params
    , redirects

    , HTTP.Cookie
    , cookie_name
    , cookie_value
    , cookie_expiry_time
    , cookie_domain
    , cookie_path
    , cookie_creation_time
    , cookie_last_access_time
    , cookie_persistent
    , cookie_host_only
    , cookie_secure_only
    , cookie_http_only

    , HTTP.Proxy
    , proxyHost
    , proxyPort

    , HTTP.Response
    , responseStatus
    , responseVersion
    , responseHeader
    , responseHeaders
    , responseBody
    , responseCookie
    , responseCookieJar
    , responseClose'

    , HTTP.Status
    , statusCode
    , statusMessage
    ) where

import Control.Applicative (Applicative)
import Control.Lens hiding (makeLenses)
import Data.ByteString (ByteString)
import Network.WReq.Lens.Internal (assoc, assoc2)
import Network.WReq.Lens.Machinery (makeLenses)
import qualified Network.HTTP.Client as HTTP
import qualified Network.HTTP.Types.Header as HTTP
import qualified Network.HTTP.Types.Status as HTTP
import qualified Network.WReq.Types as Types

makeLenses ''Types.Options
makeLenses ''HTTP.Cookie
makeLenses ''HTTP.Proxy
makeLenses ''HTTP.Response
makeLenses ''HTTP.Status

responseHeader :: Applicative f =>
                  HTTP.HeaderName -> (ByteString -> f ByteString)
               -> HTTP.Response body -> f (HTTP.Response body)
responseHeader n = responseHeaders . assoc n

param :: Functor f =>
         ByteString -> ([ByteString] -> f [ByteString]) -> Types.Options
      -> f Types.Options
param n = params . assoc2 n

header :: Functor f =>
          HTTP.HeaderName -> ([ByteString] -> f [ByteString]) -> Types.Options
       -> f Types.Options
header n = headers . assoc2 n

_CookieJar :: Iso' HTTP.CookieJar [HTTP.Cookie]
_CookieJar = iso HTTP.destroyCookieJar HTTP.createCookieJar

-- N.B. This is an "illegal" lens because we can change its cookie_name.
responseCookie :: Applicative f =>
                  ByteString -> (HTTP.Cookie -> f HTTP.Cookie)
               -> HTTP.Response body -> f (HTTP.Response body)
responseCookie name = responseCookieJar._CookieJar.traverse.filtered
                      (\c -> HTTP.cookie_name c == name)
