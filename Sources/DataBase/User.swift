//
//  User.swift
//  iNoteServerPackageDescription
//
//  Created by haoxian on 2017/10/22.
//
import Foundation
import MySQLStORM
import StORM

class User: MySQLStORM {
    // ⚠️注意⚠️：第一个属性将成为主索引字段，所以应该是ID
    var id: Int = 0
    var phoneNum: String = ""
    var password: String = ""
    var registerTime: String = ""
    
    fileprivate override init() {
        super.init()
        do {
            //确保该模型的表格存在
            try setupTable()
        } catch {
            print(error)
        }
    }
    
    //给对象的表名
    override func table() -> String {
        return "User"
    }
    
    override func to(_ this: StORMRow) {
//        id = this.data["id"] as! Int
        id = numericCast(this.data["id"] as! Int32)
        phoneNum = this.data["phoneNum"] as! String
        password = this.data["password"] as! String
        registerTime = this.data["registerTime"] as! String
    }
    
    fileprivate func rows() -> [User] {
        var rows: [User] = []
        for r in results.rows {
            let row = User()
            row.to(r)
            rows.append(row)
        }
        return rows
    }
}

//API相关操作
extension User {
    //验证用户是否存在
    fileprivate func findUserWith(_ phone: String) {
        // fine: 如果在数据库中匹配到了，则将字段的内容赋值给对象中的属性，否则什么都不做
        do {
            try find([("phoneNum",phone)])
        } catch {
            print(error)
        }
    }
    
    //注册用户
    static func register(phone: String, pwd: String) -> (String, Bool) {
        let user = User()
        user.findUserWith(phone)
        // id为0则表示数据库中不存在
        let exists = user.id != 0 ? true : false
        let message = exists ? "用户已存在" : "注册成功"
        guard !exists else {
            return (message, exists)
        }
        user.phoneNum = phone
        user.password = pwd
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        user.registerTime = formatter.string(from: date)
        do {
            try user.save(set: { (ID) in
                user.id = ID as! Int
            })
        } catch {
            print(error)
        }
        return (message, exists)
    }
    
    //登录 -> 返回（操作结果， 结果信息， 用户信息）
    static func userLoginWith(phone: String, pwd: String) -> (Bool, String, [String:String]) {
        let user = User()
        user.findUserWith(phone)
        if user.phoneNum == phone && user.password == pwd {
            let info = [
                            "userId": "\(user.id)",
                            "phoneNum": user.phoneNum,
                            "registerTime": user.registerTime
                        ]
            return (true, "登录成功", info)
        } else {
            let info = ["userId": "", "phoneNum": "", "registerTime": ""]
            return (false, "用户名或密码错误", info)
        }
    }
}
