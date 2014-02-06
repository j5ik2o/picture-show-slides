!SLIDE

# サルにはわからないDCI入門

@j5ik2o

2013-12-25

!SLIDE

## DCIとは

- Data  
モデル
- Context  
モデルを使う場面
- Interaction  
振る舞い

!SLIDE

## DCIの着眼点

[DCIアーキテクチャ - Trygve Reenskaug and James O. Coplien](http://d.hatena.ne.jp/digitalsoul/20100131/1264925022)

- ユーザのメンタルモデルに近づくこと(オブジェクト指向の目的そのもの)
- モデルにはコンテキストに関連する振る舞いと、そうでないものがある

!SLIDE

## 口座間送金の例で考える

```scala
case class BankAccount(balance: Money) {
  // 入金
  def increaseBalance(money: Money): BankAccount = {
    BankAccount(balance + money)
  }
  // 出金
  def decreaseBalance(money: Money): BankAccount = {
    require(money > Money.Zero)
    BankAccount(balance - money)
  }
  // ログ
  def updateLog(message: String,
                from: BankAccount,
                to: BankAccount,
                money: Money) = {
    val date = new Date
    println(s"date = $date, from = $from, to = $to, money = $money") 
  }

}
```

!SLIDE

## BankAccount#send

```scala
case class BankAccount(balance: Money) {

  def increaseBalance(money: Money): BankAccount = /* ... */

  def decreaseBalance(money: Money): BankAccount = /* ... */

  def updateLog(message: String,
                from: BankAccount,
                to: BankAccount, money: Money): Unit = /* ... */

  def send(money: Money, to: BankAccount): (BankAccount, BankAccoun) = {
    val newFrom = decreaseBalance(money)
    val newTo = to.receive(money, newThis)
    updateLog("send", newFrom, newTo, money)
    (newFrom, newTo)
  }

  def receive(money: Money, from: BankAccount): BankAccount = {
    val newTo = increaseBalance(money)
    updateLog("receive", from, newTo, money)
    newTo
  }

}
```

!SLIDE

## TransferService#transfer

```scala
object TransferServie {

  def transfer(money: Money,
               from: BankAccount,
               to: BankAccount): (BankAccount BankAccount) = {
    val newFrom = from.decreaseBalance(money)
    val newTo = to.increaseBalance(money)
    updateLog("tranfer", newFrom, newTo, money)
    (newFrom, newTo)
  }

}
```

!SLIDE

## 問題

- BankAccount#(send|receive)は、モデルがFatになる。本当にその振る舞いがあることが適切か？
- TransferService#tranferは、オブジェクトではなく手続き。乱用するとモデルの表現が失われていく。

!SLIDE

## DCIで解決してみる

!SLIDE

### Scalaでの実現方法いろいろ

- traitを使ったミックスイン

```scala
val bankAccount1 = new BankAccount(Money(10, JPY)) with Sender
val bankAccount2 = new BankAccount(Money(10, JPY)) with Receiver
```

- implicit conversion
- implicit parameter
    - 型クラス


!SLIDE

### RoleのI/F(Methodless Role)を定義する

```scala
// 送金元
trait MoneySource {

  def send(self: BankAccount, money: Money, to: BankAccount)
          (implicit moneySink: MoneySink): (BankAccount, BankAccount)

}

// 送金先
trait MoneySink {

  def receive(self: BankAccount,
              money: Money,
              from: BankAccount): BankAccount

}
```

!SLIDE

### ロールの実装(Mehtodful Role)を定義する

```scala
// 送金元
object TranferMoneySource extend MoneySource {

  implicit def toOps(self: BankAccount) = new {

    def receive(money: Money, from: BankAccount)
               (implicit moneySink: MoneySink) =
      moneySink.receive(self, money, from)

  }

  def send(self: BankAccount, money: Money, to: BankAccount)
          (implicit moneySink: MoneySink): (BankAccount, BankAccount) = {
    val newFrom = self.decreaseBalance(money)
    val newTo = to.receive(money)
    newTo.updateLog("send", newFrom, newTo, money)
    (newFrom, newTo)
  }

}
```

!SLIDE

```scala
// 送金先
object TransferMoneySink extends MoneySink {

  def receive(self: BankAccount, money: Money, from: BankAccount): BankAccount = {
    val newTo = self.increaseBalance(money)
    newTo.updateLog("receive", from, newTo, money)
    newTo
  }

}
```

!SLIDE

### コンテキストを実装する

```scala
// 送金コンテキスト
case class TransferMoneyContext(from: BankAccount, to: BankAccount) {

  // ロールを合成できるようにする
  implicit val source = TransferMoneySource
  implicit val sink = TransferMoneySink

  implicit def toOps(self: BankAccount) = new {

    def send(money: Money, to: BankAccount)
            (implicit moneySource: MoneySource, moneySink: MoneySink) =
      moneySource.send(self, money, to)

  }

  def execute(money: Money): (BankAccount, BankAccount) =
    from.send(money, to)

}
```

!SLIDE

### 使い方

```scala
object Main extends App {
  val from = BankAccount(Money(10, JPY))
  val to = BankAccount(Money(0, JPY))

  // BankAccount#sendと書くとコンパイルエラー

  val context = TransferMoneyContext(from, to)
  // 送金の実行　
  val (newFrom, newTo) = context.execute(Money(10, JPY))
  println(newFrom, newTo)

  // BankAccount#sendと書くとコンパイルエラー
}
```

!SLIDE

## Roleを型クラスを使って実装する

!SLIDE

ECサイトの商品購入について

```scala
// Data
trait User extends Entity[UserId] {
  // ...
}

// Data
trait Group extends Entity[GroupId] {
  // ...
}
```

!SLIDE

### Methodless Role

```scala
// Methodless Role
trait Purchaser[A] {

  def purchase(self: A, product: Product): A

}
```

!SLIDE

### Methodful Role

```scala
// Methodful Role
object UserPurchaser extends Purchaser[User] {

  def purchase(self: User, product: Product): User = {
    // ...
  }

}

// Methodful Role
object GroupPurchaser extends Purchaser[Group] {

  def purchase(self: Group, product: Product): Group = {
    // ...
  }

}
```

!SLIDE

### Context

異なる型であるが同じインターフェイスで操作できる(アドホック多相)

```scala
// Context
case class ProductPurchaseContext() {
  implicit val up = UserPurchaser
  implicit val gp = GroupPurchaser

  implicit def toPurchaserOps[A](self: A)
    (implicit purchaser: Purchaser[A]) =
      new {
       def purchase(product: Product): A =
               purchaser.purchase(self, product)
      }

  def execute(user: User, product: Product) =
    user.purchase(product) // ここ

  def execute(group: Group, product: Product) =
    group.purchase(product) // ここ
 
}
```

!SLIDE

### Main

```scala
object Main extends App {
// ...
ProductPurchaseContext().execute(User("Junichi","Kato"), Product(ProductType.MacPro))
ProductPurchaseContext().execute(Group("Capsule Corp"), Product(ProductType.MacPro))
// ...
}
```

!SLIDE

## まとめ

- DCIでは、メンタルモデルに忠実な表現が可能
- Fatモデルとサービスを回避できる

