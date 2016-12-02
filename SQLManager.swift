//
//  SQLManger.swift
//  SQLite
//
//  Created by nick on 2016/7/12.
//  Copyright © 2016年 Lin.Nick. All rights reserved.
//

/* Swift 3.0 Xcode 8.1 */
/* 最後修改時間 2016/12/01 */


import UIKit

/// SQLiteManager init need
@objc protocol SQLDelegate {
    
    /// all table's primarykey
    func tablePrimaryKey(table :String)->String
    
    /// Create Datebase use
    @objc optional var SQLsyntaxs : [String]{ get }
    
    /// DataBase Sqlite File Name and Path
    var dbPathName : String { get }
}

/// Quick use SQLite Datebase , init need have some class conform SQLDelegate
class SQLiteManager: NSObject {
    /*
        You need init form init(delegate: protocol<SQLDelegate>)
    */
    
    private var delegate : SQLDelegate?
    private var dbQuece: FMDatabaseQueue!
    
    /// initialization
    init(delegate: SQLDelegate){
        super.init()
        self.delegate = delegate
    }
    
    /// Do not Use This initialization
    private override init() {
        fatalError("You Need Use 'init(delegate:)'")
    }
  
    
    /// load SQLite File with Path(first time will create form SQLsyntaxs)
    /// need Confrom Delegate 'var SQLsyntaxs : [String]' "
    func createDB(){
        let dbPath = NSHomeDirectory().appending("/Documents" + delegate!.dbPathName)
        if !FileManager.default.fileExists(atPath:dbPath){
            if delegate!.SQLsyntaxs != nil {
                dbQuece = FMDatabaseQueue(path: dbPath)
                dbQuece.inTransaction { (db, nil) in
                    do {
                        for S in self.delegate!.SQLsyntaxs!{
                            try db!.executeUpdate(S, values: nil)
                        }
                    }catch{
                        print("create error")
                        print(error)
                    }
                }
                dbQuece = FMDatabaseQueue(path: dbPath)
            }else{
                fatalError("Use createDB need Confrom Delegate 'var SQLsyntaxs : [String]' ")
            }
            
        }else{
            dbQuece = FMDatabaseQueue(path: dbPath)
        }
    }
    
    
    /// load SQLite File with Path(first time will copy form resourcePath)
    func loadDB(){

        let dbPath = NSHomeDirectory().appending("/Documents" + delegate!.dbPathName)
        
        let defaultPath = Bundle.main.resourcePath!.appending(delegate!.dbPathName)
        if !FileManager.default.fileExists(atPath:dbPath){
            do{
                try FileManager.default.copyItem(atPath: defaultPath, toPath: dbPath)
            }catch{
                print(error)
            }
        }
        dbQuece = FMDatabaseQueue(path: dbPath)
    }
    
    /// instert One Record
    ///
    /// - parameter table: SQLite table Name
    /// - parameter data:  instert Data with Dictionary
    func instert(table:String,data:Dictionary<String,Any>){
        var name : String = ""
        var keys : String = ""
        var values : [Any] = []
        for (offset:i,(key:key,value:value)) in data.enumerated(){
            name = i == 0 ? "(" + key : ( i == data.keys.count-1 ? name + "," + key + ")" : name + "," + key )
            keys = i == 0 ? "(" + "?" : ( i == data.keys.count-1 ? keys + ",?)" : keys + ",?" )
            values.append(value)
        }
        let SQL : String = "INSERT INTO \(table) \(name) values \(keys)"
        dbQuece.inDatabase { (db) in
            do {
                try db!.executeUpdate(SQL , values: values)
            }catch{
                print("instert error")
                print(error)
            }
        }
    }
    
