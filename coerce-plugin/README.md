`hashtag-coerce` is a GHC source plugin which detects opportunities to use coerce.

At the moment it just detects one simple example, where we are mapping a newtype
constructor over a list. Operationally, this will traverse the list and apply
the newtype constructor at each position.

For example,


```
newtype Baz = Baz Int

qux :: [Int] -> [Baz]
qux = map Baz
```

will cause the plugin to warn that the `map Foo` can be replaced with `coerce`.


```
src/ModuleA.hs:6:7: warning:
    The usage of 'map' can be replaced with coerce.
  |
6 | qux = map Baz
  |       ^^^^^^^
```

The plugin can only be used with GHC 8.6.1 which is scheduled to be released at
the end of June.

In order to run the plugin, add `hashtag-coerce` as a dependency and
compiler with `-fplugin=HashtagCoerce`.
