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

若您是要在第一次進入時 創建 DB , 請使用 createDB , 並實現 delegate 裡面的 var SQL : [String]



// instert Multiple Record For Table

func insterts(table:String,datas:[Dictionary<String,AnyObject>])


// update One Record For Table

func update(table:String,data:Dictionary<String,AnyObject>)

// update Multiple Record For Table

func updates(table:String,datas:[Dictionary<String,AnyObject>])

// delete One Record For Table

func delete(table:String,data:Dictionary<String,AnyObject>)

// delete Multiple Record For Table

func delete(table:String,datas:[Dictionary<String,AnyObject>])

// delete Match Datas

func delete(SQL:String,values:[AnyObject])

// delete Where

func delete(table:String,Whree:String,values:[AnyObject])


// delete All Record For Table

func delete(table:String)

// load All Record For Table

func load(table:String)->[Dictionary<String,AnyObject>]

// load Data With SQL

func load(SQL:String,value:[AnyObject])->[Dictionary<String,AnyObject>]

// load Match Datas Form Table And Wheree 

func load(table:String,Where:String,value:[AnyObject])->[Dictionary<String,AnyObject>]{


