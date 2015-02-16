module Reddit.Types.Wiki where

import Reddit.Parser
import Reddit.Types.User
import Reddit.Utilities

import Control.Applicative
import Data.Aeson
import Data.DateTime (DateTime)
import Data.Monoid (mempty)
import Data.Text (Text)
import qualified Data.DateTime as DateTime

newtype RevisionID = RevisionID Text
  deriving (Show, Read, Eq)

data WikiPage = WikiPage { contentHTML :: Maybe Text
                         , contentMarkdown :: Text
                         , revisionDate :: DateTime
                         , revisedBy :: Username
                         , canRevise :: Bool }
  deriving (Show, Read, Eq)

instance FromJSON WikiPage where
  parseJSON (Object o) = do
    o `ensureKind` "wikipage"
    d <- o .: "data"
    WikiPage <$> (fmap unescape <$> d .:? "content_html")
             <*> (unescape <$> d .: "content_md")
             <*> (DateTime.fromSeconds <$> d .: "revision_date")
             <*> ((d .: "revision_by") >>= (.: "data") >>= (.: "name"))
             <*> d .: "may_revise"
  parseJSON _ = mempty
