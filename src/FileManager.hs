{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE GADTs #-}

module FileManager
    ( read, write, mkdir, rm, mv, ls
    ) where

import Prelude hiding (read)
import System.IO
import System.Directory
import Control.Exception
import Data.List

-----------
-- UTILS --
-----------

rootPath :: FilePath
rootPath = "/mnt/lizardfs"

------------------------
-- EXPORTED FUNCTIONS --
------------------------

read :: FilePath -> IO (Either String String)
read fileName = do    
    handle (\(e :: IOException) -> print e >> return (Left (show e))) $ do
        content <- readFile (rootPath ++ fileName)
        putStr content
        return $ Right content


write :: FilePath -> String -> IO (Either String ())
write fileName toWrite = do
    handle (\(e :: IOException) -> print e >> return (Left (show e))) $ do
        writeFile (rootPath ++ fileName) toWrite
        return $ Right ()

-- recursive=true <=> mkdir -p
mkdir :: FilePath -> Bool -> IO (Either String ())
mkdir folderName recursive = do
    handle (\(e :: IOException) -> print e >> return (Left (show e))) $ do
        createDirectoryIfMissing recursive (rootPath ++ folderName)
        return $ Right ()

rm :: FilePath -> IO (Either String ())
rm path = do
    handle (\(e :: IOException) -> print e >> return (Left (show e))) $ do
        removePathForcibly (rootPath ++ path)
        return $ Right ()

mv :: FilePath -> FilePath -> IO (Either String ())
mv src dest = do
    handle (\(e :: IOException) -> print e >> return (Left (show e))) $ do
        renamePath (rootPath ++ src) (rootPath ++ dest)
        return $ Right ()

-- only on folder
ls :: FilePath -> IO (Either String String)
ls dir = do
    handle (\(e :: IOException) -> print e >> return (Left (show e))) $ do
        files <- getDirectoryContents (rootPath ++ dir)
        let content = intercalate "\n" files
        putStrLn content
        return $ Right content


----------------------------
-- NOT EXPORTED FUNCTIONS --
----------------------------


