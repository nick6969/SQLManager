# SQLManager

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SQLManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SQLManager'
```

## Author

hawhaw.ya@gmail.com

## License

SQLManager is available under the MIT license. See the LICENSE file for more info.


## Using

這是一個封裝 FMDB 的工具類

可以簡單的 操作 Sqlite

使用方法如下：

首先創建一個 Class 符合 SQLDelegate

然後 將 SQLManager 初始化

init(delegate:SQLDelegate)

然後就可以直接使用

若您是將 .sqlite 直接放進專案中 , 請使用 loadDB 來複製 .sqlite

若您是要在第一次進入時 創建 DB , 請使用 createDB , 並實現 delegate 裡面的 var SQLsyntaxs : [String]
