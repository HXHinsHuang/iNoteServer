//
//  NetworkServerManager.swift
//  iNoteServerPackageDescription
//
//  Created by haoxian on 2017/10/22.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

enum RequestStatus: String {
    case success = "SUCCESS"
    case failure = "FAILURE"
}

class NetworkServerManager {
    
    static let share = NetworkServerManager()
    private init() {
        configure()
        server.addRoutes(routes)
    }
    
    let server = HTTPServer()
    var routes = Routes(baseUri: iNoteAIP.base.rawValue)
    
    func serverStart(_ port: UInt16 = 8181) {
        server.serverPort = port
        do {
            try server.start()
        } catch PerfectError.networkError(let code, let msg) {
            print("network error:\(code) \(msg)")
        } catch {
            print("unknow network error: \(error)")
        }
    }
    
    func configure() {
        addRouteWith(method: .post, uri: .register, handler: userRegisterHandle())
        addRouteWith(method: .post, uri: .login, handler: userLoginHandle())
        
        addRouteWith(method: .get, uri: .contentList, handler: getNoteContentListHandle())
        addRouteWith(method: .post, uri: .addNote, handler: addNoteHandel())
        addRouteWith(method: .delete, uri: .deleteNote, handler: deleteNoteHandle())
        addRouteWith(method: .post, uri: .modifyNote, handler: modifyNoteHandle())
    }
    
    func addRouteWith(method: HTTPMethod, uri: iNoteAIP, handler: @escaping RequestHandler) {
        routes.add(method: method, uri: uri.rawValue, handler: handler)
        
    }
    
    func requestHandle(request: HTTPRequest, response: HTTPResponse, status: RequestStatus, result: Bool, resultMessage: String, data:[[String:Any]]?) {
        let jsonDic: [String:Any] = ["status":status.rawValue, "result": result, "message":resultMessage, "data":data ?? []]
        do {
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
            guard let phoneNum =  request.param(name: "phoneNum"), let password = request.param(name: "password") else {
                self?.requestHandle(request: request, response: response, status: .failure, result: false, resultMessage: "缺少对应参数", data: nil)
                return
            }
            let (message, exists) = DatabaseManager.share.registerWith(phoneNum: phoneNum, password: password)
            let status: RequestStatus = exists ? .failure : .success
            self?.requestHandle(request: request, response: response, status: status, result: !exists, resultMessage: message, data: nil)
        }
    }
    
    func userLoginHandle() -> RequestHandler {
        return {[weak self] request, response in
            guard let phoneNum =  request.param(name: "phoneNum"), let password = request.param(name: "password") else {
                self?.requestHandle(request: request, response: response, status: .failure, result: false, resultMessage: "缺少对应参数", data: nil)
                return
            }
            let (result, msg, info) = DatabaseManager.share.loginWith(phoneNum: phoneNum, password: password)
            let status: RequestStatus = result ? .success : .failure
            self?.requestHandle(request: request, response: response, status: status, result: result, resultMessage: msg, data: [info])
        }
    }
    
}

// MARK:- 笔记CURD
extension NetworkServerManager {
    
    func getNoteContentListHandle() -> RequestHandler {
        return {[weak self] request, response in
            guard let userId = request.param(name: "userId") else {
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
                let content = request.param(name: "content") else {
                self?.requestHandle(request: request, response: response, status: .failure, result: false, resultMessage: "缺少对应参数", data: nil)
                return
            }
            let data = DatabaseManager.share.addNote(userId: userId, title: title, content: content)
            self?.requestHandle(request: request, response: response, status: .success, result: true, resultMessage: "添加成功", data: [data])
        }
    }
    
    func deleteNoteHandle() -> RequestHandler {
        return {[weak self] request, response in
            guard let id = request.param(name: "id") else {
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
                let content = request.param(name: "content") else {
                self?.requestHandle(request: request, response: response, status: .failure, result: false, resultMessage: "缺少对应参数", data: nil)
                return
            }
            let (result, msg, data) = DatabaseManager.share.modifyNote(id: id, title: title, content: content)
            let status: RequestStatus = result ? .success : .failure
            self?.requestHandle(request: request, response: response, status: status, result: result, resultMessage: msg, data: [data])
        }
    }
}






