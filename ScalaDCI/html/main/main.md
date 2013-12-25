!SLIDE

# DCI入門

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

- ユーザのメンタルモデルに近づくこと
- モデルにはコンテキストに関連する振る舞いと、そうでないものがある

!SLIDE

## 口座間送金の例で考える

```scala
case class BankAccount(balance: Money) {

  def increaseBalance(money: Money): BankAccount = {
    BankAccount(balance + money)
  }

  def decreaseBalance(money: Money): BankAccount = {
    require(money > Money.Zero)
    BankAccount(balance - money)
  }

  def updateLog(message: String, from: BankAccount, to: BankAccount, money: Money) = {
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

  def updateLog(message: String, from: BankAccount, to: BankAccount, money: Money): Unit = /* ... */

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

  def transfer(money: Money, from: BankAccount, to: BankAccount): (BankAccount BankAccount) = {
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

## sendとreceiveをロールに割り当てる

まずロールのインターフェイスを定める。

```scala
trait MoneySource {

  def send(self: BankAccount, money: Money, to: BankAccount)
          (implicit moneySink: MoneySink): (BankAccount, BankAccount)

}

trait MoneySink {

  def receive(self: BankAccount, money: Money, from: BankAccount): BankAccount

}
```

!SLIDE

ロールの実装を定義する。

```scala
object TranferMoneySource extend MoneySource {

  def send(self: BankAccount, money: Money, to: BankAccount)
          (implicit moneySink: MoneySink): (BankAccount, BankAccount) = {
    val newFrom = self.decreaseBalance(money)
    val newTo = to.receive(money)
    newTo.updateLog("send", newFrom, newTo, money)
    (newFrom, newTo)
  }

}

object TransferMoneySink extends MoneySink {

  def receive(self: BankAccount, money: Money, from: BankAccount): BankAccount = {
    val newTo = self.increaseBalance(money)
    newTo.updateLog("receive", from, newTo, money)
    newTo
  }

}
```

!SLIDE

## コンテキストを実装する

```scala
case class TransferMoneyContext(from: BankAccount, to: BankAccount) {

  implicit val source = TransferMoneySource
  implicit val sink = TransferMoneySink

  implicit def toOps(self: BankAccount) = new {

    def send(money: Money, to: BankAccount)
            (implicit moneySource: MoneySource, moneySink: MoneySink) =
      moneySource.send(self, money, to)

    def receive(money: Money, from: BankAccount)
               (implicit moneySink: MoneySink) =
      moneySink.receive(self, money, from)
  }

  def execute(money: Money): (BankAccount, BankAccount) =
    from.send(money, to)

}
```

!SLIDE

## 使い方

```scala
object Main extends App {
  val to = BankAccount(Money(10, JPY))
  val from = BankAccount(Money(0, JPY))

  val (newFrom, newTo) = TransferMoneyContext(from, to).execute(Money(10, JPY))
  println(newFrom, newTo)
}
```

