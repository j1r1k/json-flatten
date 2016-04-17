{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Monad.Reader (runReader)

import Data.Aeson (eitherDecodeStrict', encode)
import Data.Aeson.Flatten (flatten)
import Data.Aeson.Prefix (Options(..), Prefix, Separator, defaultOptions, prefix)
import qualified Data.ByteString as BS (getContents)
import qualified Data.ByteString.Lazy.Char8 as BS (putStrLn)
import Data.Text (Text(..))
import qualified Data.Text as Text (pack)

import Options.Applicative

class FromText a where
    fromText :: Text -> Either String a

instance FromText Text where
    fromText = Right

textOption :: FromText a => Mod OptionFields a -> Parser a
textOption = option $ eitherReader (fromText . Text.pack)

optSeparatorParser :: Parser Separator
optSeparatorParser = textOption
                   $ long "separator"
                  <> short 's'
                  <> metavar "SYMBOL"
                  <> help "Symbol used as key separator"
                  <> value (optionSeparator defaultOptions)

optPreservePrefixParser :: Parser Bool
optPreservePrefixParser = switch
                      $ long "arrays"
                     <> short 'a'
                     <> help "Preserve prefix for arrays"

optPrefixParser :: Parser Prefix
optPrefixParser = optional $ textOption
                $ long "prefix"
               <> short 'p'
               <> metavar "PREFIX"
               <> help "Prefix used for all keys"

optParser :: Parser Options
optParser = Options
        <$> optPreservePrefixParser
        <*> optSeparatorParser
        <*> optPrefixParser

runWithOptions :: Options -> IO ()
runWithOptions opts = do
  i <- eitherDecodeStrict' <$> BS.getContents
  case i of (Left  e) -> print $ "Error: " ++ e
            (Right r) -> BS.putStrLn $ encode $ flatten $ runReader (prefix r) opts

main :: IO ()
main = execParser opts >>= runWithOptions
  where opts = info (helper <*> optParser)
             $ fullDesc 
            <> progDesc "Simplify structure of a JSON while complicating key names"
            <> header "json-flatten - JSON flatten and hiearchical key names"
