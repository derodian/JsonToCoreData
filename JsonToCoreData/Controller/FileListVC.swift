//
//  ViewController.swift
//  JsonToCoreData
//
//  Created by Googoo on 6/6/19.
//  Copyright © 2019 Derodian. All rights reserved.
//

import UIKit
import CoreData

class FileListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var files: [File] = []
    let downloadService = DownloadService()
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        self.title = "Files List"
        view.backgroundColor = .white
        
//        clearData()
        updateTableContent()
        
        // Set downloadsSession proerty of DownloadService
        downloadService.downloadsSession = downloadsSession
    }
    
    func updateTableContent() {
        // Fetch Data from CoreData
        do {
            try self.fetchedResultController.performFetch()
            print("COUNT FETCHED FIRST: \(String(describing:self.fetchedResultController.sections?[0].numberOfObjects))")
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
        
        // Get Data from Web & Save it to CoreData
        NetworkingService.instance.getDataWith { (result) in
            switch result {
            case .Success(let data):
                self.clearData()
                self.saveInCoreDataWith(array: data)
            //                print(data)
            case .Error(let message):
                DispatchQueue.main.async {
                    self.showAlertWith(title: "Error", message: message)
                }
            }
        }
    }
    
    func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: "Cancel", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Move this to Services or Helper if needed
    // Helper method that accepts a dictionary and returns a NSManagedObject
    private func createFileEntityFrom(dictionary: [String: AnyObject], index: Int) -> NSManagedObject? {
        let context = CoreDataStack.instance.persistentContainer.viewContext
        if let fileEntity = NSEntityDescription.insertNewObject(forEntityName: "File", into: context) as? File {
            fileEntity.id = dictionary["id"] as! Int32
            fileEntity.name = dictionary["name"] as? String
            fileEntity.uploadDate = dictionary["uploadDate"] as? String
            let url = dictionary["fileUrl"] as? String
            fileEntity.fileUrl = URL(string: url!)
            fileEntity.index = Int32(index)
            
            return fileEntity
        }
        return nil
    }
    
    // method to save files info into CoreData
    private func saveInCoreDataWith(array: [[String: AnyObject]]) {
//        _ = array.map{self.createFileEntityFrom(dictionary: $0)}
        // can also use 'for loop' instead of map function
        var index = 0
        for dict in array {
            _ = self.createFileEntityFrom(dictionary: dict, index: index)
            index += 1
        }
        do {
            try CoreDataStack.instance.persistentContainer.viewContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // Fetch data from CoreData
    lazy var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: File.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.instance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    private func clearData() {
        do {
            let context = CoreDataStack.instance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "File")
            do {
                let objects = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataStack.instance.saveContext()
            } catch let error {
                print("ERROR DELETING: \(error)")
            }
        }
    }


}

extension FileListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! FileListCell
        
        cell.delegate = self
        if let file = fetchedResultController.object(at: indexPath) as? File {
            if let fileUrl = file.fileUrl {
                cell.configureCellWith(file: file, download: downloadService.activeDownloads[fileUrl])
            }
            
        }
        
        return cell
    }
    
    
}

extension FileListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // PerformSegue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass Data to destination View Controller
    }
    
}

extension FileListVC: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}

extension FileListVC: FileListDelegate {
    func pauseTapped(_ cell: FileListCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let file = fetchedResultController.object(at: indexPath) as! File
            downloadService.pauseDownload(file)
            reload(indexPath.row)
        }
    }
    
    func resumeTapped(_ cell: FileListCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let file = fetchedResultController.object(at: indexPath) as! File
            downloadService.resumeDownload(file)
            reload(indexPath.row)
        }
    }
    
    func cancelTapped(_ cell: FileListCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let file = fetchedResultController.object(at: indexPath) as! File
            downloadService.cancelDownload(file)
            reload(indexPath.row)
        }
    }
    
    func downloadTapped(_ cell: FileListCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let file = fetchedResultController.object(at: indexPath) as! File
            downloadService.startDownload(file)
            reload(indexPath.row)
        }
    }
    
    // Update filelist cell's buttons
    func reload(_ row: Int) {
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
}

extension FileListVC: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Finished downloading to \(location)")
        // Extract original request URL from task and remove corresponding Download from that dictionary
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        let download = downloadService.activeDownloads[sourceURL]
        downloadService.activeDownloads[sourceURL] = nil
        
        // Pass sourceURL to localFilepath helper method in FileListVC to genearte permanent filepath
        let destinationURL = localFilePath(for: sourceURL)
        print(destinationURL)
        
        // Move downloaded file from temp directory to desired destination directory and set downloaded property to true
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            download?.file.downloaded = true
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        // Reload selected cell using file's index property
        if let index = download?.file.index {
            // Set file's downloaded value to true to dismiss download button and make it selectable
//            let file = fetchedResultController.object(at: index) as! File
            let f = fetchedResultController.fetchedObjects![Int(index)] as! File
            f.downloaded = true
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: Int(index), section: 0)], with: .none)
                print("Cell updated...")
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // Get url of downloadTask and use it to find matching Download
        guard let url = downloadTask.originalRequest?.url, let download = downloadService.activeDownloads[url] else { return }
        
        // Calculate ration of total bytes written & expected to be written and save result to Download
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        // Format byte value to human-readable string
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        
        // Find cell responsible for displaying the file and call cell's helper method to update progress
        DispatchQueue.main.async {
            if let fileListCell = self.tableView.cellForRow(at: IndexPath(row: Int(download.file.index), section: 0)) as? FileListCell {
                fileListCell.updateDisplay(progress: download.progress, totalSize: totalSize)
            }
        }
    }
}

extension FileListVC: URLSessionDelegate {
    // Standard background session handler
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}

