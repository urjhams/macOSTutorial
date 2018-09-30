/*
 * Copyright (c) 2016 Razeware LLC
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
  
  @IBOutlet weak var statusLabel: NSTextField!
  @IBOutlet weak var tableView: NSTableView!
    
  
  let sizeFormatter = ByteCountFormatter()
  var directory: Directory?
  var directoryItems: [Metadata]?
  var sortOrder = Directory.FileOrder.Name
  var sortAscending = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.statusLabel.stringValue = ""
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.target = self
    self.tableView.doubleAction = #selector(self.tableViewDoubleClick(_:))
    self.prepareSorting()
  }
  
  override var representedObject: Any? {
    didSet {
      if let url = representedObject as? URL {
        directory = Directory(folderURL: url)
        self.reloadFileList()
      }
    }
  }
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return directoryItems?.count ?? 0
    }
  
  func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
    // Retrives(truy xuất) the first sort descriptor that corresponds to the column header clicked by the user
    guard let sortDescriptor = tableView.sortDescriptors.first else {
      return
    }
    
    // assign sortOrder, sortAscending based on the sort descriptor above and reload data
    if let order = Directory.FileOrder(rawValue: sortDescriptor.key!) {
      self.sortOrder = order
      self.sortAscending = sortDescriptor.ascending
      self.reloadFileList()
    }
  }
}

extension ViewController: NSTableViewDelegate {
    fileprivate enum CellIdentifier {
        static let NameCell = "NameCellID"
        static let DateCell = "DateCellID"
        static let SizeCell = "SizeCellID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
      var image: NSImage?
      var text = ""
      var cellIdentifier = ""
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .long
      dateFormatter.timeStyle = .long
      
      guard let item = directoryItems?[row] else {
        return nil
      }
      
      switch tableColumn {
      case tableView.tableColumns[0]:
        image = item.icon
        text = item.name
        cellIdentifier = CellIdentifier.NameCell
      case tableView.tableColumns[1]:
        text = dateFormatter.string(from: item.date)
        cellIdentifier = CellIdentifier.DateCell
      case tableView.tableColumns[2]:
        text = item.isFolder ? "--" : sizeFormatter.string(fromByteCount: item.size)
        cellIdentifier = CellIdentifier.SizeCell
      default:
        return nil
      }
      
      if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
        cell.textField?.stringValue = text
        cell.imageView?.image = image ?? nil
        return cell
      }
      return nil
    }
  
  func tableViewSelectionDidChange(_ notification: Notification) {
    self.updateStatus()
  }
}

extension ViewController {
  private func reloadFileList() {
    self.directoryItems = directory?.contentsOrderedBy(sortOrder, ascending: sortAscending)
    self.tableView.reloadData()
  }
  
  private func updateStatus() {
    let text: String
    
    let itemSelectedNumber = self.tableView.selectedRowIndexes.count
    
    if directoryItems == nil {
      text = "No Items"
    } else if itemSelectedNumber == 0 {
      text = "\(directoryItems!.count) items"
    } else {
      text = "\(itemSelectedNumber) of \(directoryItems!.count) selected"
    }
    
    self.statusLabel.stringValue = text
  }
  
  @objc private func tableViewDoubleClick(_ sender: AnyObject) {
    guard self.tableView.selectedRow > 0,
      let item = directoryItems?[tableView.selectedRow] else {
      return
    }
    if item.isFolder {
      self.representedObject = item.url as Any
    } else {
      NSWorkspace.shared.open(item.url)
    }
  }
  
  private func prepareSorting() {
    let nameDescriptor = NSSortDescriptor(key: Directory.FileOrder.Name.rawValue, ascending: true)
    let dateDescriptor = NSSortDescriptor(key: Directory.FileOrder.Date.rawValue, ascending: true)
    let sizeDescriptor = NSSortDescriptor(key: Directory.FileOrder.Size.rawValue, ascending: true)
    
    let nameColumn = self.tableView.tableColumns[0]
    nameColumn.sortDescriptorPrototype = nameDescriptor
    
    let dateColumn = self.tableView.tableColumns[1]
    dateColumn.sortDescriptorPrototype = dateDescriptor
    
    let sizeColumn = self.tableView.tableColumns[2]
    sizeColumn.sortDescriptorPrototype = sizeDescriptor
  }
}
