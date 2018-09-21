/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Cocoa

class ViewController: NSViewController {

  // MARK: - Outlets

  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var infoTextView: NSTextView!
  @IBOutlet weak var saveInfoButton: NSButton!
  @IBOutlet weak var moveUpButton: NSButton!

  // MARK: - Properties

  var filesList: [URL] = []
  var showInvisibles = false

  var selectedFolderUrl: URL? {
    didSet {
      if let selectedFolderUrl = selectedFolderUrl {
        filesList = contentsOf(folder: selectedFolderUrl)
        selectedItem = nil
        self.tableView.reloadData()
        self.tableView.scrollRowToVisible(0)
        moveUpButton.isEnabled = true
        view.window?.title = selectedFolderUrl.path
      } else {
        moveUpButton.isEnabled = false
        view.window?.title = "FileSpy"
      }
    }
  }

  var selectedItem: URL? {
    didSet {
      infoTextView.string = ""
      saveInfoButton.isEnabled = false

      guard let selectedUrl = selectedItem else {
        return
      }

      let infoString = infoAbout(url: selectedUrl)
      if !infoString.isEmpty {
        let formattedText = formatInfoText(infoString)
        infoTextView.textStorage?.setAttributedString(formattedText)
        saveInfoButton.isEnabled = true
      }
    }
  }

  // MARK: - View Lifecycle & error dialog utility

  override func viewWillAppear() {
    super.viewWillAppear()

    restoreCurrentSelections()
  }

  override func viewWillDisappear() {
    saveCurrentSelections()

    super.viewWillDisappear()
  }

  func showErrorDialogIn(window: NSWindow, title: String, message: String) {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = message
    alert.alertStyle = .critical
    alert.beginSheetModal(for: window, completionHandler: nil)
  }

}

// MARK: - Getting file or folder information

extension ViewController {

  func contentsOf(folder: URL) -> [URL] {
    let fileManager = FileManager.default
    
    // use do catch cause contentsOfDirectory can throw error
    do {
        let contents = try fileManager.contentsOfDirectory(atPath: folder.path)
        
        // map the content of directory(file path or folder) to array of url path
        // the filter find out the hidden item by the name start with a period (in Unix system)
        let urls = contents
            .filter{ return showInvisibles ? true : $0.prefix(1) != "." }
            .map { return folder.appendingPathComponent($0) }
        
        return urls
    } catch {
        return []
    }
  }

  func infoAbout(url: URL) -> String {
    let fileMng = FileManager.default
    do {
        let attributes = try fileMng.attributesOfItem(atPath: url.path)
        var report: [String] = ["\(url.path)", ""]
        
        for (key, value) in attributes {
            
            // ignore NSFileExtendedAttributes, too complicate
            if key.rawValue == "NSFileExtendedAttributes" {
                continue
            }
            
            report.append("\(key.rawValue):\t\(value)")
        }
        return report.joined(separator: "\n")
        
    } catch  {
        return "No information available for \(url.path)"
    }
    
  }

  func formatInfoText(_ text: String) -> NSAttributedString {
    let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
    paragraphStyle?.minimumLineHeight = 24
    paragraphStyle?.alignment = .left
    paragraphStyle?.tabStops = [ NSTextTab(type: .leftTabStopType, location: 240) ]

    let textAttributes: [String: Any] = [
      convertFromNSAttributedStringKey(NSAttributedString.Key.font): NSFont.systemFont(ofSize: 14),
      convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): paragraphStyle ?? NSParagraphStyle.default
    ]

    let formattedText = NSAttributedString(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary(textAttributes))
    return formattedText
  }
    
}

// MARK: - Actions

extension ViewController {

  @IBAction func selectFolderClicked(_ sender: Any) {
    // check does it has a window for NSOpenPanel to be display
    guard let window = view.window else { return }
    
    // create a NSOpenPanel
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    openPanel.allowsMultipleSelection = false
    
    openPanel.beginSheetModal(for: window) { [weak self] (response) in
        if response.rawValue == NSFileHandlingPanelOKButton {
            // because it could be mutiple selection so it must be an array of urls
            self?.selectedFolderUrl = openPanel.urls[0]
        }
    }
  }

  @IBAction func toggleShowInvisibles(_ sender: NSButton) {
    self.showInvisibles = sender.state == .on
    
    if let selectedFolder = self.selectedFolderUrl {
        self.filesList = contentsOf(folder: selectedFolder)
        self.selectedItem = nil
        self.tableView.reloadData()
    }
  }

