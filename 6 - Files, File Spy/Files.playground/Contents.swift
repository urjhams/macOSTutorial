import Cocoa

let completePath = "/Users/apple/Desktop/Files.playground"
let completeURL = URL(fileURLWithPath: completePath)

/// the url to home directory of current user in mac os
let home = FileManager.default.homeDirectoryForCurrentUser

/// make sure this file must be on the desktop
let thisPlaygroundPath = "Desktop/Files.playground"
let thisPlaygroundUrl = home.appendingPathComponent(thisPlaygroundPath)

// ------- URL class's properties:
thisPlaygroundUrl.path
thisPlaygroundUrl.absoluteString
thisPlaygroundUrl.absoluteURL
thisPlaygroundUrl.baseURL

thisPlaygroundUrl.pathComponents
thisPlaygroundUrl.lastPathComponent
thisPlaygroundUrl.pathExtension

thisPlaygroundUrl.isFileURL
thisPlaygroundUrl.hasDirectoryPath
// --------------------------------

// -------- some interactions:
var urlForEditting = home
urlForEditting.path

urlForEditting.appendingPathComponent("Desktop")
urlForEditting.path

urlForEditting.appendingPathComponent("Test file")
urlForEditting.path

urlForEditting.appendPathExtension("txt")
urlForEditting.path

urlForEditting.deletePathExtension()
urlForEditting.path

urlForEditting.deleteLastPathComponent()
urlForEditting.path

// ----- create new URL from existed one:
let fileUrl = home.appendingPathComponent("Desktop")
    .appendingPathComponent("Test File")
    .appendingPathExtension("txt")
fileUrl.path

let desktopUrl = fileUrl.deletingLastPathComponent()
desktopUrl.path

// ------ check does the file exist
let fileManager = FileManager.default
fileManager.fileExists(atPath: thisPlaygroundUrl.path)

let missingFile = URL(fileURLWithPath: "this_file_does_not_exist.missing")
fileManager.fileExists(atPath: missingFile.path)

// ------ check does the folder exist
var isDirectory: ObjCBool = false
fileManager.fileExists(atPath: thisPlaygroundUrl.path, isDirectory: &isDirectory)
isDirectory.boolValue
