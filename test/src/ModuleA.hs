module ModuleA where

newtype Baz = Baz Int

qux :: [Int] -> [Baz]
qux = map Baz
