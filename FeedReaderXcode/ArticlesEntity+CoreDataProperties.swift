//
//  ArticlesEntity+CoreDataProperties.swift
//  FeedReader
//
//  Created by Sergey on 21/02/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//
//

import Foundation
import CoreData


extension ArticlesEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArticlesEntity> {
        return NSFetchRequest<ArticlesEntity>(entityName: "ArticlesEntity")
    }

    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var image: Data?
    @NSManaged public var url: URL?
    @NSManaged public var date: Date?

}
