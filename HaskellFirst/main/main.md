!SLIDE

# Haskell Boot Camp

@j5ik2o

!SLIDE

# アジェンダ

- なんとなくモナドを理解できるところまで。
    - Functor
    - Applicative Functor
    - Monoid
    - Monad

!SLIDE

聞いてるだけじゃ面白くないので、リアルタイムにツッコミ入れてください

!SLIDE

# Functor

!SLIDE

写像を作り出すための型クラス

!SLIDE

## リストの値を2倍する処理

```haskell
ghci> fmap (*2) [1..5]
[2,4,6,8,10]
```
!SLIDE

## fmapの定義

```haskell
ghci> :t fmap
fmap :: Functor f => (a -> b) -> f a -> f b
```

!SLIDE

## Functor型クラス

```haskell
class Functor f where
  fmap :: (a -> b) -> f a -> f b
```

!SLIDE

## リストの実装

```haskell
instance Functor [] where
    fmap = map

map :: (a -> b) -> [a] -> [b]
map _ []     = []
map f (x:xs) = f x : map f xs
```

!SLIDE

## ファンクター則

- idでファンクター値を写した場合、ファンクター値が変化してはならない

```haskell
ghci> fmap id (Just 3)
Just 3
ghci> id $ Just 3
Just 3
ghci> fmap id [1..5]
[1,2,3,4,5]
ghci> id [1..5]
[1,2,3,4,5]
ghci> fmap id []
[]
ghci> fmap id Nothing
Nothing
```

!SLIDE

## ファンクター則

「`f`と`g`の合成関数でファンクター値を写したもの」と、「まず`g`、次に`f`でファンクター値を写したもの」が等しいこと

```haskell
fmap (f . g) = fmap f . fmap g
```

ファンクター値xに対して次が成り立つ必要がある

```haskell
fmap (f . g) x = fmap f (fmap g x)
```

!SLIDE

## Functor

- Functor値を、関数を適用して別の値に変換させる。つまり写像を作るための型クラス。
- `(a -> b)`なので、変換で値の型が変わってもよいことを意味する。

!SLIDE

## Functor Option

```haskell
data Option a = None | Some a deriving(Eq, Ord, Read, Show)
```

!SLIDE

### 実装例

```haskell
data Option a = None | Some a deriving (Show)

instance Functor Option where
  fmap f (Some x) = Some (f x)
  fmap f None = None

getOrElse :: a -> Option a -> a
getOrElse v None = v
getOrElse _ (Some x) = x
```

!SLIDE

利用例

```haskell
ghci> :l Option.hs
ghci> getOrElse 0 $ Some 1
1
ghci> getOrElse 0 None
0
ghci> fmap (+1) $ Some 1
Some 2
ghci> fmap (+1) None
None
```

!SLIDE

# Applicative Functor

!SLIDE

強化版のFunctor

!SLIDE

```haskell
class Functor f where
  fmap :: (a -> b) -> f a -> f b
```

```haskell
class (Functor f) => Applicative f where
   pure  :: a -> f a
   (<*>) :: f (a -> b) -> f a -> f b
```

!SLIDE

少し話題が逸れるが、
2項演算子をfmapするとFunctorに関数が格納される。
関数も値なのでこんなことは普通にできる。

```haskell
ghci> let b = fmap (+) $ Just 1
ghci> :t b
b :: Maybe (Integer -> Integer)
```

そのFunctorに関数を適用すると計算が可能。

```haskell
ghci> fmap (\f -> f 1) b
Just 2
```

!SLIDE

Applicativeの関数を使えば、これをもっと簡単に実現できます

```haskell
ghci> Just (+1) <*> Just (1)
Just (2)
```

他の例

```haskell
ghci> pure (+3) <*> Just 10
Just 13
ghci> Just (+++"hahaha") <*> Nothing
Nothing
ghci> Nothing <*> Just "woot"
Nothing
```

!SLIDE

`<*>`は連続して使うことができる

```haskell
ghci> pure (+) <*> Just 3 <*> Just 5
Just 8
ghci> pure (+) <*> Just 3 <*> Nothing
Nothing
ghci> pure (+) <*> Nothing <*> Just 5
Nothing
```

!SLIDE

```haskell
pure f <*> x <*> y
```

は

```haskell
fmap f x <*> y
```

のように記述できる

Control.Applicativeにはfmap相当の`<$>`が定義されている。

```haskell
(<$>) :: (Functor f) => (a -> b) -> f a -> f b
f <$> x = fmap f x
```

