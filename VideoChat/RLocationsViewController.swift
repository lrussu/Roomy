//
//  RLocationsViewController.swift
//  VideoChat
//
//  Created by Farshx on 08/03/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit

protocol RLocationsViewControllerDelegate {
    func selectedGenres(_ genres: [[String: String]])
    func selectedCountrys(_ countrys: [[String: String]])
}

class RLocationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var delegate: RLocationsViewControllerDelegate? = nil
    
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var locationsTableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    
    var unhideMenu = true
    var genderOrLocations = (false, true)
    var multiSelect = true
    var myCountrySelected = ""
    var countrys = [[String: String]]()
    var selectedIndexes = [IndexPath]()
    var selectedGenresBlock: ((_ genres: [[String: String]])->Void)? = nil
    var selectedCountrysBlock: ((_ countrys: [[String: String]])->Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndexes.removeAll(keepingCapacity: false)
        if genderOrLocations.0{
            locationsTableView.isScrollEnabled = false
            countrys.append([
                "image" : "",
                "name" : "Male"
                ])
            countrys.append([
                "image" : "",
                "name" : "Female"
                ])
            titleLabel.text = "Gender Preferences"
            
            if genresFilters.contains("Male"){
                selectedIndexes.append(IndexPath(row: 0, section: 0))
            }
            if genresFilters.contains("Female"){
                selectedIndexes.append(IndexPath(row: 1, section: 0))
            }
        }else{
            titleLabel.text = genderOrLocations.1 ? "Regional Preferences" : "Select your country"
            if let path = MB.path(forResource: "Flags", ofType: nil){
                if let contents = try? FM.contentsOfDirectory(atPath: path){
                    countrys.removeAll(keepingCapacity: false)
                    for (index, content) in contents.enumerated(){
                        var country = content.replacingOccurrences(of: "@2x.png", with: "")
                        country = country.replacingOccurrences(of: "_", with: " ")
                        let components = country.components(separatedBy: " ")
                        country = ""
                        for comp in components{
                            if comp.characters.count > 3 || comp == "the" || comp == "and"{
                                country += comp.capitalized + " "
                            }else{
                                country += comp.uppercased() + " "
                            }
                        }
                        country = country.substring(to: country.characters.index(country.startIndex, offsetBy: country.characters.count - 1))
                        countrys.append([
                            "image" : content,
                            "name" : country
                            ])
                        if locationsFiltres.contains(country){
                            selectedIndexes.append(IndexPath(row: index, section: 0))
                        }
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! LocationsCell
        cell.locationsNameLabel.text = countrys[indexPath.row]["name"]!
        if selectedIndexes.contains(indexPath){
            cell.selectionImageView.isHidden = false
            cell.selectionsIndicator.isHidden = false
        }else{
            cell.selectionImageView.isHidden = true
            cell.selectionsIndicator.isHidden = true
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !multiSelect && genderOrLocations.0 == false{
            if myCountrySelected != "" {
                if let cell = tableView.cellForRow(at: selectedIndexes[0]) as? LocationsCell{
                    cell.selectionImageView.isHidden = true
                    cell.selectionsIndicator.isHidden = true
                }
                selectedIndexes.removeAll(keepingCapacity: false)
                myCountrySelected = ""
            }
            let cell = tableView.cellForRow(at: indexPath) as! LocationsCell
            cell.selectionImageView.isHidden = false
            cell.selectionsIndicator.isHidden = false
            myCountrySelected = countrys[indexPath.row]["name"]!
            selectedIndexes.append(indexPath)
        }else{
            let cell = tableView.cellForRow(at: indexPath) as! LocationsCell
            if let index = selectedIndexes.index(of: indexPath){
                selectedIndexes.remove(at: index)
                cell.selectionImageView.isHidden = true
                cell.selectionsIndicator.isHidden = true
            }else{
                selectedIndexes.append(indexPath)
                cell.selectionImageView.isHidden = false
                cell.selectionsIndicator.isHidden = false
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countrys.count
    }
    
    @IBAction func doneButtonAction(_ sender: AnyObject) {
        if !multiSelect && myCountrySelected == ""{
            let alert = UIAlertController(title: "Country", message: "Select please your country.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Select", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        var selected = [[String: String]]()
        for indexPath in selectedIndexes{
            selected.append(countrys[indexPath.row])
        }
        
        if genderOrLocations.0{
            delegate?.selectedGenres(selected)
            selectedGenresBlock?(selected)
        }else{
            delegate?.selectedCountrys(selected)
            selectedCountrysBlock?(selected)
        }
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            
            self.view.frame.origin = CGPoint(x: 0, y: kScreen.height)
            
            }, completion: { (finished) -> Void in
                if self.unhideMenu{
                    let ss = SlideNavigationController.sharedInstance()
                    let bottomMenu = ss?.bottomMenu as! RBottomMenuViewController
                    bottomMenu.unHideMenu()
                }
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        }) 
    }

}
