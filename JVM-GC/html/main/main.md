!SLIDE

# Java VM GC 概説

@j5ik2o

!SLIDE

Java VMのメモリ空間どうなっているのか

!SLIDE

```
+--------+--------+-------------------+
|    New(Young)   |                   |
|-----------------+                   |
|  Eden  |Survivor|    Old(Tenured)   |
|        +--------|                   |
|        |From|To |                   |
+-----------------+-------------------+
```

!SLIDE

## ヒープ領域
- New世代領域

        寿命が短いオブジェクトのための領域

- Old世代領域

        寿命が長いオブジェクトのための領域

!SLIDE

## GCの種類

- マイナーGC

         New世代領域で起こるGC。

- メジャーGC

         Old世代領域で起こるGC。フルGCとも呼ばれる。

!SLIDE

## New世代領域
- Eden

        最初にアロケートされるところ

- Survivor

        マイナーGCの退避先
    - From
    - To

!SLIDE

## マイナーGC

- コピーGCアルゴリズム
- ライブオブジェクトをコピーし残った領域を解放する。

!SLIDE

## マイナーGCの流れ

1.newするとEdenにアロケートする。
2.Edenが一杯になると、ライブオブジェクトだけをToにコピーする。
3.Edenの領域に残っているオブジェクトを破棄する。
4.ToとFromの名前を入れ替える。

!SLIDE

## 1回目GC
```
 |  Eden  | From |  To |
1| oxoxox |      |     |
2| oxoxox |      | ooo |
3|        |      | ooo |
4|        | ooo  |     |
```

!SLIDE

## 2回目GC
```
 |  Eden  |  From |  To   |
1| oxxxox | ooo   |       |
2| oxxxox | ooo   | oo    |
3|        |       | ooooo |
4|        | ooooo |       |
```

!SLIDE

## メリット・デメリット

### メリット
- 高速GC
- 高速にアロケートできる
- フラグメントがない

### デメリット
- ヒープ領域の試用効率が悪い

!SLIDE

## メジャーGC

- Mark & Sweep & Compaction GC

1.ライブオブジェクトにマークをつける。
2.マークされていないオブジェクトを破棄する。
3. 空き領域を詰める処理を行う。

```
1| vovov |
2| v v v |
3| vvv   |
```

