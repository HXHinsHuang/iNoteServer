
import PackageDescription

let versions = Version(0,0,0)..<Version(10,0,0)
let urls = [
    "https://github.com/PerfectlySoft/Perfect-HTTPServer.git",
    "https://github.com/SwiftORM/MySQL-StORM.git",
    "https://github.com/PerfectlySoft/Perfect-Logger.git",
    "https://github.com/PerfectlySoft/Perfect-RequestLogger.git"
]

let package = Package(
    name: "iNoteServer",
    targets: [],
    dependencies: urls.map { .Package(url: $0, versions: versions) }
)
