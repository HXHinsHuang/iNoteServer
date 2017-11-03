//
//  DatabaseManager.swift
//  iNoteServerPackageDescription
//
//  Created by haoxian on 2017/10/22.
//

import MySQLStORM
import StORM

class DatabaseManager {
    static let share = DatabaseManager()
    private init() {
        MySQLConnector.host = "127.0.0.1"
        MySQLConnector.username = "root"
        MySQLConnector.password = "Hhx505608099" //此处填你自己的mysql密码
        MySQLConnector.database = "iNote"
        MySQLConnector.port = 3306
    }
}

// MARK:- User
extension DatabaseManager {

    func registerWith(phoneNum: String, password: String) -> (String, Bool) {
        return User.register(phone: phoneNum, pwd: password)
    }
    
    func loginWith(phoneNum: String, password: String) -> (Bool, String, [String:String]) {
        return User.userLoginWith(phone: phoneNum, pwd: password)
    }
    
}

// MARK:- NoteContent
extension DatabaseManager {
    func getNoteContentList(_ userId: String) -> [[String:String]] {
        let notes = NoteContent.fetchNoteContent(userId)
        var notesDic: [[String:String]] = []
        notes.forEach { (note) in
            let dict = self.noteMapDict(note)
            notesDic.append(dict)
        }
        return notesDic
    }
    
    func addNote(userId: String, title: String, content: String) -> [String: String] {
        let note = NoteContent.addNoteContent(userId: userId, title: title, content: content)
        return noteMapDict(note)
    }
    
    func delteNote(_ id: String) -> [String:String] {
        let note = NoteContent.deleteNoteContent(id)
        return noteMapDict(note)
    }
    
    func modifyNote(id: String, title: String, content: String) -> (Bool, String, [String: String]) {
        let (result, msg, note) = NoteContent.modifyNoteContent(id: id, title: title, content: content)
        let dict = noteMapDict(note)
        return (result, msg, dict)
    }
    
    func noteMapDict(_ note: NoteContent) -> [String:String] {
        let dict = [
            "id" : "\(note.id)",
            "title" : note.title,
            "content" : note.content,
            "createTime" : note.createTime
        ]
        return dict
    }
    
}
