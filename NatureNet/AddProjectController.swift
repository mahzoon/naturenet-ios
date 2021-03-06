//
//  AddProjectController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 6/8/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class AddProjectController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet var addProjectTableView: UITableView!
    @IBOutlet weak var addProjectTextView: UITextView!
    
    var sitesIds = [String]()
    var switchValues = [Int: Bool]()
    var projectTitleText = ""
    var projectDescriptionText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !DataService.ds.LoggedIn() {
            UtilityFunctions.showAuthenticationRequiredMessage(theView: self, completion: {
                self.performSegue(withIdentifier: SEGUE_SIGNIN, sender: nil)
            })
        }
        
        sitesIds = DataService.ds.GetSiteIds()
        hideKeyboardWhenTappedOutside()
        addProjectTextView.attributedText = ADD_PROJECT_DESCRIPTION()
        
        for (index, _) in sitesIds.enumerated() {
            switchValues[index] = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addProjectTableView.FixHeaderLayout()
    }
    
    // returns the height of each project cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            //return CGFloat(ADD_PROJECT_TITLE_CELL_HEIGHT)
            return CGFloat(PROJECT_CELL_ITEM_HEIGHT)
        }
        if indexPath.section == 1 {
            return CGFloat(ADD_PROJECT_DESCRIPTION_CELL_HEIGHT)
        }
        return CGFloat(PROJECT_CELL_ITEM_HEIGHT)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1{
            return 1
        }
        if section == 2 {
            return sitesIds.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(ADD_PROJECT_HEADER_CELL_HEIGHT)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return PROJECT_TITLE_TEXT
        }
        if section == 1 {
            return PROJECT_DESCRIPTION_TEXT
        }
        if section == 2 {
            return PROJECT_SITE_TEXT
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return PROJECT_TITLE_INSTRUCTIONS
        }
        if section == 1 {
            return PROJECT_DESCRIPTION_INSTRUCTIONS
        }
        if section == 2 {
            return PROJECT_SITES_INSTRUCTIONS
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: TEXT_FIELD_CELL_ID) as? TextFieldCell {
                cell.configureCell {
                    if let n_cell = self.addProjectTableView.cellForRow(at: IndexPath(row: 0, section: 1)), (n_cell as? TextViewCell) != nil {
                        let next_cell = n_cell as! TextViewCell
                        next_cell.textBox.becomeFirstResponder()
                    }
                }
                return cell
            } else {
                return TextFieldCell()
            }
        }
        if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: TEXT_VIEW_CELL_ID) as? TextViewCell {
                cell.configureCell()
                cell.textBox.delegate = self
                return cell
            } else {
                return TextViewCell()
            }
        }
        if indexPath.section == 2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SITE_SWITCH_CELL_ID) as? SiteSwitchCell {
                if let val = switchValues[indexPath.row] {
                    cell.configureCell(siteName: DataService.ds.GetSiteName(with: sitesIds[indexPath.row]), value: val, index: indexPath.row)
                } else {
                    cell.configureCell(siteName: DataService.ds.GetSiteName(with: sitesIds[indexPath.row]), value: false, index: indexPath.row)
                }
                return cell
            } else {
                return SiteSwitchCell()
            }
        }
        return UITableViewCell()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        view.endEditing(true)
        if !DataService.ds.LoggedIn() {
            UtilityFunctions.showAuthenticationRequiredMessage(theView: self, completion: {
                self.performSegue(withIdentifier: SEGUE_SIGNIN, sender: nil)
            })
        } else {
            if projectTitleText == "" || projectDescriptionText == "" {
                UtilityFunctions.showErrorMessage(theView: self, title: PROJECT_EMPTY_ERROR_TITLE,
                                                  message: PROJECT_EMPTY_ERROR_MESSAGE,
                                                  buttonText: PROJECT_EMPTY_ERROR_BUTTON_TEXT)
                return
            }
            if isNoSiteSelected() {
                UtilityFunctions.showErrorMessage(theView: self, title: PROJECT_EMPTY_ERROR_TITLE,
                                                  message: PROJECT_EMPTY_SITE_ERROR_MESSAGE,
                                                  buttonText: PROJECT_EMPTY_ERROR_BUTTON_TEXT)
                return
            }
            
            if let userId = DataService.ds.GetCurrentUserId() {
                let project = NNProject(desc: projectDescriptionText, icon: ICON_PROJECT_DEFAULT_LINK, id: "", latestContrib: 0, name: projectTitleText, sites: getCheckedSites(), submitter: userId, source:DB_SOURCE, created: 0, updated: 0)
                DataService.ds.AddProject(project: project, completion: { success in
                    if (success) {
                        let alert = UIAlertController(title: ADD_PROJECT_SUCCESS_TITLE, message: ADD_PROJECT_SUCCESS_MESSAGE, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: ADD_PROJECT_SUCCESS_BUTTON_TEXT, style: .default, handler: { val in
                            self.dismiss(animated: true) {}
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    func isNoSiteSelected() -> Bool {
        if getCheckedSites().count == 0 {
            return true
        }
        return false
    }
    
    func getCheckedSites() -> [String: AnyObject] {
        var siteDict = [String: AnyObject]()
        for (index, siteId) in sitesIds.enumerated() {
            if let b = switchValues[index], b {
                siteDict[siteId] = true as AnyObject
            }
        }
        return siteDict
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switchValues[sender.tag] = sender.isOn
    }
    
    @IBAction func projectTitleChanged(_ sender: UITextField) {
        self.projectTitleText = sender.text ?? ""
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.projectDescriptionText = textView.text
    }
}
