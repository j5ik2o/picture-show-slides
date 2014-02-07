!SLIDE

# ざっくりScala入門

@j5ik2o

!SLIDE

普段なにやっているか

- Scala/Finagleを利用したバックエンドシステムのアーキテクト
- SISIOH project http://sisioh.org/
    - https://github.com/sisioh/trinity

!SLIDE

## どんな言語？

- オブジェクト指向パラダイムを主軸に関数型パラダイムを取り込んだプログラミング言語です。
- コンパイラ言語であり、コンパイル結果はJavaバイトコードとなり、JVM上で実行可能です。

!SLIDE

## インストール方法

```sh
$ brew install scala
```

!SLIDE

## Hello, World!

- REPL(Read Eval Print Loop)に直接コードを入力して実行する。

```sh
$ scala
Welcome to Scala version 2.10.3 (Java HotSpot(TM) 64-Bit Server VM, Java 1.7.0_40).
Type in expressions to have them evaluated.
Type :help for more information.

scala> println("Hello, World!")
Hello, World!
```

!SLIDE

- スクリプトモードで実行する。

```sh
$ echo 'println("Hello, World!")' > Script.scala
$ scala Script.scala
Hello, World!
```

!SLIDE

- コンパイルして実行する。

```scala
object Main extends App {
  println("Hello, World!")
}
```

```sh
$ scalac Main.scala
$ scala Main
Hello, World!
```

!SLIDE

## Scalaプログラミング基礎編

!SLIDE

### 変数

- 最代入可能な変数は`var`を使って宣言する。変数の型名は変数名の後ろに記述する(型アノテーション)。

```scala
scala> var name: String = "java"
name: String = java

scala> name = "scala"
name: String = scala
```

!SLIDE

### 定数

- 再代入不可能な定数を`val`を使って宣言する。

```scala
scala> val name: String = "scala"
name: String = scala

scala> name = "java"
<console>:8: error: reassignment to val
       name = "java"
```

!SLIDE

#### 変数に型がある

- 文字列型には整数型を代入できません。

```scala
scala> var name: String = "scala"
name: String = scala

scala> name = 1
Int(1) <: String?
false
<console>:8: error: type mismatch;
 found   : Int(1)
 required: String
       name = 1
```

!SLIDE

#### 型推論

- 変数の型は値から型推論可能。

```scala
scala> val name = "scala"
name: String = scala
```

- 抽象型を明示的に指定したい場合は、型アノテーションを意図的に使う。

```scala
scala> val number = 1
number: Int = 1

scala> val number: Number = 1
number: Number = 1
```

!SLIDE

### クラスを実装する

- お金(通貨の単位と、お金の量を保持する)を表現するクラスを実装する。

```scala
package money

import java.util.Currency

class Money(val amount: Int, val currency: Currency)

val JPY = Currency.getInstance("JPY")
val m = new Money(1, JPY) // 1円

println(m == new Money(1, JPY)) // false
```

!SLIDE

- ケースクラスを利用する

```scala
package money

import java.util.Currency

// caseを付けてvalを除く
case class Money(amount: Int, currency: Currency)

val JPY = Currency.getInstance("JPY")
val m = Money(1, JPY) // Money.apply(1, JPY)

println(m == Money(1, JPY)) // true : equalsメソッドが自動的に実装される
println(m) // Money(1, JPY) : toStringが自動的に実装される
```

!SLIDE

- クラスにメソッドを追加する

```scala
case class Money(amount: Int, currency: Currency) {

  def plus(other: Money): Money = {
    require(currency == other.currency)
    Money(amount + other.amount, currency)
  }
  
  def minus(ohter: Money): Money = {
    require(currency == other.currency)
    Money(amount - other.amount, currency)
  }
  
  def +(other: Money) = plus(other)
  
  def -(other: Money) = minus(other)

}
```

!SLIDE

```scala
val m1 = Money(100, JPY).plus(Money(10, JPY))
println(m1) // Money(110, JPY)

val m2 = Money(100, JPY) plus Money(10, JPY)
println(m2) // Money(110, JPY)

val m3 = Money(100, JPY) + Money(10, JPY)
println(m3) // Money(110, JPY)
```

!SLIDE

### 関数

- 関数はオブジェクトの一種です。変数に格納したり、メソッドの引数などに渡すことが可能です。

- 引数なしで整数値を返す、関数を記述する

```scala
val f = { () => 1 }

println(f()) // println(f.apply()) // 1
```

!SLIDE

- 引数を二倍にして返す、関数を記述する

```scala
val f = { x: Int => x * 2 }

println(f(2)) // f.apply(2) // 4
```

!SLIDE

- メソッドの引数や戻り値に関数を利用する

```scala
def foreach(array: Array[Int], f: Int => Unit) = {
  for (value <- array) f(value)
}

foreach(Array(1, 2, 3), { n => println(n) })
```

!SLIDE

### よく使う型

- Option型(Maybeモナド)

```scala
case class Person(id: Int, name: String)

def findById(id: Int): Option[Person] = 
  if (id % 2 == 0) Some(Person(id, "a")) else None

val pOpt1 = findById(1) // Some(Person(1, "a"))
val pOpt2 = findById(2) // None

val p1 = pOpt1.get // Person(1, "a")
val p2 = pOpt2.get // NoSuchElementException
val p3 = pOpt2.getOrElse(Person(1, "b")) // Noneの時に返すデフォルト値を指定
```

!SLIDE

- タプル型

複数個の値を一塊に扱う型

