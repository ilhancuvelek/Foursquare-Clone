//
//  ListViewController.swift
//  FoursquareClone
//
//  Created by İlhan Cüvelek on 3.02.2024.
//

import UIKit
import Firebase

class ListViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var placeNameArray:[String] = []
    var placeIdArray:[String] = []
    
    var choosenPlaceId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate=self
        tableView.dataSource=self
        
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))

        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logOutClicked))
        
        getPlaces()

    }
    func getPlaces(){
        
        let firestore=Firestore.firestore()
        
        if let currentUser = Auth.auth().currentUser{
            let userId = currentUser.uid
            print(userId)
            firestore.collection("Places").whereField("userId", isEqualTo: userId).addSnapshotListener { [self] snapShot, error in
                if error != nil{
                    print(error?.localizedDescription)
                }else{
                    if snapShot?.isEmpty != true && snapShot != nil{
                        
                        placeIdArray.removeAll(keepingCapacity: false)
                        placeIdArray.removeAll(keepingCapacity: false)
                        
                        for document in snapShot!.documents {
                            if let placeName=document.get("placeName") as? String{
                                placeNameArray.append(placeName)
                            }
                            if let placeId=document.documentID as? String{
                                placeIdArray.append(placeId)
                            }
                        }
                        
                    }
                    self.tableView.reloadData()
                }
            }

        }
        
    }
    
    @objc func addButtonClicked(){
        self.performSegue(withIdentifier: "toUploadVC", sender: nil)
    }
    
    @objc func logOutClicked(){
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
            self.performSegue(withIdentifier: "toVC", sender: nil)
            
        } catch let error {
            print("Çıkış yaparken bir hata oluştu: \(error.localizedDescription)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.placeNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content=cell.defaultContentConfiguration()
        content.text=placeNameArray[indexPath.row]
        cell.contentConfiguration=content
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenPlaceId=placeIdArray[indexPath.row]
        performSegue(withIdentifier: "toPlaceDetail", sender: nil)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            deleteData(placeId: self.placeIdArray[indexPath.row])
            placeNameArray.remove(at: indexPath.row)
            placeIdArray.remove(at: indexPath.row)
            placeNameArray.removeAll(keepingCapacity: false)
            placeIdArray.removeAll(keepingCapacity: false)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="toPlaceDetail"{
            let destinationVC=segue.destination as? PlaceDetailViewController
            destinationVC?.selectedPlaceId=choosenPlaceId
        }
    }
    func deleteData(placeId:String){
        do{
            let firestore=Firestore.firestore()
            try firestore.collection("Places").document(placeId).delete()
        }catch{
            print("success")
        }
    }

}