```haskell
ghci> (++) <$> Just "Junichi" <*> Just "Kato"
Just "JunichiKato"

ghci> (++) "Junichi" "Kato"
"JunichiKato"
```
!SLIDE

## Applicative Functor

- Functorまま関数適用が可能になる

!SLIDE

## Applicative Option

```haskell
instance Applicative Option where
    pure = Just
    None <*> _ = None
    (Just f) <*> something = fmap f something
```

利用例

```haskell
ghci> :l Option.hs
ghci> pure (+) <*> Some 3 <*> Some 5
Some 8
ghci> pure (+) <*> Some 3 <*> None
None
```

!SLIDE

# Monoid

!SLIDE

二項演算と単位元を持つ代数的データ構造

!SLIDE

1 は * の単位元、[] は ++ の単位元

```haskell
ghci> 5 * 1
5
ghci> [1,2,3] ++ []
[1,2,3]
```

!SLIDE

- mempty は モノイドの単位元
- mappend は モノイド固有の二項演算関数
    - 付け足すという意味ではない。2つのモノイド値を取って第三のモノイド値を返す関数。
- mconcatはモノイドのリストをmappendで畳み込んだ、モノイド値を返す関数。

```haskell
class Monoid m where
  mempty :: m
  mappend :: m -> m -> m
  mconcat :: [m] -> m
  mconcat = foldr mappend mempty
```

!SLIDE

リストはモノイド

```haskell
instance Monoid [a] where
  mempty = []
  mappend = (++)
```

!SLIDE

文字列もリスト

```haskell
ghci> [1,2,3] `mappend` [4,5,6]
[1,2,3,4,5,6]
ghci> ("one" `mappend` "two") `mappend` "tree"
"onetwotree"
```

!SLIDE

関数の適用順序を変えても結果が変わらない。結合的という。

```haskell
ghci> ("one" `mappend` "two") `mappend` "tree"
"onetwotree"
ghci> "one" `mappend` ("two" `mappend` "tree")
"onetwotree"
ghci> "one" `mappend` "two" `mappend` "tree"
"onetwotree"
```

!SLIDE

```haskell
ghci> "pang" `mappend` mempty
"pang"
ghci> mconcat [[1,2],[3,6],[9]]
[1,2,3,6,9]
ghci> mempty :: [a]
[]
```

!SLIDE

## モノイド則

- 単位元のための法則
    - ``mempty `mappend` x = x``
    - ``x `mappend` mempty = x``
- mappendが結合的であることを表す法則
    - ``(x `mappend` y) `mappend` z = x `mappend` (y `mappend` z)``

!SLIDE

## Monoid Option

```haskell
data Option a = None | Some a deriving (Show)

instance Monoid a => Monoid (Option a) where
    mempty = None
    None `mappend` m = m
    m `mappend` None = m
    Some m1 `mappend` Some m2 = Some (m1 `mappend` m2)
```

利用例

```haskell
ghci> None `mappend` Some "abc"
Some "abc"
ghci> Some LT `mappend` None
Some LT
ghci> Some (Sum 3) `mappend` Some (Sum 4)
Some (Sum {getSum = 7})
```

!SLIDE

# Monad

Applicative Functorの強化版らしい

!SLIDE

(Applicative m) => がついてない...。

```haskell
class Monad m where
    return :: a -> m a
    (>>=) :: m a -> (a -> m b) -> m b
    (>>) :: m a -> m b -> m b
    ￼x >> y = x >>= \_ -> y
    fail :: String -> m a
```

!SLIDE

## Monad Option

```haskell
data Option a = None | Some a deriving (Show)

instance Monad Option where
    return = Some
    None >>= f = None
    Some x >>= f = f x
```

!SLIDE

### 利用例

pureと同じ使い方

```haskell
ghci> return "WHAT" :: Option String
Some "WHAT"
```

!SLIDE

Some の場合に xに9が渡され、Some (90)が返される

```haskell
ghci> Some 9 >>= \x -> return (x*10)
Some 90
```

!SLIDE

Noneの場合は関数は適用されずにNoneが返される

```haskell
ghci> None >>= \x -> return (x*10)
None
```

!SLIDE

引数を利用しないで値を返したい場合

```haskell
ghci> Some 1 >> None
None
ghci> Some 1 >>= \_ -> None
None
```

```haskell
(>>) :: (Monad m) => m a -> m b -> m b
m >> n = m >>= \_->n
```

!SLIDE

Some (Some 1)の中の値を二乗しSomeでラップして返す。

