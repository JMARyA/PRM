//
//  File.swift
//  aOS
//
//  Created by Angelo Rodriguez on 25.05.18.
//  Copyright © 2018 Arya. All rights reserved.
//

import Foundation

class File: CustomStringConvertible, Equatable {
    var path: String
    
    
    static func == (lhs: File, rhs: File) -> Bool {
        if (lhs.path == rhs.path) {
            return true
        }
        return false
    }
    
    var contentsOfDirectory: Array<String> {
        do {
            let x = try FileManager().contentsOfDirectory(atPath: self.path)
            return x
        } catch {}
        return Array<String>()
    }
    
    var fileExists: Bool {
        return FileManager().fileExists(atPath: self.path)
    }

    var isDirectory: Bool {
        var isDir : ObjCBool = false
        FileManager().fileExists(atPath: self.path, isDirectory:&isDir)
        return isDir.boolValue
    }
    var isReadable: Bool {
        return FileManager().isReadableFile(atPath: self.path)
    }
    var isWriteable: Bool {
        return FileManager().isWritableFile(atPath: self.path)
    }
    var isExecutable: Bool {
        return FileManager().isExecutableFile(atPath: self.path)
    }
    var isDeletable: Bool {
        return FileManager().isDeletableFile(atPath: self.path)
    }
    
    var pathElements: Array<String> {
        return FileManager().componentsToDisplay(forPath: self.path)!
    }
    var fileName: String {
        return FileManager().displayName(atPath: self.path)
    }
    
    
    var description: String {
        return "File at Path \"\(self.path)\""
    }
    
    func createDirectory() -> Bool {
        do {
            try FileManager().createDirectory(atPath: self.path, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            return false
        }
    }
    
    func createFile(withContents content: String = "") {
        FileManager().createFile(atPath: self.path, contents: nil, attributes: nil)
        do { try content.write(toFile: self.path, atomically: true, encoding: String.Encoding.utf8) } catch {}
    }
    
    func moveToTrash() -> Bool {
        do{
            try FileManager().trashItem(at: NSURL(string: "file://" + self.path)! as URL, resultingItemURL: nil)
            return true
        }catch{ return false}
    }
    
    func delete() -> Bool{
        do {
            try FileManager().removeItem(atPath: self.path)
            return true
        } catch {
            return false
        }
    }
    
    func copy(toPath: String) -> Bool {
        do {
            try FileManager().copyItem(atPath: self.path, toPath: toPath)
            return true
        } catch {
            return false
        }
    }
    
    func move(toPath: String) -> Bool {
        do {
            try FileManager().moveItem(atPath: self.path, toPath: toPath)
            return true
        } catch {
            return false
        }
    }
    
    func createSymbolicLink(atPath p: String) -> Bool {
        do {
            try FileManager().createSymbolicLink(atPath: p, withDestinationPath: self.path)
            return true
        } catch {
            return false
        }
    }
    
    func getDestinationOfSymbolicLink() -> String? {
        do {
            return try FileManager().destinationOfSymbolicLink(atPath: self.path)
        } catch {
            return nil
        }
    }
    
    func write(content: String) {
        do { try content.write(toFile: self.path, atomically: true, encoding: String.Encoding.utf8) } catch {}
    }
    
    func read(encoding: String.Encoding = String.Encoding.utf8) -> String {
        return String(data: FileManager().contents(atPath: self.path)!, encoding: encoding)!
    }
    
    
    init(ofPath: String) {
        self.path = ofPath
    }
}
