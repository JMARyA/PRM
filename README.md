# PRM
## Project Manager for Swift

With this you can create Application Folders for each of your Swift Project.
It keeps track of all your swift files and if you build it compiles everything in one executable.

To compile this project:
Without PRM `swiftc -o Product/prm Source/main.swift Frameworks/Utils/File.swift Frameworks/Utils/Sys.swift`
With PRM `prm build`

Info:
`prm new NAME` creates new Application Folder
`prm build` compiles it
`prm run` compiles and runs it
`prm --compiler PATH` you can change the used swift compiler
`prm --help` tells you the same as what you read