```haskell
square = case Some (Some 1) of
         None -> None
         Some x -> case x of
                   None -> None
                   Some x -> Some $ x * x
```

!SLIDE

モナドの関数を使うとこんな簡単に書ける

```haskell
square = Some (Some 1) >>= \x -> x >>= \y -> return (y * y)
```

!SLIDE

## do式

```haskell
square = do
          x <- Some (Some 1)
          y <- x
          return y * y
```

!SLIDE

## Monad

文脈に通常の値を取る関数を適用し別の文脈に変換することができる


!SLIDE

## モナド則

!SLIDE

### 左恒等性

- `return x >>= f`と`f x`が同じであること

```haskell
ghci> return 3 >>= (\x -> Just (x+1))
Just 4
ghci> (\x -> Just (x+1)) 3
Just 4
```

!SLIDE

### 右恒等性

- `m >>= return` と `m` が等しいこと

```haskell
ghci> Just "move on up" >>= return
Just "move on up"
ghci> [1,2,3,4] >>= return
[1,2,3,4]
```

!SLIDE

### 結合法則

- `(m >>= f) >>= g` と `m >>= (\x -> f x >>= g)`

!SLIDE

たとえばこんな例

```haskell
double :: Num a => a -> Maybe a
double x = return $ x * 2

square :: Num a => a -> Maybe a
square x = return $ x * x

dec :: Num a => a -> Maybe a
dec x = return $ x - 1

inc :: Num a => a -> Maybe a
inc x = return $ x + 1
```

```haskell
ghci> return 1 >>= double >>= inc >>= square >>= dec
Just 8
```

!SLIDE

括弧をつけると

```haskell
ghci> (((return 1 >>= double) >>= inc) >>= square) >>= dec
Just 8
```

!SLIDE

だけど、こう書ける!

```haskell
return 1 >>= (\a ->
double a >>= (\b ->
inc b >>= (\c ->
square c >>= (\d ->
dec d))))
```

関数の入れ子の順序はどうでもよい。適用する関数の意味だけが重要。これをモナド結合法則という

!SLIDE

# 付録

!SLIDE

## Maybeの拡張版 Either

!SLIDE

Maybeは失敗するかもしれない計算を含む文脈を表しているが、どんな失敗だったかはわからない。Eitherはエラーの内容がわかるようになっている。

```haskell
data Either a b = Left a | Right b deriving (Eq, Ord, Read, Show)
```

!SLIDE

Left True は Either Bool bとなり、bが多相のまま。NothingにはMaybe aがつくのと同じ。Nothingではよくわからないので、エラーの型を指定できるようになっている。

```haskell
ghci> Right 20
Right 20
ghci> Left "w00t"
Left "w00t"
ghci> :t Right 'a'
Right 'a' :: Either a Char
ghci> :t Left True
Left True :: Either Bool b
```

!SLIDE

EitherはFunctorです

EitherではなくEither a型としているのが肝。Maybe a相当の型を表現している。

```haskell
instance Functor (Either Int) where
    fmap _ (Left x) = Left x
    fmap f (Right x) = Right (f x)
```


```haskell
ghci> fmap (== "cheeseburger") (Left 1 :: Either Int String)
Left 1
ghci> fmap (== "cheeseburger") (Left 1 :: Either Int String)
Right False
```

!SLIDE

EitherはMonadです

- Leftの値はError型であること
- return はデフォルトの最小限の文脈を入れる関数
- 左辺がRightの場合はその中の値にfを適用する。
- 左辺がすでにエラーだった場合は引き継がれる。

```haskell
instance (Error e) -> Monad (Either e) where
    return x = Right x
    Right x >>= f = f x
    Left err >>= f = Left Error
    fail msg = Left (strMsg msg)
```

!SLIDE

```haskell
ghci> Left "boom" >>= \x -> return (x+1)
Left "boom"
ghci> Left "boom" >>= \x -> Left "no way!"
Left "boom"
ghci> Right 100 >>= \x -> Left "no way!"
Left "no way1"
```

!SLIDE

## MonadPlus型クラス

```haskell
class Monad m => MonadPlus m where
    mzero :: m a
    mplus :: m a -> m a -> m a
```

!SLIDE

```haskell
guard :: (MonadPlus m) => Bool -> m ()
guard True = return ()
guard False = mzero
```

!SLIDE

```haskell
test :: Maybe String
test = if (5 > 2) then Just "cool" else Nothing
```

!SLIDE

elseケースを書く必要がなくなる!

```haskell
test :: Maybe String
test = guard (5 > 2) >> return "cool"
```


