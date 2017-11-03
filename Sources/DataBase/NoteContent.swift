//
//  NoteContent.swift
//  iNoteServerPackageDescription
//
//  Created by haoxian on 2017/10/29.
//

import Foundation
import MySQLStORM
import StORM

class NoteContent: MySQLStORM {
    var id: Int = 0
    var title: String = ""
    var content: String = ""
    var userId: Int = 0
    var createTime: String = ""
    
    fileprivate override init() {
        super.init()
        do {
            try setupTable()
        } catch {
            print(error)
        }
    }
    
    override func table() -> String {
        return "NoteContent"
    }
    
    override func to(_ this: StORMRow) {
        id = numericCast(this.data["id"] as! Int32)
        title = this.data["title"] as! String
        content = this.data["content"] as! String
        userId = numericCast(this.data["userId"] as! Int32)
        createTime = this.data["createTime"] as! String
    }
    
    fileprivate func rows() -> [NoteContent] {
        var rows: [NoteContent] = []
        for r in results.rows {
            let note = NoteContent()
            note.to(r)
            rows.append(note)
        }
        return rows
    }
}

// MARK:- CRUD
extension NoteContent {
    
    // MARK:- 获取
    static func fetchNoteContent(_ userId: String) -> [NoteContent] {
        let note = NoteContent()
        do {
            try note.find(["userId":userId])
        } catch {
            print(error)
        }
        return note.rows()
    }
    
    // MARK:- 添加
    static func addNoteContent(userId: String, title: String, content: String) -> NoteContent {
        let note = NoteContent()
        note.userId = Int(userId) ?? 0
        note.title = title
        note.content = content
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        note.createTime = formatter.string(from: date)
        do {
            try note.save(set: { (id) in
                note.id = id as! Int
            })
        } catch {
            print(error)
        }
        return note
    }
    
    // MARK:- 删除
    static func deleteNoteContent(_ id: String) -> NoteContent {
        let note = NoteContent()
        do {
            try note.find(["id": id])
            note.to(note.results.rows[0])
            try note.delete(id)
        } catch {
            print(error)
        }
        return note
    }
    
    // MARK:- 修改
    static func modifyNoteContent(id: String, title: String, content: String) -> (Bool, String, NoteContent) {
        let note = NoteContent()
        do {
            let result = try note.update(cols: ["title", "content"], params: [title, content], idName: "id", idValue: id)
            let msg = result ? "修改成功" : "修改失败"
            try note.find(["id": id])
            return (result, msg, note)
        } catch {
            print(error)
        }

        return (false, "修改失败", note)
    }
}
