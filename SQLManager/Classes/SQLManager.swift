//
//  SQLManager.swift
//  FBSnapshotTestCase
//
//  Created by Nick Lin on 2018/1/31.
//

import Foundation
import FMDB

public protocol SQLDelegate: class {

    func tablePrimaryKey(table: String) -> String
    var SQLsyntaxs: [String] { get }
    var dbPathName: String { get }
}

public class SQLiteManager: NSObject {
    // swiftlint:disable weak_delegate
    fileprivate var delegate: SQLDelegate?
    // swiftlint:enable weak_delegate
    fileprivate var dbQuece: FMDatabaseQueue!

    public init(delegate: SQLDelegate) {
        super.init()
        self.delegate = delegate
    }

    private override init() {
        fatalError("You Need Use 'init(delegate:)'")
    }

    public func createDB() {
        let dbPath = NSHomeDirectory().appending("/Documents" + (delegate?.dbPathName ?? String()))
        if !FileManager.default.fileExists(atPath: dbPath) {
            dbQuece = FMDatabaseQueue(path: dbPath)
            guard let syntaxs = delegate?.SQLsyntaxs else { return }
            dbQuece.inTransaction { (datebase, _) in
                guard let datebase = datebase  else { return }
                do {
                    for S in syntaxs {
                        try datebase.executeUpdate(S, values: nil)
                    }
                } catch {
                    print("create error")
                    print(error)
                }
            }
        } else {
            dbQuece = FMDatabaseQueue(path: dbPath)
        }
    }

    public func loadDB() {

        guard let resourcePath = Bundle.main.resourcePath else { return }
        guard let dbPathName = delegate?.dbPathName else { return }

        let dbPath = NSHomeDirectory().appending("/Documents" + dbPathName)
        let defaultPath = resourcePath.appending(dbPathName)
        if !FileManager.default.fileExists(atPath: dbPath) {
            do {
                try FileManager.default.copyItem(atPath: defaultPath, toPath: dbPath)
            } catch {
                print(error)
            }
        }
        dbQuece = FMDatabaseQueue(path: dbPath)
    }

    public func closeDB() {
        dbQuece.close()
    }

    public func opertion(process: String, value: [Any]) {
        dbQuece.inTransaction { (database, _) in
            guard let database = database else { return }
            do {
                try database.executeUpdate(process, values: value)
            } catch {
                print("process error")
                print(error)
            }
        }
    }

    public func checkTableColumn(table: String, column: String) -> Bool {
        let tables = self.loadMatch(allmatch: "SELECT * FROM sqlite_master", value: [])
        return tables.contains { "\($0["name"]!)" == table && "\($0["sql"]!)".contains(column)}
    }

    public func checkTable(table: String) -> Bool {
        let tables = self.loadMatch(allmatch: "SELECT * FROM sqlite_master", value: [])
        return tables.contains { "\($0["name"]!)" == table }
    }

}

// MARK: - Load
public extension SQLiteManager {
    public func loadAll(table: String) -> [[String: Any]] {
        var data: [[String: Any]] = []
        dbQuece.inDatabase { database in
            guard let database = database else { return }
            do {
                let rs = try database.executeQuery("SELECT * FROM \(table)", values: nil)
                while rs.next() {
                    var dd = [String: Any]()
                    for (key, index) in rs.columnNameToIndexMap {
                        guard let key = key as? String, let index = index as? Int32 else { continue }
                        if let value = rs.object(forColumnIndex: index) {
                            dd[key] = value
                        }
                    }
                    data.append(dd)
                }
            } catch {
                print("loadAll error")
                print(error)
            }
        }
        return data
    }

    public func loadMatch(allmatch: String, value: [Any]) -> [[String: Any]] {
        var data: [[String: Any]] = []
        dbQuece.inDatabase { database in
            guard let database = database else { return }
            do {
                let rs = try database.executeQuery(allmatch, values: value)
                while rs.next() {
                    var dd = [String: Any]()
                    for (key, index) in  rs.columnNameToIndexMap {
                        guard let key = key as? String, let index = index as? Int32 else { continue }
                        if let value = rs.object(forColumnIndex: index) {
                            dd[key] = value
                        }
                    }
                    data.append(dd)
                }
            } catch {
                print(error)
            }
        }
        return data
    }

    public func loadMatch(table: String, match: String, value: [Any]) -> [[String: Any]] {
        var data: [[String: Any]] = []
        dbQuece.inDatabase { (database) in
            guard let database = database else { return }
            do {
                let rs = try database.executeQuery("SELECT * FROM \(table) WHERE " + match, values: value)
                while rs.next() {
                    var dd = [String: Any]()
                    for (key, index) in rs.columnNameToIndexMap {
                        guard let key = key as? String, let index = index as? Int32 else { continue }
                        if let value = rs.object(forColumnIndex: index) {
                            dd[key] = value
                        }
                    }
                    data.append(dd)
                }
            } catch {
                print("\(match) error")
                print(error)
            }
        }
        return data
    }
}