    /// instert Multiple Record
    ///
    /// - parameter table: SQLite table Name
    /// - parameter data:  instert Datas with Dictionarys
    func instert(table:String,datas:[Dictionary<String,Any>]){
        var SQLArray : [String] = [String]()
        var valuesArray : [[Any]] = []
        for dd in datas{
            var name : String = ""
            var keys : String = ""
            var values : [Any] = []
            for (offset:i,(key:key,value:value)) in dd.enumerated(){
                name = i == 0 ? "(" + key : ( i == dd.keys.count-1 ? name + "," + key + ")" : name + "," + key )
                keys = i == 0 ? "(" + "?" : ( i == dd.keys.count-1 ? keys + ",?)" : keys + ",?" )
                values.append(value)
            }
            SQLArray.append("INSERT INTO \(table) \(name) values \(keys)")
            valuesArray.append(values)
        }
        
        dbQuece.inTransaction { (db, nil) in
            do {
                for i in 0...SQLArray.count-1{
                    try db!.executeUpdate(SQLArray[i], values: valuesArray[i])
                }
            }catch{
                print("instert error")
                print(error)
            }
        }
    }
    
    /// update One Record
    ///
    /// - parameter table: SQLite table Name
    /// - parameter data:  update Data with Dictionary
    func update(table:String,data:Dictionary<String,Any>){
        var name : String = ""
        var values : [Any] = []
        let primarykey : String = delegate!.tablePrimaryKey(table: table)
        for (offset:_,(key:key,value:value)) in data.enumerated(){
            if key != primarykey{
                name += key + " = ? ,"
                values.append(value)
            }
        }
        name.characters.removeLast()
        values.append(data[primarykey]!)
        let SQL : String = "UPDATE \(table) SET \(name) WHERE \(primarykey) = ?"
        dbQuece.inDatabase { (db) in
            do {
                try db!.executeUpdate(SQL, values: values)
            }catch{
                print("update error")
                print(error)
            }
        }
    }

    /// update Multiple Record
    ///
    /// - parameter table: SQLite table Name
    /// - parameter data:  update Datas with Dictionarys
    func update(table:String,datas:[Dictionary<String,Any>]){
        let primarykey : String = delegate!.tablePrimaryKey(table: table)
        var SQLArray : [String] = [String]()
        var valuesArray : [[Any]] = []
        for dd in datas{
            var name : String = ""
            var values : [Any] = []
            for (offset:_,(key:key,value:value)) in dd.enumerated(){
                if key != primarykey{
                    name += key + " = ? ,"
                    values.append(value)
                }
            }
            name.characters.removeLast()
            values.append(dd[primarykey]!)
            SQLArray.append("UPDATE \(table) SET \(name) WHERE \(primarykey) = ?")
            valuesArray.append(values)
        }
        
        dbQuece.inTransaction { (db, nil) in
            do {
                for i in 0...SQLArray.count-1{
                    try db!.executeUpdate(SQLArray[i], values: valuesArray[i])
                }
            }catch{
                print("update error")
                print(error)
            }
        }
    }

    /// delete One Record
    ///
    /// - parameter table: SQLite table Name
    /// - parameter data:  delete Data with Dictionary
    func delete(table:String,data:Dictionary<String,Any>){
        let primarykey : String = delegate!.tablePrimaryKey(table: table)
        dbQuece.inDatabase { (db) in
            do {
                try db!.executeUpdate("DELETE FROM \(table) WHERE \(primarykey) = ?", values: [data[primarykey]!])
            }catch{
                print("delete error")
                print(error)
            }
        }
    }
    
    /// delete Multiple Record
    ///
    /// - parameter table: SQLite table Name
    /// - parameter data:  delete Datas with Dictionarys
    func delete(table:String,datas:[Dictionary<String,Any>]){
        let primarykey : String = delegate!.tablePrimaryKey(table: table)
        dbQuece.inTransaction { (db, nil) in
            do {
                for data in datas{
                    try db!.executeUpdate("DELETE FROM \(table) WHERE \(primarykey) = ?", values: [data[primarykey]!])
                }
            }catch{
                print("delete error")
                print(error)
            }
        }
    }

    /// delete the match condition data
    ///
    /// - parameter SQL:    SQL Syntax
    /// - parameter values: value with SQL Syntax
    func deleteMatch(SQL:String,values:[Any]){
        dbQuece.inDatabase { (db) in
            do {
                try db!.executeUpdate(SQL, values: values)
            }catch{
                print("delete error")
                print(error)
            }
        }
    }
    
    
    
    
    /// delete the match SQLite table Name all data
    ///
    /// - parameter table: SQLite table Name
    func deleteAll(table:String){
        dbQuece.inDatabase { (db) in
            do {
                try db?.executeUpdate("DELETE FROM \(table)", values: [])
            }catch{
                print("delete error")
                print(error)
            }
        }
    }
    
