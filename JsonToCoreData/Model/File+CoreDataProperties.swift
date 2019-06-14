//
//  File+CoreDataProperties.swift
//  JsonToCoreData
//
//  Created by Googoo on 6/10/19.
//  Copyright © 2019 Derodian. All rights reserved.
//
//

import Foundation
import CoreData


extension File {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<File> {
        return NSFetchRequest<File>(entityName: "File")
    }

    @NSManaged public var downloaded: Bool
    @NSManaged public var fileUrl: URL?
    @NSManaged public var id: Int32
    @NSManaged public var index: Int32
    @NSManaged public var name: String?
    @NSManaged public var uploadDate: String?

}
