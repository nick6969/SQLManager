//
//  SQLManger.swift
//  SQLite
//
//  Created by nick on 2016/7/12.
//  Copyright © 2016年 Lin.Nick. All rights reserved.
//

import UIKit
import FMDB

@objc protocol SQLDelegate {
    
    /// all table's primarykey
    func tablePrimaryKey(table :String)->String
    
    /// use createDB need set this Array , This is Create table SQL
    @objc optional var SQL : [String] { get }
    
    
    /// DataBase Sqlite File Name and Path
    var dbPathName : String { get }
}

class SQLiteManager {
    /*
        You need create new Class and this Class need conform SQLdelegate
    */
    
    var delegate : SQLDelegate!
    var dbQuece: FMDatabaseQueue!
    
    // setting Delegate
    init(delegate:SQLDelegate) {
        self.delegate = delegate
    }
    
    /// Create Database
    func createDB(){
        
        let dbPath = NSHomeDirectory().appending("/Documents" + delegate!.dbPathName)
        if !FileManager.default.fileExists(atPath:dbPath){
            if delegate!.SQL != nil {
                dbQuece = FMDatabaseQueue(path: dbPath)
                dbQuece.inTransaction { (db, nil) in
                    do {
                        for S in self.delegate!.SQL!{
                            try db!.executeUpdate(S, values: nil)
                        }
                    }catch{
                        print("create error")
                        print(error)
                    }
                }
                dbQuece = FMDatabaseQueue(path: dbPath)
            }else{
                fatalError("Use createDB need Confrom Delegate 'var SQL : [String]' ")
            }
            
        }else{
            dbQuece = FMDatabaseQueue(path: dbPath)
        }
    }

    
    /// load Datebase
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
    
    /// instert One Record For Table
    func instert(table:String,data:Dictionary<String,AnyObject>){
        var name : String = ""
        var keys : String = ""
        var values : [AnyObject] = []
        
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
    
    /// instert Multiple Record For Table
    func insterts(table:String,datas:[Dictionary<String,AnyObject>]){
        var SQLArray : [String] = [String]()
        var valuesArray : [[AnyObject]] = []
        for dd in datas{
            var name : String = ""
            var keys : String = ""
            var values : [AnyObject] = []
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
    
    /// update One Record For Table
    func update(table:String,data:Dictionary<String,AnyObject>){
        var name : String = ""
        var values : [AnyObject] = []
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
    
    /// update Multiple Record For Table
    func updates(table:String,datas:[Dictionary<String,AnyObject>]){
        let primarykey : String = delegate!.tablePrimaryKey(table: table)
        var SQLArray : [String] = [String]()
        var valuesArray : [[AnyObject]] = []
        for dd in datas{
            var name : String = ""
            var values : [AnyObject] = []
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

    /// delete One Record For Table
    func delete(table:String,data:Dictionary<String,AnyObject>){
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
    
    /// delete Multiple Record For Table
    func delete(table:String,datas:[Dictionary<String,AnyObject>]){
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

    /// delete Match Datas
    func delete(SQL:String,values:[AnyObject]){
        dbQuece.inDatabase { (db) in
            do {
                try db!.executeUpdate(SQL, values: values)
            }catch{
                print("delete error")
                print(error)
            }
        }
    }
    
    /// delete Where
    func delete(table:String,Whree:String,values:[AnyObject]){
        dbQuece.inDatabase { (db) in
            do {
                try db!.executeUpdate("DELETE FROM \(table) WHERE \(Whree)", values: values)
            }catch{
                print("delete error")
                print(error)
            }
        }
    }
    
    
    /// delete All Record For Table
    func delete(table:String){
        dbQuece.inDatabase { (db) in
            do {
                try db?.executeUpdate("DELETE FROM \(table)", values: [])
            }catch{
                print("delete error")
                print(error)
            }
        }
    }
    
    /// load All Record For Table
    func load(table:String)->[Dictionary<String,AnyObject>]{
        var data : [Dictionary<String,AnyObject>] = [Dictionary<String,AnyObject>]()
        dbQuece.inDatabase { (db) in
            do {
                let rs = try db!.executeQuery("SELECT * FROM \(table)", values: nil)
                while rs.next(){
                    var dd = Dictionary<String,AnyObject>()
                    for (key,value) in  rs.columnNameToIndexMap{
                        dd.updateValue(value as AnyObject, forKey: key as! String)
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
    
    /// load Data With SQL
    func load(SQL:String,value:[AnyObject])->[Dictionary<String,AnyObject>]{
        var data : [Dictionary<String,AnyObject>] = [Dictionary<String,AnyObject>]()
        dbQuece.inDatabase { (db) in
            do {
                let rs = try db!.executeQuery(SQL, values: value)
                while rs.next(){
                    var dd = Dictionary<String,AnyObject>()
                    for (key,value) in  rs.columnNameToIndexMap{
                        dd.updateValue(value as AnyObject, forKey: key as! String)
                    }
                    data.append(dd)
                }
            }catch{
                print(error)
            }
        }
        return data
    }
    
    /// load Match Datas Form Table And Wheree
    func load(table:String,Where:String,value:[AnyObject])->[Dictionary<String,AnyObject>]{
        var data : [Dictionary<String,AnyObject>] = [Dictionary<String,AnyObject>]()
        dbQuece.inDatabase { (db) in
            do {
                let rs = try db!.executeQuery("SELECT * FROM \(table) WHERE " + Where, values: value)
                while rs.next(){
                    var dd = Dictionary<String,AnyObject>()
                    for (key,value) in  rs.columnNameToIndexMap{
                        dd.updateValue(value as AnyObject, forKey: key as! String)
                    }
                    data.append(dd)
                }
            }catch{
                print("\(Where) error")
                print(error)
            }
        }
        return data
    }
 
    
}







