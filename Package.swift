
import PackageDescription

let versions = Version(0,0,0)..<Version(10,0,0)
let urls = [
    "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", //服务端核心框架
    "https://github.com/SwiftORM/MySQL-StORM.git", //对象关系型数据库
    "https://github.com/PerfectlySoft/Perfect-Logger.git",
    "https://github.com/PerfectlySoft/Perfect-RequestLogger.git"
]

let package = Package(
    name: "iNoteServer",
    targets: [],
    dependencies: urls.map { .Package(url: $0, versions: versions) }
)
