//
//  SysFunc.swift
//  aOS
//
//  Created by Angelo Rodriguez on 25.05.18.
//  Copyright © 2018 Arya. All rights reserved.
//

import Foundation

func getHomeDirectory() -> String {
    var dir =  String(FileManager().homeDirectoryForCurrentUser.absoluteString)
    for _ in 0...6 {
        dir.removeFirst()
    }
    return dir
}

func getFullUserName() -> String {
    return NSFullUserName()
}

func getUserName() -> String {
    return NSUserName()
}

func getMountedVolumes() -> Array<String> {
    let fm = FileManager()
    var ret = Array<String>()
    for x in fm.mountedVolumeURLs(includingResourceValuesForKeys: nil)! {
        var itm =  String(x.absoluteString)
        for _ in 0...6 {
            itm.removeFirst()
        }
        ret.append(itm)
    }
    return ret
}

func changeCurrentWorkingDirectory(toPath: String) {
    FileManager().changeCurrentDirectoryPath(toPath)
}
func getCurrentWorkingDirectory() -> String {
    return FileManager().currentDirectoryPath
}


func shell(_ input: String) -> String {
    var arguments = input.split { $0 == " " }.map(String.init)
    let launchPath = arguments[0]
    arguments.removeFirst()
    
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    
    return output
}

func getArguments() -> [String] {
    return CommandLine.arguments
}
