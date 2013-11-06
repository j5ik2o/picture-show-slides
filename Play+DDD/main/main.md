!SLIDE

Scala + Play + DDD

!SLIDE

APIサーバ作りました

!SLIDE

* Scala 試してみよう
* 複雑なもの作るのでDDDでやろう

!SLIDE

* ngnix
* play2
* redis
* mysql

!SLIDE

```
app
 +- controllers
 +- views
 +- domain
 +- infrastructure
```

!SLIDE

ドメインの中身

!SLIDE

Entity

!SLIDE

```scala
trait Entity[ID] {
  val id: ID
  def equals(obj : Any) = obj match {
    case that: Entity[_] => id == that.id
    case _ => false
  }
  def hashCode = 31 * id.##
}
```

!SLIDE

```scala
class User(val id: UUID, val name: String)
  extends Entity[UUID]
```

!SLIDE

Repository

```scala
trait Respository[Entity[ID], ID] {
  def resolve(id: UUID): Entity[ID]
  def store(entity: Entity[ID]): this.type
}
```

```scala
trait EntityResolver[Entity[ID], ID]{
  def resolve(id: UUID): Entity[ID]
}
```

!SLIDE

```scala
class UserRepository extends Repsotiory[User]{
  def resolve(id: Identity[UUID]) = ...
  def store(user: User) = ...
}
```

!SLIDE

```scala
abstract class OnRedisRepository[T <: Entity[ID], ID, T2]
(master: RedisConfig, slaveOption: Option[RedisConfig], expire: Int)
(implicit redisFormat: RedisFormat[T, ID, T2])
  extends Repository[T, ID] {

  protected val masterRedisClientPool = Pool(master)

  protected val slaveRedisClientPool = slaveOption.map(Pool(_)).getOrElse(masterRedisClientPool)

  def resolve(identifier: Identity[ID]) =
    resolveOption(identifier).getOrElse(throw new EntityNotFoundException)

  def contains(entity: T) =
    contains(entity.identity)

  def delete(identity: Identity[ID]) {
    masterRedisClientPool.withClient {
      masterRedisClient =>
        masterRedisClient.del(redisFormat.toKey(identity))
    }
  }

  def delete(entity: T) {
    delete(entity.identity)
  }
```

!SLIDE

<code style="font-size: 50%">
class CachedEntityResolveDecorator[E <: Entity[ID], ID]
(resolver: EntityResolver[E, ID],
 cacheRepos: Repository[CacheableEntityContainer[E, ID], String])
(implicit cm:ClassManifest[E])
  extends EntityResolver[E, ID] with LoggingEx {

  def resolveOption(identifier: Identity[ID]) = {
    // キャッシュから探す
    val cacheKey = generateCacheKey(cm.erasure, identifier)
    cacheRepos.resolveOption(cacheKey) match {
      case Some(e) =>
        Some(e.entity)
      case None =>
        // なければ、リゾルバから探す
        resolver.resolveOption(identifier).map {
          entity =>
          // あればキャッシュに格納
            cacheRepos.store(new CacheableEntityContainer(entity, cacheKey))
            entity
        }
    }
  }

  def resolve(identifier: Identity[ID]) =
    resolveOption(identifier).getOrElse(throw new EntityNotFoundException)

  def contains(identifier: Identity[ID]) = resolveOption(identifier).isDefined

  def contains(entity: E) = contains(entity.identity)
}
</div>
