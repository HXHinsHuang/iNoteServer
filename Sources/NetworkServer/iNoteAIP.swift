//
//  iNoteAIP.swift
//  iNoteServerPackageDescription
//
//  Created by haoxian on 2017/10/22.
//

import Foundation

enum iNoteAIP: String {
    
    case base = "/iNote"
    
    //注册页面
    case register = "/register"
    
    //登录页面
    case login = "/login"
    
    //获取笔记列表
    case contentList = "/contentList"
    
    //添加笔记
    case addNote = "/addNote"
    
    //删除笔记
    case deleteNote = "/deleteNote"
    
    //修改笔记
    case modifyNote = "/modifyNote"
    
}
