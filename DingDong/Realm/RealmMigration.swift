//
//  RealmMigration.swift
//  DingDong
//
//  Created by Seppuu on 16/6/16.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import Foundation
import RealmSwift

let RealmConfig = Realm.Configuration(
    // 设置新的架构版本。这个版本号必须高于之前所用的版本号（如果您之前从未设置过架构版本，那么这个版本号设置为 0）
    schemaVersion: 4,
    
    // 设置闭包，这个闭包将会在打开低于上面所设置版本号的 Realm 数据库的时候被自动调用
    migrationBlock: { migration, oldSchemaVersion in
        // 目前我们还未进行数据迁移，因此 oldSchemaVersion == 0
        if (oldSchemaVersion < 4) {
            // 什么都不要做！Realm 会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库架构
        }
})

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        
        return array
    }
}
