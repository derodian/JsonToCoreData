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
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        self.title = "Files List"
        view.backgroundColor = .white
        
//        clearData()
        updateTableContent()
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
    private func createFileEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        let context = CoreDataStack.instance.persistentContainer.viewContext
        if let fileEntity = NSEntityDescription.insertNewObject(forEntityName: "File", into: context) as? File {
            fileEntity.id = dictionary["id"] as! Int32
            fileEntity.name = dictionary["name"] as? String
            fileEntity.uploadDate = dictionary["uploadDate"] as? String
            fileEntity.fileUrl = dictionary["fileUrl"] as? String
            fileEntity.index = fileEntity.id - 1
            
            return fileEntity
        }
        return nil
    }
    
    // method to save files info into CoreData
    private func saveInCoreDataWith(array: [[String: AnyObject]]) {
        _ = array.map{self.createFileEntityFrom(dictionary: $0)}
        // can also use 'for loop' instead of map function
//        for dict in array {
//            _ = self.createFileEntityFrom(dictionary: dict)
//        }
        do {
            try CoreDataStack.instance.persistentContainer.viewContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // Fetch data from CoreData
    lazy var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: File.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "uploadDate", ascending: true)]
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
        
//        cell.delegate = self
        if let file = fetchedResultController.object(at: indexPath) as? File {
            cell.configureCellWith(file: file)
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
            DownloadService.instance.pauseDownload(file)
            reload(indexPath.row)
        }
    }
    
    func resumeTapped(_ cell: FileListCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let file = fetchedResultController.object(at: indexPath) as! File
            DownloadService.instance.resumeDownload(file)
            reload(indexPath.row)
        }
    }
    
    func cancelTapped(_ cell: FileListCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let file = fetchedResultController.object(at: indexPath) as! File
            DownloadService.instance.cancelDownload(file)
            reload(indexPath.row)
        }
    }
    
    func downloadTapped(_ cell: FileListCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let file = fetchedResultController.object(at: indexPath) as! File
            DownloadService.instance.startDownload(file)
            reload(indexPath.row)
        }
    }
    
    // Update filelist cell's buttons
    func reload(_ row: Int) {
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
}

