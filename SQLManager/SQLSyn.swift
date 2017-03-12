//
//  SQLSyn.swift
//  test
//
//  Created by nick on 2016/12/13.
//  Copyright © 2016年 nick. All rights reserved.
//

import UIKit

/*
//範例
    var SQLsyntaxs: [String] = [
        
        SQLite(create: "user")
            .cloumn("id").INTEGER.PRIMARYKEY.AUTOINCREMENT.NOTNULL
            .cloumn("name").TEXT
            .cloumn("gender").TEXT
            .cloumn("age").INTEGER
            .cloumn("addres").TEXT
            .value ,
        SQLite(create: "postcode")
            .cloumn("id").INTEGER.PRIMARYKEY.AUTOINCREMENT.NOTNULL
            .cloumn("country").TEXT
            .cloumn("city").TEXT
            .cloumn("township").TEXT
            .cloumn("code").INTEGER
            .value
    ]
// */

/// MARK:- SQLite Syntax Help
final public class SQLite {
    private enum type {
        case create
        case alter
    }
    private var count = 0
    private var syntax : String = ""
    private var style : type!
    
    private init() { }
    
    /// 新建  table
    public convenience init(create table: String) {
        self.init()
        syntax = "CREATE TABLE '\(table)' ( "
        style = .create
    }
    
    /// 更改 table 內容
    public convenience init(alter table: String) {
        self.init()
        syntax = "ALTER TABLE '\(table)' ADD COLUMN "
        style = .alter
    }
    
    /// 添加欄位
    /// - Parameter cloum: 欄位名
    public func cloumn(_ cloum:String) -> SQLite{
        count == 0 ? (count += 1) : (syntax += (style == .create ? ", " : "" ))
        syntax += "'\(cloum)' "
        return self
    }
    /// 欄位型別 INTEGER
    public var INTEGER : SQLite {
        syntax += "INTEGER "
        return self
    }
    /// 欄位型別 TEXT
    public var TEXT : SQLite {
        syntax += "TEXT "
        return self
    }
    /// 主鍵
    public var PRIMARYKEY : SQLite {
        syntax += "PRIMARY KEY "
        return self
    }
    /// 自動遞增
    public var AUTOINCREMENT : SQLite {
        syntax += "AUTOINCREMENT "
        return self
    }
    /// not null
    public var NOTNULL : SQLite {
        syntax += "NOT NULL "
        return self
    }
    /// 取值
    public var value : String{
        return syntax + (style == .create ? ")" : "")
    }
}
