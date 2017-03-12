//
//  DBM.swift
//  SQLManager
//
//  Created by nickLin on 03/12/2017.
//  Copyright © 2017年 nickLin. All rights reserved.
//

import UIKit

let DBM = SQLiteManager(delegate:DBHelp())

class DBHelp : SQLDelegate {
    /// all table's primarykey
    func tablePrimaryKey(table :String)->String {
        return "id"
    }
    
    
    /// Create Datebase will use
    var SQLsyntaxs : [String] {
        
        var sqlsyntaxs : [String] = []
        
        let user = SQLite(create: DB_User.tableName)
            .cloumn(DB_User.id).INTEGER.NOTNULL.PRIMARYKEY.AUTOINCREMENT
            .cloumn(DB_User.web_id).INTEGER
            .cloumn(DB_User.email).TEXT
            .cloumn(DB_User.phone).TEXT
            .cloumn(DB_User.openid).TEXT
            .cloumn(DB_User.password).TEXT
            .cloumn(DB_User.birthday).TEXT
            .cloumn(DB_User.gender).INTEGER
            .value
        
        sqlsyntaxs.append(user)
        
        // you can append More table in here
        
        
        
        
        return sqlsyntaxs
        
    }
    
    
    
    /// DataBase Sqlite File Name and Path
    var dbPathName : String = "/SQLiteManager.sqlite"
    
}

// you can use enum
enum DB_User {
    static let tableName    = "user"
    
    static let id           = "id"
    static let web_id       = "web_id"
    static let email        = "email"
    static let phone        = "phone"
    static let openid       = "openid"
    static let password     = "password"
    static let birthday     = "birthday"
    static let gender       = "gender"
}