  @IBAction func tableViewDoubleClicked(_ sender: Any) {
    if self.tableView.selectedRow < 0 { return }
    let selectedItemUrl = self.filesList[self.tableView.selectedRow]
    if selectedItemUrl.hasDirectoryPath {
        self.selectedFolderUrl = selectedItemUrl
    }
  }

  @IBAction func moveUpClicked(_ sender: Any) {
    if selectedFolderUrl?.path == "/" {
        let message = [NSLocalizedDescriptionKey : "Oops, you have been in the root"]
        let error = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: message)
        
        //NSAlert(error: error).runModal()
        let alert = NSAlert(error: error)
        alert.runModal()
        
        return
    }
    selectedFolderUrl?.deleteLastPathComponent()
  }

  @IBAction func saveInfoClicked(_ sender: Any) {
    guard let window = self.view.window else { return }
    guard let selectedItemUrl = self.selectedFolderUrl else { return }
    
    let savePanel = NSSavePanel()
    savePanel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
    savePanel.nameFieldStringValue = selectedItemUrl
        .deletingPathExtension()
        .appendingPathExtension("fs.txt")
        .lastPathComponent
    
    savePanel.beginSheetModal(for: window) { [weak self] (response: NSApplication.ModalResponse) in
        if response == NSApplication.ModalResponse.OK, let url = savePanel.url {
            do {
                let infoAsText = self?.infoAbout(url: selectedItemUrl)
                try infoAsText?.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                self?.showErrorDialogIn(window: window,
                                       title: "Unable to save file",
                                       message: error.localizedDescription)
            }
        }
    }
  }

}

// MARK: - NSTableViewDataSource

extension ViewController: NSTableViewDataSource {

  func numberOfRows(in tableView: NSTableView) -> Int {
    return filesList.count
  }

}

// MARK: - NSTableViewDelegate

extension ViewController: NSTableViewDelegate {

  func tableView(_ tableView: NSTableView, viewFor
    tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let item = filesList[row]
    
    let fileIcon = NSWorkspace.shared.icon(forFile: item.path)
    
    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileCell"), owner: nil) as? NSTableCellView {
        cell.textField?.stringValue = item.lastPathComponent
        cell.imageView?.image = fileIcon
        return cell
    }
    return nil
  }

  func tableViewSelectionDidChange(_ notification: Notification) {
    if tableView.selectedRow < 0 {
      selectedItem = nil
      return
    }

    selectedItem = filesList[tableView.selectedRow]
  }

}

// MARK: - Save & Restore previous selection

extension ViewController {

  func saveCurrentSelections() {
    guard let dataFileUrl = urlForDataStorage() else { return }

    let parentForStorage = selectedFolderUrl?.path ?? ""
    let fileForStorage = selectedItem?.path ?? ""
    let completeData = "\(parentForStorage)\n\(fileForStorage)\n"

    try? completeData.write(to: dataFileUrl, atomically: true, encoding: .utf8)
  }

  func restoreCurrentSelections() {
    guard let dataFileUrl = urlForDataStorage() else { return }

    do {
      let storedData = try String(contentsOf: dataFileUrl)
      let storedDataComponents = storedData.components(separatedBy: .newlines)
      if storedDataComponents.count >= 2 {
        if !storedDataComponents[0].isEmpty {
          selectedFolderUrl = URL(fileURLWithPath: storedDataComponents[0])
          if !storedDataComponents[1].isEmpty {
            selectedItem = URL(fileURLWithPath: storedDataComponents[1])
            selectUrlInTable(selectedItem)
          }
        }
      }
    } catch {
      print(error)
    }
  }

  private func selectUrlInTable(_ url: URL?) {
    guard let url = url else {
      tableView.deselectAll(nil)
      return
    }

    if let rowNumber = filesList.index(of: url) {
      let indexSet = IndexSet(integer: rowNumber)
      DispatchQueue.main.async {
        self.tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
      }
    }
  }
  
  private func urlForDataStorage() -> URL? {
    let fileMng = FileManager.default
    
    guard let folder = fileMng.urls(for: .applicationSupportDirectory,
                                    in: .userDomainMask).first else { return nil }
    let appFolderUrl = folder.appendingPathComponent("FileSpy")
    var isDirectory: ObjCBool = false
    let folderExist = fileMng.fileExists(atPath: appFolderUrl.path,
                                         isDirectory: &isDirectory)
    if !folderExist || !isDirectory.boolValue {
        do {
            try fileMng.createDirectory(at: appFolderUrl,
                                        withIntermediateDirectories: true,
                                        attributes: nil)
        } catch {
            return nil
        }
    }
    let dataFileUrl = appFolderUrl.appendingPathComponent("StoredState.txt")
    return dataFileUrl
  }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
