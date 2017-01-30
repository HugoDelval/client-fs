module Main where

import FileManager as FM
import System.IO

main :: IO ()
main = do
    randomIOs

randomIOs :: IO ()
randomIOs = do
    FM.rm "/helo"
    FM.mkdir "/helo/hugo" True
    FM.write "/helo/hugo/plop" "Hi there!\n"
    key <- FM.lock "/helo/hugo/plop"
    FM.readLocked "/helo/hugo/plop" key

    -- both operation should fail
    FM.read "/helo/hugo/plop"
    FM.readLocked "/helo/hugo/plop" "Not the right key"
    
    FM.unlock "/helo/hugo/plop" key

    FM.mv "/helo/hugo/plop" "/helo/hugo/plop2"

    -- should fail (print an error)
    FM.read "/helo/hugo/plop"
    
    -- should succeed
    FM.read "/helo/hugo/plop2"
    
    FM.ls "/helo/hugo/"
    FM.rm "/helo/hugo/plop2"
    FM.ls "/helo/hugo/"

    -- should fail  (print an error)
    FM.read "/helo/hugo/plop2"

    FM.ls "/"
    FM.rm "/helo"
    FM.ls "/"

    return ()
