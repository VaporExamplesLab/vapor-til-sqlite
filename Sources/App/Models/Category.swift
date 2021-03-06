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

import Vapor
import FluentSQLite

final class Category: Codable {
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Category: SQLiteModel {}
extension Category: Content {}
extension Category: Migration {}
extension Category: Parameter {}

extension Category {
    var acronyms: Siblings<Category, Acronym, AcronymCategoryPivot> {
        return siblings()
    }
    
    static func addCategory(_ name: String, to acronym: Acronym,
                            on req: Request) throws -> Future<Void> {
        return Category.query(on: req).filter(\.name == name).first().flatMap(to: Void.self) { foundCategory in
            if let existingCategory = foundCategory {
                return acronym.categories.attach(existingCategory, on: req).transform(to: ())
            } else {
                let category = Category(name: name)
                return category.save(on: req).flatMap(to: Void.self) { savedCategory in
                    return acronym.categories.attach(savedCategory, on: req).transform(to: ())
                }
            }
        }
    }
    
    //static func addCategory(_ name: String, to acronym: Acronym,
    //                        on req: Request) throws
    //    -> Future<Void> {
    //        // 1
    //        return Category.query(on: req)
    //            .filter(\.name == name)
    //            .first()
    //            .flatMap(to: Void.self) { foundCategory in
    //                if let existingCategory = foundCategory {
    //                    // 2
    //                    let pivot
    //                        = try AcronymCategoryPivot(acronym.requireID(),
    //                                                   existingCategory.requireID())
    //                    // 3
    //                    return pivot.save(on: req).transform(to: ())
    //                } else {
    //                    // 4
    //                    let category = Category(name: name)
    //                    // 5
    //                    return category.save(on: req)
    //                        .flatMap(to: Void.self) { savedCategory in
    //                            // 6
    //                            let pivot
    //                                = try AcronymCategoryPivot(acronym.requireID(),
    //                                                           savedCategory.requireID())
    //                            // 7
    //                            return pivot.save(on: req).transform(to: ())
    //                    }
    //                }
    //        }
    //}
    
    
}
