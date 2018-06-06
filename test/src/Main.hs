{-# LANGUAGE RoleAnnotations #-}
module Main(main) where

import ModuleA hiding (b)
import Data.Coerce

b = ()

main :: IO ()
main = print a

newtype Nev = Nev Int

newtype Bar a = Bar a
type role Bar nominal

data Foo = Foo Int

qux :: [Int] -> [Nev]
qux = map Nev

oux :: [Int] -> [Foo]
oux = map Foo

sux2 :: [Int] -> [Bar Int]
sux2 = map Bar

sux :: [Int] -> [Bar Int]
sux = coerce

foo :: ()
foo = ()


