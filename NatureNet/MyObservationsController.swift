//
//  MyObservationsController.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 6/21/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class MyObservationsController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var observationsTable: UITableView!
    
    var user: NNUser?
    
    var pages = 0
    var maxNV = 0
    var maxNB = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observationsTable.delegate = self
        observationsTable.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let n = DETAILED_OBSV_LIST_INIT_COUNT + pages * DETAILED_OBSV_LIST_LOAD_MORE_COUNT
        var total = 0
        if let user = self.user {
            total = DataService.ds.GetObservationsForUser(with: user.id).count
        }
        var ret_val = 0
        if n < total {
            maxNV = n
            maxNB = true
            ret_val = n + 1
        } else {
            maxNV = total
            maxNB = false
            ret_val = total
        }
        return ret_val
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if maxNB && maxNV == indexPath.row {
            return CGFloat(SHOW_MORE_CELL_HEIGHT)
        }
        return CGFloat(RECENT_OBSV_ESTIMATED_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // the case which we should dequeue a ShowMoreCell
        if maxNB && maxNV == indexPath.row {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SHOW_MORE_CELL_ID) as? ShowMoreCell {
                cell.configureCell()
                return cell
            } else {
                return ShowMoreCell()
            }
        }
        
        // the case which we should dequeue a regular cell (GalleryCell)
        if let cell = tableView.dequeueReusableCell(withIdentifier: GALLERY_CELL_ID) as? GalleryCell {
            if let user = self.user {
                let listObsv = DataService.ds.GetObservationsForUser(with: user.id)
                if indexPath.row < listObsv.count {
                    let observation = listObsv[indexPath.row]
                    let numComment = DataService.ds.GetCommentsOnObservation(with: observation.id).count
                    let numLikes = observation.Likes.count
                    let numDislikes = observation.Dislikes.count
                    let projectName = DataService.ds.GetProject(by: observation.project)?.name ?? ""
                    cell.configureCell(id: GALLERY_CELL_ID + "\(indexPath.section).\(indexPath.row)",
                        username: user.displayName, affiliation: DataService.ds.GetSiteName(with: user.affiliation), project: projectName, avatar: user.avatarUrl, obsImage: observation.observationImageUrl, text: observation.observationText, num_likes: "\(numLikes)", num_dislikes: "\(numDislikes)", num_comments: "\(numComment)", date: observation.updatedAt, observation: observation, controller: self)
                }
            }
            return cell
        } else {
            return GalleryCell()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if id == SEGUE_DETAILS {
                if let cell = sender as? GalleryCell {
                    if let dest = segue.destination as? GalleryDetailController {
                        dest.observationObj = cell.observation
                        dest.commentTextShouldBeSelected = cell.tappedCommentButton
                        cell.tappedCommentButton = false
                    }
                }
            }
        }
    }
    
    @IBAction func showMoreTapped(_ sender: Any) {
        pages = pages + 1
        observationsTable.reloadData()
    }
}