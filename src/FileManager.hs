{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE GADTs #-}

module FileManager
    ( read, readLocked, write, writeLocked, mkdir, rm, rmLocked, mv, mvLocked, ls, lock, unlock
    ) where

import Prelude hiding (read)
import System.IO
import System.Directory
import Control.Exception
import Data.List
import Data.List.Split
import Control.Concurrent
import Control.Exception
import System.Random
import System.IO.Unsafe

-----------
-- UTILS --
-----------

rootPath :: FilePath
rootPath = "/mnt/lizardfs"

------------------------
-- EXPORTED FUNCTIONS --
------------------------

lock :: FilePath -> IO String
lock fileName = do
    fileNameExists <- doesFileExist (rootPath ++ fileName)
    -- if the file we want to lock does not exists -> fail
    if not fileNameExists then return ""
    else do
        let lockFile = getLockFileName fileName
        lockExists <- doesFileExist lockFile
        if lockExists then do
            threadDelay 5000 -- wait for 5ms before retry
            lock fileName
        else do
            let key = randomStr
            writeFile lockFile key
            return randomStr

unlock :: FilePath -> String -> IO Bool
unlock fileName key = do
    accessGranted <- hasAccessToFile fileName key
    if accessGranted then do
        removePathForcibly $ getLockFileName fileName
        return True
    else return False

read :: FilePath -> IO (Either String String)
read fileName = readLocked fileName ""

readLocked :: FilePath -> String -> IO (Either String String)
readLocked fileName key = do
    handle (\(e :: IOException) -> print e >> return (Left (show e))) $ do
        accessGranted <- hasAccessToFile fileName key
        if not accessGranted then fail ("File \"" ++ fileName ++ "\" is locked by another process, you can't access it.")
        else do
            content <- readFile (rootPath ++ fileName)
            putStr content
            return $ Right content

write :: FilePath -> String -> IO (Either String ())
write fileName toWrite = writeLocked fileName toWrite ""

writeLocked :: FilePath -> String -> String -> IO (Either String ())
writeLocked fileName toWrite key = do
    handle (\(e :: IOException) -> print e >> return (Left (show e))) $ do
        accessGranted <- hasAccessToFile fileName key
        if not accessGranted then fail ("File \"" ++ fileName ++ "\" is locked by another process, you can't access it.")
        else do
            if ".lock." `isInfixOf` fileName then fail ("Cannot write a file which name's contains \".lock.\".")
            else do
                writeFile (rootPath ++ fileName) toWrite
                return $ Right ()


-- recursive=true <=> mkdir -p
mkdir :: FilePath -> Bool -> IO (Either String ())
mkdir folderName recursive = do
    handle (\(e :: IOException) -> print e >> return (Left (show e))) $ do
        if ".lock." `isInfixOf` folderName then fail ("Cannot create a folder which name's contains \".lock.\".")
        else do
            createDirectoryIfMissing recursive (rootPath ++ folderName)
            return $ Right ()

-- only on folder
ls :: FilePath -> IO (Either String String)
ls dir = do
    handle (\(e :: IOException) -> print e >> return (Left (show e))) $ do
        files <- getDirectoryContents (rootPath ++ dir)
        let content = intercalate "\n" files
        putStrLn content
        return $ Right content

rm :: FilePath -> IO (Either String ())
rm path = rmLocked path ""

rmLocked :: FilePath -> String -> IO (Either String ())
rmLocked path key = do
    handle (\(e :: IOException) -> print e >> return (Left (show e))) $ do
        accessGranted <- hasAccessToFile path key
        if not accessGranted then fail ("File \"" ++ path ++ "\" is locked by another process, you can't access it.")
        else do
            removePathForcibly (rootPath ++ path)
            return $ Right ()

mv :: FilePath -> FilePath -> IO (Either String ())
mv src dest = mvLocked src dest ""

mvLocked :: FilePath -> FilePath -> String -> IO (Either String ())
mvLocked src dest key = do
    handle (\(e :: IOException) -> print e >> return (Left (show e))) $ do
        accessGranted <- hasAccessToFile src key
        if not accessGranted then fail ("File \"" ++ src ++ "\" is locked by another process, you can't access it.")
        else do
            if ".lock." `isInfixOf` dest then fail ("Cannot move a path with a destination that contains \".lock.\".")
            else do
                renamePath (rootPath ++ src) (rootPath ++ dest)
                return $ Right ()


----------------------------
-- NOT EXPORTED FUNCTIONS --
----------------------------

-- ex : getLockFileName("/here/heythere") -> /mnt/lizardfs/here/.lock.heythere
getLockFileName :: FilePath -> FilePath  
getLockFileName fileName = rootPath ++ (intercalate "/" $ init $ splitOn "/" fileName) ++ "/.lock." ++ (last $ splitOn "/" fileName)

hasAccessToFile :: FilePath -> String -> IO Bool
hasAccessToFile fileName key = do
    let lockFile = getLockFileName fileName
    lockExists <- doesFileExist lockFile
    if lockExists then do
        content <- readFile lockFile
        if key == content then return True
        else do
            return False
    else return True


randomStr :: String
randomStr = take 20 $ randomRs ('a','z') $ unsafePerformIO newStdGen
