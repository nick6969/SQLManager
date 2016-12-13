# SQLiteManager


這是一個封裝 FMDB 的工具類

可以簡單的 操作 Sqlite

記得要先 pod 'FMDB'

// 直接將 SQLManager.swift 拉近您的專案即可使用

使用方法如下：

首先創建一個 Class 符合 SQLDelegate

然後 將 SQLManager 初始化

    init(delegate:SQLDelegate)

然後就可以直接使用

若您是將 .sqlite 直接放進專案中 , 請使用 loadDB 來複製 .sqlite

若您是要在第一次進入時 創建 DB , 請使用 createDB , 並實現 delegate 裡面的 var SQLsyntaxs : [String]

2016-12-13
新增 SQLite 類，簡單的撰寫 創建 table 語法，並且可讀性比原本的寫法更好


