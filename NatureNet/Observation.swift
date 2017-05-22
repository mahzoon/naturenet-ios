//
//  Observation.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/16/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import Foundation
import MapKit

class NNObservation: NSObject, MKAnnotation {
    
    // the activity which this observation belongs to
    var project: String!
    // the site which this observation belongs to
    var site: String!
    // observer is the user id who made this observation
    var observer: String!
    // id of the observation
    var id: String!
    // data can have multiple interpretations that each has its own key-value in the dictionary. Current possibilities are "text", and "image"
    var data: [String: String]!
    // coordinates of the observation. The dictionary keys are 0 (latitude) and 1 (longitude)
    var location: [Double]!
    // timestamp of the creation time
    var createdAt: NSNumber!
    // timestamp of the updated time
    var updatedAt: NSNumber!
    // status
    var status: String!
    
    // returns the text of the observation
    var observationText: String {
        return data["text"] ?? ""
    }
    // return the text if any as the title
    var title: String? {
        return data["text"]
    }
    // returns the image url
    var observationImageUrl: String {
        return data["image"] ?? ""
    }
    // returns coordinates object
    var locationCoordinate: CLLocationCoordinate2D {
        if location.count != 2 {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        } else {
            return CLLocationCoordinate2D(latitude: location[0], longitude: location[1])
        }
    }
    var coordinate: CLLocationCoordinate2D {
        return locationCoordinate
    }
    // return pin color
    var pinColor: UIColor {
        return PIN_COLORS[site] ?? DEFAULT_PIN_COLOR
    }
    
    // the initializer.
    init(project: String, site: String, observer: String, id: String, data: [String: String], location: [Double], created: NSNumber, updated: NSNumber, status: String) {
        self.project = project
        self.site = site
        self.id = id
        self.observer = observer
        self.data = data
        self.location = location
        self.createdAt = created
        self.updatedAt = updated
        self.status = status
    }
    
    static func createObservationFromFirebase(with snapshot: [String: AnyObject]) -> NNObservation {
        // setting default values
        var obsProject = ""
        var obsId = ""
        var obsSite = ""
        var obsObserver = ""
        var obsData = [String: String]()
        var obsLocation = [Double]()
        var obsCreated: NSNumber = 0
        var obsUpdated: NSNumber = 0
        var obsStatus = ""
        // setting values when possible
        if let tmp = snapshot["activity"], (tmp as? String) != nil {
            obsProject = tmp as! String
        }
        if let tmp = snapshot["id"], (tmp as? String) != nil {
            obsId = tmp as! String
        }
        if let tmp = snapshot["site"], (tmp as? String) != nil {
            obsSite = tmp as! String
        }
        if let tmp = snapshot["observer"], (tmp as? String) != nil {
            obsObserver = tmp as! String
        }
        if let tmp = snapshot["data"], (tmp as? [String: String]) != nil {
            obsData = tmp as! [String: String]
        }
        if let tmp = snapshot["l"], (tmp as? [Double]) != nil {
            obsLocation = tmp as! [Double]
        }
        if let tmp = snapshot["created_at"], (tmp as? NSNumber) != nil {
            obsCreated = tmp as! NSNumber
        }
        if let tmp = snapshot["updated_at"], (tmp as? NSNumber) != nil {
            obsUpdated = tmp as! NSNumber
        }
        if let tmp = snapshot["status"], (tmp as? String) != nil {
            obsStatus = tmp as! String
        }
        let observation = NNObservation(project: obsProject, site: obsSite, observer: obsObserver, id: obsId, data: obsData, location: obsLocation, created: obsCreated, updated: obsUpdated, status: obsStatus)
        return observation
    }

}