// MARK: - Instert
public extension SQLiteManager {
    public func instert(table: String, data: [String: Any]) {
        var name: String = String()
        var keys: String = String()
        var values: [Any] = []
        var SQL: String = String()
        for (offset: i, (key: key, value: value)) in data.enumerated() {
            name = i == 0 ? "(" + key : ( i == data.keys.count-1 ? name + "," + key + ")" : name + "," + key )
            keys = i == 0 ? "(" + "?" : ( i == data.keys.count-1 ? keys + ",?)" : keys + ",?" )
            values.append(value)
        }
        if data.keys.count > 1 {
            SQL = "INSERT INTO \(table) \(name) values \(keys)"
        } else {
            SQL = "INSERT INTO \(table) \(name)) values \(keys))"
        }
        dbQuece.inDatabase { database in
            guard let database = database else { return }
            do {
                try database.executeUpdate(SQL, values: values)
            } catch {
                print("instert error")
                print(error)
            }
        }
    }

    public func instert(table: String, datas: [[String: Any]]) {
        var SQLArray: [String] = [String]()
        var valuesArray: [[Any]] = []
        for dd in datas {
            var name: String = String()
            var keys: String = String()
            var values: [Any] = []
            for (offset: i, (key: key, value: value)) in dd.enumerated() {
                name = i == 0 ? "(" + key : ( i == dd.keys.count-1 ? name + "," + key + ")" : name + "," + key )
                keys = i == 0 ? "(" + "?" : ( i == dd.keys.count-1 ? keys + ",?)" : keys + ",?" )
                values.append(value)
            }
            SQLArray.append("INSERT INTO \(table) \(name) values \(keys)")
            valuesArray.append(values)
        }

        dbQuece.inTransaction { (database, _) in
            guard let database = database else { return }
            do {
                for i in 0..<SQLArray.count {
                    try database.executeUpdate(SQLArray[i], values: valuesArray[i])
                }
            } catch {
                print("instert error")
                print(error)
            }
        }
    }
}

// MARK: - Update
public extension SQLiteManager {
    public func update(table: String, data: [String: Any]) {
        var name: String = String()
        var values: [Any] = []
        guard let primarykey = delegate?.tablePrimaryKey(table: table) else { return }
        for (offset: _, (key: key, value: value)) in data.enumerated() where key != primarykey {
            name += key + " = ? ,"
            values.append(value)
        }
        name.removeLast()
        if let value = data[primarykey] {
            values.append(value)
        }
        let SQL: String = "UPDATE \(table) SET \(name) WHERE \(primarykey) = ?"
        dbQuece.inDatabase { database in
            guard let database = database else { return }
            do {
                try database.executeUpdate(SQL, values: values)
            } catch {
                print("update error")
                print(error)
            }
        }
    }

    public func update(table: String, datas: [[String: Any]]) {
        guard let primarykey = delegate?.tablePrimaryKey(table: table) else { return }
        var SQLArray: [String] = [String]()
        var valuesArray: [[Any]] = []
        for dd in datas {
            var name: String = String()
            var values: [Any] = []
            for (offset: _, (key: key, value: value)) in dd.enumerated() where key != primarykey {
                name += key + " = ? ,"
                values.append(value)
            }
            name.removeLast()
            if let value = dd[primarykey] {
                values.append(value)
            }
            SQLArray.append("UPDATE \(table) SET \(name) WHERE \(primarykey) = ?")
            valuesArray.append(values)
        }

        dbQuece.inTransaction { (database, _) in
            guard let database = database else { return }
            do {
                for i in 0..<SQLArray.count {
                    try database.executeUpdate(SQLArray[i], values: valuesArray[i])
                }
            } catch {
                print("update error")
                print(error)
            }
        }
    }
}

// MARK: - Delete
public extension SQLiteManager {
    public func delete(table: String, data: [String: Any]) {
        guard let primarykey = delegate?.tablePrimaryKey(table: table) else { return }
        dbQuece.inDatabase { (database) in
            guard let database = database else { return }
            guard let value = data[primarykey] else { return }
            do {
                try database.executeUpdate("DELETE FROM \(table) WHERE \(primarykey) = ?", values: [value])
            } catch {
                print("delete error")
                print(error)
            }
        }
    }

    public func delete(table: String, datas: [[String: Any]]) {
        guard let primarykey = delegate?.tablePrimaryKey(table: table) else { return }
        dbQuece.inTransaction { (database, _) in
            guard let database = database else { return }
            do {
                for data in datas {
                    guard let value = data[primarykey] else { continue }
                    try database.executeUpdate("DELETE FROM \(table) WHERE \(primarykey) = ?", values: [value])
                }
            } catch {
                print("delete error")
                print(error)
            }
        }
    }

    public func deleteMatch(SQL: String, values: [Any]) {
        dbQuece.inDatabase { database in
            guard let database = database else { return }
            do {
                try database.executeUpdate(SQL, values: values)
            } catch {
                print("delete error")
                print(error)
            }
        }
    }

    public func deleteAll(table: String) {
        dbQuece.inDatabase { database in
            guard let database = database else { return }
            do {
                try database.executeUpdate("DELETE FROM \(table)", values: [])
            } catch {
                print("delete error")
                print(error)
            }
        }
    }

    public func delete(table: String, match: String, values: [Any]) {
        dbQuece.inDatabase { database in
            guard let database = database else { return }
            do {
                try database.executeUpdate("DELETE FROM \(table) WHERE \(match)", values: values)
            } catch {
                print("delete error")
                print(error)
            }
        }
    }
}

