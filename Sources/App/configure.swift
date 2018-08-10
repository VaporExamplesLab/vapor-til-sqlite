/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import FluentSQLite
import Vapor
import Leaf
import Authentication

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
    ) throws {
    // Register providers first
    try services.register(FluentSQLiteProvider())
    try services.register(LeafProvider())
    try services.register(AuthenticationProvider())
    
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)
    
    // Configure a database
    var storage: SQLiteStorage!  
    //print("Environment (env): \(env)")
    //print("ProcessInfo (environment): \(ProcessInfo.processInfo.environment)")
    switch env {
    case .development:
        // default: "/tmp/db.sqlite"
        // exported absolute VAPOR_DATABASE_HOME path
        if let databaseHomePath = Environment.get("VAPOR_DATABASE_HOME") {
            let sqlitePath = "\(databaseHomePath)/vapor-til-sqlite.db"
            storage =  .file(path: sqlitePath)
        }
        else {
            storage = .memory
        }
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
    var databases = DatabasesConfig()
    databases.add(database: sqliteDb, as: .sqlite) 
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .sqlite)
    migrations.add(model: Acronym.self, database: .sqlite)
    migrations.add(model: Category.self, database: .sqlite)
    migrations.add(model: AcronymCategoryPivot.self, database: .sqlite)
    migrations.add(model: Token.self, database: .sqlite)
    migrations.add(migration: AdminUser.self, database: .sqlite)
    services.register(migrations)
    
    // Configure the rest of your application here
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands() // "revert", "migrate"
    services.register(commandConfig)
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}
