import Foundation

let args = getArguments()
let dir = getCurrentWorkingDirectory()

if args.count < 2 {
    exit(1)
}

if File(ofPath: (getHomeDirectory() + "/.config/prmpref.json")).fileExists {} else {
    let prefJSON: [String: Any] = ["Compiler": "/usr/bin/swiftc"]
    let jsonData = try JSONSerialization.data(withJSONObject: prefJSON, options: JSONSerialization.WritingOptions())
    let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
    File(ofPath: "\(getHomeDirectory())/.config/prmpref.json").write(content: jsonString!)
}

let prefData = File(ofPath: "\(getHomeDirectory())/.config/prmpref.json").read().data(using: .utf8)
let pref = try? JSONSerialization.jsonObject(with: prefData!, options: []) as! Dictionary<String, Any>

func scanFolder(_ folder: String) -> [String] {
    var files = [String]()
    for file in File(ofPath: folder).contentsOfDirectory {
            if folder.hasSuffix("Source") {
                if file == "main.swift" {
                    continue
                }
            }
            if file.hasPrefix(".") {
                continue
            }
            if File(ofPath: "\(folder)/\(file)").isDirectory {
                    print("Found Directory \(folder)/\(file)")
                    files += scanFolder("\(folder)/\(file)")
            }
            if file.hasSuffix("swift") {
                print("Found File \(folder)/\(file)")
                files.append("\(folder)/\(file)")
            } else {
                continue
            }
        }
    return files
}

func buildApp() {
        let compiler = pref!["Compiler"]!
        var compilerFiles = ["\(dir)/Source/main.swift"]
        compilerFiles += scanFolder("\(dir)/Source")
        compilerFiles += scanFolder("\(dir)/Frameworks")
        var compilerFilesStr = ""
        for x in compilerFiles {
            compilerFilesStr += "\(x) "
        }

        let prjdata = File(ofPath: "\(dir)/project.json").read().data(using: .utf8)
        let prj = try? JSONSerialization.jsonObject(with: prjdata!, options: []) as! Dictionary<String, Any>

        let name = prj!["Name"]!

        let output = shell("\(compiler) -o \(dir)/Product/\(name) \(compilerFilesStr)")
        print(output)
}

switch args[1] {
    case "new":
        let name = args[2]
        File(ofPath: "\(dir)/\(name)").createDirectory()
        let prdir = "\(dir)/\(name)"
        File(ofPath: "\(prdir)/Frameworks").createDirectory()
        File(ofPath: "\(prdir)/Source").createDirectory()
        File(ofPath: "\(prdir)/Product").createDirectory()
        File(ofPath: "\(prdir)/Source/main.swift").write(content: "print(\"Hello World!\")\n")
        let projectJSON: [String: Any] = ["Name": name]
        let jsonData = try JSONSerialization.data(withJSONObject: projectJSON, options: JSONSerialization.WritingOptions())
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
        File(ofPath: "\(prdir)/project.json").write(content: jsonString!)
        print("Created \(name)")
    case "build":
        buildApp()
    case "run":
        buildApp()
        let prjdata = File(ofPath: "\(dir)/project.json").read().data(using: .utf8)
        let prj = try? JSONSerialization.jsonObject(with: prjdata!, options: []) as! Dictionary<String, Any>
        let name = prj!["Name"]!
        var aargs = args
        aargs.removeFirst()
        aargs.removeFirst()
        var aargsstr = ""
        for x in aargs {
            aargsstr += "\(x) "
        }
        print("Starting Application...")
        print(shell("\(dir)/Product/\(name) \(aargsstr)"))
        
    case "--compiler":
        let prefJSON: [String: Any] = ["Compiler": args[2]]
        let jsonData = try JSONSerialization.data(withJSONObject: prefJSON, options: JSONSerialization.WritingOptions())
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
        File(ofPath: "\(getHomeDirectory())/.config/prmpref.json").write(content: jsonString!)

    case "--help":
        let helptext = """
        PRM v1.0
        new [NAME]      -       Creates a new Application
        build           -       Builds an Application
        run             -       Builds and runs an Application
        --compiler      -       Change the Path of the used Swift Compiler
        --help          -       Shows this text
        """
        print(helptext)
    default:
        break
}