    /// delete the match SQLite table Name And
    ///
    /// - parameter table:  SQLite table Name
    /// - parameter Whree:  conditon
    /// - parameter values: value with SQL Syntax
    func delete(table:String,Whree:String,values:[Any]){
        dbQuece.inDatabase { (db) in
            do {
                try db!.executeUpdate("DELETE FROM \(table) WHERE \(Whree)", values: values)
            }catch{
                print("delete error")
                print(error)
            }
        }
    }

    
    /// lodaing the match SQLite table Name all data
    ///
    /// - parameter table: SQLite table Name
    func loadAll(table:String)->[Dictionary<String,Any>]{
        var data : [Dictionary<String,Any>] = [Dictionary<String,Any>]()
        dbQuece.inDatabase { (db) in
            do {
                let rs = try db!.executeQuery("SELECT * FROM \(table)", values: nil)
                while rs.next(){
                    var dd = Dictionary<String,Any>()
                    for (key,index) in  rs.columnNameToIndexMap{
                        dd[key as! String] = rs.object(forColumnIndex: index as! Int32)!
                    }
                    data.append(dd)
                }
            }catch{
                print("loadAll error")
                print(error)
            }
        }
        return data
    }
    
    /// load the match condition data
    ///
    /// - parameter Allmatch: SQL Syntax
    /// - parameter value:    value with SQL Syntax
    ///
    /// - returns: load the match condition datas
    func loadMatch(Allmatch:String,value:[Any])->[Dictionary<String,Any>]{
        var data : [Dictionary<String,Any>] = [Dictionary<String,Any>]()
        dbQuece.inDatabase { (db) in
            do {
                let rs = try db!.executeQuery(Allmatch, values: value)
                while rs.next(){
                    var dd = Dictionary<String,Any>()
                    for (key,index) in  rs.columnNameToIndexMap{
                        dd[key as! String] = rs.object(forColumnIndex: index as! Int32)!
                    }
                    data.append(dd)
                }
            }catch{
                print(error)
            }
        }
        return data
    }
    
    /// load the match condition data with SQL table
    ///
    /// - parameter table: SQLite table Name
    /// - parameter match: SQL Syntax
    /// - parameter value: value with SQL Syntax
    ///
    /// - returns: load the match condition datas with SQL table
    func loadMatch(table:String,match:String,value:[Any])->[Dictionary<String,Any>]{
        var data : [Dictionary<String,Any>] = [Dictionary<String,Any>]()
        dbQuece.inDatabase { (db) in
            do {
                let rs = try db!.executeQuery("SELECT * FROM \(table) WHERE " + match, values: value)
                while rs.next(){
                    var dd = Dictionary<String,Any>()
                    for (key,index) in  rs.columnNameToIndexMap{
                        dd[key as! String] = rs.object(forColumnIndex: index as! Int32)!
                    }
                    data.append(dd)
                }
            }catch{
                print("\(match) error")
                print(error)
            }
        }
        return data
    }
    /// dataBase Opertion
    ///
    /// - Parameters:
    /// - process: SQL Syntax
    /// - value: value with SQL Syntax
    func opertion(process:String,value:[Any]){
        dbQuece.inTransaction { (db, nil) in
            do {
                try db!.executeUpdate(process, values: value)
            }catch{
                print("process error")
                print(error)
            }
        }
    }
    /// conform Database specific table has column
    ///
    /// - Parameters:
    /// - Table: tableName
    /// - Column: columnName
    /// - Returns: isHave
    func checkTableColumn(table Table:String,Column:String)->Bool{
        let tables = self.loadMatch(Allmatch: "SELECT * FROM sqlite_master", value: [])
        return tables.contains{ "\($0["name"]!)" == Table && "\($0["sql"]!)".contains(Column)}
    }
    /// conform Database has table
    ///
    /// - Parameters:
    /// - Table: tableName
    /// - Returns: isHave
    func checkTable(table Table:String)->Bool{
        let tables = self.loadMatch(Allmatch: "SELECT * FROM sqlite_master", value: [])
        return tables.contains{ "\($0["name"]!)" == Table }
    }

}
