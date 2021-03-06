//
//  main.swift
//  XcodeProjectRenamer
//
//  Created by Marko Tadic on 8/1/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import Foundation

class XcodeProjectRenamer: NSObject {
    
    // MARK: - Constants
    
    struct Color {
        static let Black = "\u{001B}[0;30m"
        static let Red = "\u{001B}[0;31m"
        static let Green = "\u{001B}[0;32m"
        static let Yellow = "\u{001B}[0;33m"
        static let Blue = "\u{001B}[0;34m"
        static let Magenta = "\u{001B}[0;35m"
        static let Cyan = "\u{001B}[0;36m"
        static let White = "\u{001B}[0;37m"
        static let DarkGray = "\u{001B}[1;30m"
    }
    
    // MARK: - Properties
    
    let fileManager = FileManager.default
    var processedPaths = Set<String>()
    
    let oldName: String
    let newName: String
    
    // MARK: - Init
    
    init(oldName: String, newName: String) {
        self.oldName = oldName
        self.newName = newName
    }
    
    // MARK: - API
    
    func run() {
        print("\n\(Color.Green)------------------------------------------")
        print("\(Color.Green)Rename Xcode Project from [\(oldName)] to [\(newName)]")
        print("\(Color.Green)Current Path: \(fileManager.currentDirectoryPath)")
        print("\(Color.Green)------------------------------------------\n")
        
        let currentPath = fileManager.currentDirectoryPath
        if validatePath(currentPath) {
            enumeratePath(currentPath)
        } else {
            print("\(Color.Red)Xcode project or workspace with name: [\(oldName)] is not found at current path.")
        }
        
        print("\n\(Color.Green)------------------------------------------")
		print("\(Color.Green)Xcode Project Rename Finished! Processed \(self.processedPaths.count) files and directories.")
        print("\(Color.Green)------------------------------------------\n")
    }
    
    // MARK: - Helpers
    
    private func validatePath(_ path: String) -> Bool {
        let projectPath = path.appending("/\(oldName).xcodeproj")
        let workspacePath = path.appending("/\(oldName).xcworkspace")
        let isValid = fileManager.fileExists(atPath: projectPath) || fileManager.fileExists(atPath: workspacePath)
        return isValid
    }
    
    private func enumeratePath(_ path: String) {
		let enumerator = fileManager.enumerator(atPath: path)
        while let element = enumerator?.nextObject() as? String {
			if self.shouldSkip(element) { continue }
			
			let fullPath = path + "/\(element)"
			if !processedPaths.contains(fullPath) {
				processPath(fullPath)
			}
        }
		
		let resourceKeys = [URLResourceKey.isDirectoryKey]
		let directoryEnumerator = self.fileManager.enumerator(at: URL(fileURLWithPath: path), includingPropertiesForKeys: resourceKeys, options: .skipsHiddenFiles)!
		 
		for case let fileURL as URL in directoryEnumerator {
			guard let resourceValues = try? fileURL.resourceValues(forKeys: Set(resourceKeys)) else { continue }
				
			if resourceValues.isDirectory == true {
				self.renameItem(atPath: fileURL.path)
				processedPaths.insert(path)
			}
		}
    }
    
    private func processPath(_ path: String) {
        
        var isDir: ObjCBool = false
		print("Processing: \(path)")
		if fileManager.fileExists(atPath: path, isDirectory: &isDir) && !isDir.boolValue {
            updateContentsOfFile(atPath: path)
			renameItem(atPath: path)
			processedPaths.insert(path)
        }
    }
    
    private func shouldSkip(_ element: String) -> Bool {
        guard
            !element.hasPrefix("."),
            !element.contains(".DS_Store"),
            !element.contains("Carthage"),
            !element.contains("Pods"),
            !element.contains("fastlane")
        else { return true }
        
        let fileExtension = URL(fileURLWithPath: element).pathExtension
        switch fileExtension {
        case "appiconset", "json", "png", "xcuserstate", "framework":
            return true
        default:
            return false
        }
    }
    
    private func updateContentsOfFile(atPath path: String) {
        do {
            let oldContent = try String(contentsOfFile: path, encoding: .utf8)
            if oldContent.contains(oldName) {
                let newContent = oldContent.replacingOccurrences(of: oldName, with: newName)
                try newContent.write(toFile: path, atomically: true, encoding: .utf8)
                print("\(Color.Blue)-- Updated: \(path)")
            }
        } catch {
            print("\(Color.Red)Error while updating file: \(error.localizedDescription)")
        }
    }
    
    private func renameItem(atPath path: String) {
        do {
            let oldItemName = URL(fileURLWithPath: path).lastPathComponent
            if oldItemName.contains(oldName) {
                let newItemName = oldItemName.replacingOccurrences(of: oldName, with: newName)
                let directoryURL = URL(fileURLWithPath: path).deletingLastPathComponent()
                let newPath = directoryURL.appendingPathComponent(newItemName).path
                try fileManager.moveItem(atPath: path, toPath: newPath)
                print("\(Color.Magenta)-- Renamed: \(oldItemName) -> \(newItemName)")
            }
        } catch {
            print("\(Color.Red)Error while renaming file: \(error.localizedDescription)")
        }
    }
    
}

let arguments = CommandLine.arguments
if arguments.count == 3 {
    let oldName = arguments[1]
    let newName = arguments[2].replacingOccurrences(of: " ", with: "")
    let xpr = XcodeProjectRenamer(oldName: oldName, newName: newName)
    xpr.run()
} else {
    print("\(XcodeProjectRenamer.Color.Red)Invalid number of arguments! Expected OLD and NEW project name.")
}