```scala
val t2 = (1, 2)
println(t2._1 + ":" + t2._2)

val t3 = (1, 2, 3)
val t4 = (1, 2, 3, 4)
```

!SLIDE

- 配列(可変コレクション)

```scala
val a = Array(1, 2, 3, 4, 5)
val e = a(0) // 一番目にアクセス
a(0) = 100
println(a) // Array(100, 2, 3, 4, 5)
```

!SLIDE

- リスト(不変コレクション)

```scala
val l = List(1, 2, 3, 4, 5)
val e = l(0) // 一番目にアクセス
l(0) = 1 // コンパイルエラー
```

!SLIDE

- マップ(不変コレクション)

```scala
val m = Map(1 -> "a", 2 -> "b", 3 -> "c") // Map[Int, String]
val v = m(1) //: String "a"
val vOpt = m.get(1) //: Option[String] Some("a")
```

!SLIDE

#### 要素の繰り返し処理

```scala
val l = List(1,2,3) // Arrayも同じ

// for式
for(n <- l) println(n)

// 高階関数
l.foreach{ n => printl(n) }
l.foreach(println(_))
l.foreach(println)

val m = Map(1 -> "a", 2 -> "b", 3 -> "c")
for(t <- m) println(t) // t は (k,v)

m.foreach(println)
```

!SLIDE

#### 要素を検索する

```scala
val l = List(1, 2, 3)

l.find(_ == 2) // Option[Int]

val m = Map(1 -> "a", 2 -> "b", 3 -> "c")
m.find(_._1 == 1) // Option[(Int, String)]
```

!SLIDE

#### 要素の変換

```scala
val l = List(1, 2, 3)
val l2 = l.map(_ * 2) // List(2, 4, 6)

val m = Map(1 -> "a", 2 -> "b", 3 -> "c")
val m2 = m.map(e => (e._1, e._2 + e._1)) // Map(1 -> a1, 2 -> b2, 3 -> c3)
val m3 = m.map{ case (k, v) => (k, v + k) } // パターンマッチ機能を持つ、部分関数を使うともっと簡潔に記述できる
```

!SLIDE

### パターンマッチ

- 数値のパターンマッチ

```scala
def numberMatch(n: Int) = n match {
  case 1 => println("one")
  case 2 | 3 => println("two or three")
  case _ => println("otherwise")
}

numberMatch(1) // one
numberMatch(2) // two or three
numberMatch(3) // two or three
numberMatch(4) // otherwise
```

!SLIDE

- match式は値を返す

```scala
def convertToString(obj: Any) = obj match {
  case n:Int => "one" // Int型の場合
  case "2" => "two" // 文字列の値の場合
  case List(3,3,3) => "three" // コレクションの場合
  case _ => throw new IllegalArgumentException
}

println(convertNumberToString(1)) // one
println(convertNumberToString("2")) // two
println(convertNumberToString(List(3,3,3)) // three
println(convertNumberToString(0.5)) // エラー
```

!SLIDE

- ケースクラスによるパターンマッチ

```scala
case class PersonName(firstName: String, lastName: String)
case class PostalAddress(zipCode: String, prefName: String, cityName: String, addressName: String, buildingName: Option[String])
case class Person(name: PersonName, postalAddress: PostalAddress)

val persons = List(
    Person(
        PersonName("Junichi", "Kato"), 
        PostalAddress("000-0000", "東京都", "目黒区", "下目黒")
        ),
...)

def hasLastNameAndPrefName(person: Person, lastName: String, prefName: String) = preson match {
  case Person(PersonName(_, l), PostalAddress(_, p, _, _, _) if l == lastName && p == prefName => true
  case _ => false
}
```

!SLIDE

## Scalaプログラミング応用編

- 命令型で記述。

```scala
for (n <- 1 to 100) {
  if (n % 15 == 0) {
    println("FizzBuzz")
  } else if (n % 3 == 0) {
    println("Fizz")
  } else if (n % 5 == 0) {
    println("Buzz")
  } else {
    println(n)
  }
}
```

!SLIDE

- 関数型で記述。その前に

```scala
scala> 1.to(100)
res0: scala.collection.immutable.Range.Inclusive = Range(1, ..., 100)
scala> res0.map({v :Int => v * 2})
res1: scala.collection.immutable.IndexedSeq[Int] = Vector(2, ..., 200)
```

!SLIDE

```scala
 val f = {n:Int => n.toString}
 /*
 val f = new Function1[Int,String]{
   def apply(arg:Int):String = arg.toString
 }
*/
 (1 to 100).map(f)
```

!SLIDE

```scala
res0.map{v :Int => v * 2}
res0.map{v => v * 2}
res0.map{_ * 2}
res0.map(_ * 2)
```

!SLIDE

- 関数型で記述。

```scala
(1 to 100).map({
  case n if n % 15 == 0 => "FizzBuzz"
  case n if n % 3 == 0 => "Fizz"
  case n if n % 5 == 0 => "Buzz"
  case n => n
}).foreach(println)
```

!SLIDE

- 他の書き方

```scala
 (1 to 100).map {
   n => if (n % 15 == 0) "FizzBuzz"
     else if (n % 3 == 0) "Fizz"
       else if (n % 5 == 0) "Buzz"
         else n
}.foreach(println)
```

!SLIDE

```scala
(1 to 100).map {
  case n => if (n % 15 == 0) "FizzBuzz"
    else if (n % 3 == 0) => "Fizz"
      else if (n % 5 == 0) => "Buzz"
        else n
}.foreach(println)
```

!SLIDE

## BTree

https://gist.github.com/j5ik2o/7332812

https://gist.github.com/j5ik2o/7611983


