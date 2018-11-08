import Foundation

let args = getArguments()
let dir = getCurrentWorkingDirectory()

if args.count < 2 {
    exit(1)
}

if File(ofPath: (getHomeDirectory() + "/.config/prmpref.json")).fileExists {} else {
    let prefJSON: [String: Any] = ["Compiler": "/usr/bin/swiftc"]
    let jsono = JSON(prefJSON)
    File(ofPath: "\(getHomeDirectory())/.config/prmpref.json").write(content: jsono.description)
}

let prefStr = File(ofPath: "\(getHomeDirectory())/.config/prmpref.json").read()
let pref = JSON(parseJSON: prefStr)

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
        let compiler = pref["Compiler"]
        var compilerFiles = ["\(dir)/Source/main.swift"]
        compilerFiles += scanFolder("\(dir)/Source")
        compilerFiles += scanFolder("\(dir)/Frameworks")
        var compilerFilesStr = ""
        for x in compilerFiles {
            compilerFilesStr += "\(x) "
        }

        let prjstr = File(ofPath: "\(dir)/project.json").read()
        let prj = JSON(parseJSON: prjstr)

        let name = prj["Name"]
        let flags = prj["flags"]

        var flagsstr = ""
        for x in flags {
            flagsstr += "-D \(x.1) "
        }

        let output = shell("\(compiler) -o \(dir)/Product/\(name) \(flagsstr)\(compilerFilesStr)")
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
        var projectJSON: [String: Any] = ["Name": name]
        projectJSON["flags"] = [String]()
        let jsono = JSON(projectJSON)
        File(ofPath: "\(prdir)/project.json").write(content: jsono.description)
        print("Created \(name)")
    case "build":
        buildApp()
    case "run":
        buildApp()
        let prjstr = File(ofPath: "\(dir)/project.json").read()
        let prj = JSON(parseJSON: prjstr)
        let name = prj["Name"]
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
        let jsono = JSON(prefJSON)
        File(ofPath: "\(getHomeDirectory())/.config/prmpref.json").write(content: jsono.description)

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
