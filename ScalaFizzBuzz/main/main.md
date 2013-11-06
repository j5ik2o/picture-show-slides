!SLIDE

いまさらScalaのFizzBuzz

@j5ik2o

!SLIDE

普段なにやっているか

* PHPをJVMで動作させる検証。不毛ですorz
* ニコニコのスマフォ用API鯖をPlay2+Scala+DDDで書いてた

!SLIDE

命令型で記述。

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

関数型で記述。その前に

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

関数型で記述。

```scala
(1 to 100).map({
  case n if n % 15 == 0 => "FizzBuzz"
  case n if n % 3 == 0 => "Fizz"
  case n if n % 5 == 0 => "Buzz"
  case n => n
}).foreach(println)
```

!SLIDE

他の書き方

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
