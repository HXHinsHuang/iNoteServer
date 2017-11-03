//
//  NetworkServerManager.swift
//  iNoteServerPackageDescription
//
//  Created by haoxian on 2017/10/22.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

// MARK:- status状态
enum ResponseStatus: String {
    case success = "SUCCESS"
    case failure = "FAILURE"
}

class NetworkServerManager {
    // 创建HTTP服务器
    let server = HTTPServer()
    //创建路由组，用来存放各个路由
    var routes = Routes(baseUri: iNoteAIP.base.rawValue)
    
    static let share = NetworkServerManager()
    private init() {
        //注册您自己的路由和请求／响应句柄 (请求方法,地址,请求处理)
        configure()
    }
    
    func serverStart(_ port: UInt16 = 8181) {
        // 监听8181端口
        server.serverPort = port
        // 将路由注册到服务器上
        server.addRoutes(routes)
        // 启动服务器
        do {
            try server.start()
        } catch PerfectError.networkError(let code, let msg) {
            print("network error:\(code) \(msg)")
        } catch {
            print("unknow network error: \(error)")
        }
    }
    
    //uri适应iNoteAIP中的枚举值字符串
    func addRouteWith(method: HTTPMethod, uri: iNoteAIP, handler: @escaping RequestHandler) {
        routes.add(method: method, uri: uri.rawValue, handler: handler)
    }
}

extension NetworkServerManager {
    //添加各模块的路由
    func configure() {
        //登录注册接口的路由
        addRouteWith(method: .post, uri: .register, handler: userRegisterHandle())
        addRouteWith(method: .post, uri: .login, handler: userLoginHandle())
        //笔记的CURD接口的路由
        addRouteWith(method: .get, uri: .contentList, handler: getNoteContentListHandle())
        addRouteWith(method: .post, uri: .addNote, handler: addNoteHandel())
        addRouteWith(method: .delete, uri: .deleteNote, handler: deleteNoteHandle())
        addRouteWith(method: .post, uri: .modifyNote, handler: modifyNoteHandle())
    }
}

extension NetworkServerManager {
    // 处理要返回的响应体，构建json格式
    func requestHandle(request: HTTPRequest, response: HTTPResponse, status: ResponseStatus, result: Bool, resultMessage: String, data:[[String:Any]]?) {
        let jsonDic: [String:Any]
        jsonDic = [
            "status":status.rawValue,
            "result": result,
             "message":resultMessage,
             "data":data ?? []
        ]
        do {
            //jsonEncodedString: 对字典的扩展方法，返回对应json格式的字符串
            let json = try jsonDic.jsonEncodedString()
            response.setBody(string: json)
        } catch {
            print(error)
        }
        response.completed()
    }
}

// MARK:- 注册和登录
extension NetworkServerManager {
    
    func userRegisterHandle() -> RequestHandler {
        return {[weak self] request, response in
            guard let phoneNum =  request.param(name: "phoneNum"),
                  let password = request.param(name: "password"),
                  phoneNum.characters.count > 0,
                  password.characters.count > 0
            else {
                self?.requestHandle(request: request, response: response, status: .failure, result: false, resultMessage: "缺少对应参数", data: nil)
                return
            }
            
            
            let (message, exists) = DatabaseManager.share.registerWith(phoneNum: phoneNum, password: password)
            let status: ResponseStatus = exists ? .failure : .success
            self?.requestHandle(request: request, response: response, status: status, result: !exists, resultMessage: message, data: nil)
        }
    }
    
    func userLoginHandle() -> RequestHandler {
        return {[weak self] request, response in
            guard let phoneNum =  request.param(name: "phoneNum"),
                  let password = request.param(name: "password"),
                  phoneNum.characters.count > 0,
                  password.characters.count > 0
            else {
                self?.requestHandle(request: request, response: response, status: .failure, result: false, resultMessage: "缺少对应参数", data: nil)
                return
            }
            // 操作是否成功， 结果信息， 用户信息
            let (result, msg, info) = DatabaseManager.share.loginWith(phoneNum: phoneNum, password: password)
            let status: ResponseStatus = result ? .success : .failure
            self?.requestHandle(request: request, response: response, status: status, result: result, resultMessage: msg, data: [info])
        }
    }
    
}

// MARK:- 笔记CURD
extension NetworkServerManager {
    
    func getNoteContentListHandle() -> RequestHandler {
        return {[weak self] request, response in
            
            guard let userId = request.param(name: "userId"),
                  userId.characters.count > 0
            else {
                self?.requestHandle(request: request, response: response, status: .failure, result: false, resultMessage: "缺少对应参数", data: nil)
                return
            }
            
            let notes = DatabaseManager.share.getNoteContentList(userId)
            self?.requestHandle(request: request, response: response, status: .success, result: true, resultMessage: "获取成功", data: notes)
        }
    }
    
    func addNoteHandel() -> RequestHandler {
        return {[weak self] request, response in
            
            guard let userId = request.param(name: "userId"),
                  let title = request.param(name: "title"),
                  let content = request.param(name: "content"),
                  userId.characters.count > 0,
                  title.characters.count > 0,
                  content.characters.count > 0
            else {
                self?.requestHandle(request: request, response: response, status: .failure, result: false, resultMessage: "缺少对应参数", data: nil)
                return
            }
            
            let data = DatabaseManager.share.addNote(userId: userId, title: title, content: content)
            self?.requestHandle(request: request, response: response, status: .success, result: true, resultMessage: "添加成功", data: [data])
        }
    }
    
    func deleteNoteHandle() -> RequestHandler {
        return {[weak self] request, response in
            
            guard let id = request.param(name: "id"),
                  id.characters.count > 0
            else {
                self?.requestHandle(request: request, response: response, status: .failure, result: false, resultMessage: "缺少对应参数", data: nil)
                return
            }
            
            let data = DatabaseManager.share.delteNote(id)
            self?.requestHandle(request: request, response: response, status: .success, result: true, resultMessage: "删除成功", data: [data])
        }
    }
    
    func modifyNoteHandle() -> RequestHandler {
        return {[weak self] request, response in
            
            guard let id = request.param(name: "id"),
                  let title = request.param(name: "title"),
                  let content = request.param(name: "content"),
                  id.characters.count > 0,
                  title.characters.count > 0,
                  content.characters.count > 0
            else {
                self?.requestHandle(request: request, response: response, status: .failure, result: false, resultMessage: "缺少对应参数", data: nil)
                return
            }
            
            let (result, msg, data) = DatabaseManager.share.modifyNote(id: id, title: title, content: content)
            let status: ResponseStatus = result ? .success : .failure
            self?.requestHandle(request: request, response: response, status: status, result: result, resultMessage: msg, data: [data])
        }
    }
}






