

# Vapor TIL SQLite

<a id="toc"></a>
[Overview](#Overview) |
[PostgreSQL → SQLite](#PostgreSQLToSQLite) |
[Resources](#Resources)

## Overview <a id="Overview">[▴](#toc)</a>

The [vapor-til-sqlite]() is based on [vapor-til](https://github.com/raywenderlich/vapor-til). Some key aspects of `vapor-til-sqlite` are:

* SQLite is used instead of PostgreSQL. 
* SQLite pivot `id` type is `Int` instead of `UUID`.
* TBD: Tests pass on Linux 16.04?
* Swift script to populate database.

## PostgreSQL → SQLite Conversion <a id="PostgreSQLToSQLite">[▴](#toc)</a>

Direct find & replace. 

| `PostgreSQL`               | `SQLite`               |
|----------------------------|------------------------|
| `FluentPostgreSQL`         | `FluentSQLite`         |
| `FluentPostgreSQLProvider` | `FluentSQLiteProvider` |
| `PostgreSQLModel`          | `SQLiteModel`          |
| `PostgreSQLUUIDModel`      | `SQLiteUUIDModel`      |
| `PostgreSQLConnection`     | `SQLiteConnection`     |
| `.psql`                    | `.sqlite`              |

Rewritten sections.

| `PostgreSQL`               | `SQLite`               |
|----------------------------|------------------------|
| `PostgreSQLDatabase`       | `SQLiteDatabase`       |
| `PostgreSQLDatabaseConfig` | `SQLiteStorage`        |
| `PostgreSQLUUIDPivot`      | `SQLitePivot`          |


`configure.swift` PostgreSQLDatabaseConfig, PostgreSQLDatabase

``` swift
// Configure a database
var databases = DatabasesConfig()
let databaseConfig: PostgreSQLDatabaseConfig
if let url = Environment.get("DATABASE_URL") {
  databaseConfig = try PostgreSQLDatabaseConfig(url: url)
} else {
  let databaseName: String
  let databasePort: Int
  if (env == .testing) {
    databaseName = "vapor-test"
    if let testPort = Environment.get("DATABASE_PORT") {
      databasePort = Int(testPort) ?? 5433
    } else {
      databasePort = 5433
    }
  }
  else {
    databaseName = Environment.get("DATABASE_DB") ?? "vapor"
    databasePort = 5432
  }

  let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
  let username = Environment.get("DATABASE_USER") ?? "vapor"
  let password = Environment.get("DATABASE_PASSWORD") ?? "password"
  databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname, port: databasePort, username: username, database: databaseName, password: password)
}
let database = PostgreSQLDatabase(config: databaseConfig)
databases.add(database: database, as: .psql)
services.register(databases)
```

`configure.swift` SQLiteStorage, SQLiteDatabase

``` swift
// Configure a database
var databases = DatabasesConfig()
var storage: SQLiteStorage!  
switch env {
case .development:
    // default: "/tmp/db.sqlite"
    let sqlitePath = "/Volumes/gMediaHD/VaporProjects/workspace/databases/vapor-til-sqlite.sqlite"
    storage = .file(path: sqlitePath)
case .testing:
    // "/tmp/_swift-tmp.sqlite"
    storage = .memory
case .production:
    storage = .memory
default:
    // includes custom
    storage = .memory
}
let sqliteDb = try SQLiteDatabase(storage:  storage)
databases.add(database: sqliteDb, as: .sqlite) 
services.register(databases)
```


## Additions

**Authentication**

Adds public to `user.swift`.

``` swift
import Authentication


final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
  var password: String
    
    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username
        self.password = password
  }

    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String

        init(id: UUID?, name: String, username: String) {
            self.id = id
            self.name = name
            self.username = username
        }
    }
}
```

Adds file `Models/Token.swift`

## Notes

**`vapor-til-sqlite`** original

* `LinuxMain.swift` not empty. 
    * :TODO: check tests on Linux 
    
* Tests/
    * does not have `AppTests.swift` which does nothing.
    * does have `AcronymTests.swift`, `CategoryTests.swift`, `UserTests.swift`, `Application+Testable.swift`, `Models+Testable.swift`
    * :TODO: check tests with SQLite
    
## Comments <a id="Comments">[▴](#toc)</a>

## Unresolved <a id="Unresolved">[▴](#toc)</a>

`Package.swift`

* .package(url: "https://github.com/vapor/crypto.git", from: "3.1.2"), not present. :TODO:???: Not needed?
* .target(… dependencies: […, "Crypto", "Random"]), not present. :TODO:???: Not needed?

## Resources <a id="Resources">[▴](#toc)</a>

* [GitHub/raywenderlich: vapor-til ⇗](https://github.com/raywenderlich/vapor-til)
* [Ray Wenderlich Video Courses: Server Side Swift with Vapor ⇗](https://videos.raywenderlich.com/courses/115-server-side-swift-with-vapor/lessons/1)
* [Vapor: documentation ⇗](https://docs.vapor.codes/3.0/)