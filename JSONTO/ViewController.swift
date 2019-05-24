//
//  ViewController.swift
//  JSONTO
//
//  Created by Brijesh Patel on 23/05/19.
//  Copyright © 2019 Brijesh Patel. All rights reserved.
//

import UIKit
struct User{
    let name: String
    let email: String
    let city: String
    init(name: String, email: String, city: String) {
        self.name = name
        self.email = email
        self.city = city
    }
}
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
 
    @IBOutlet weak var tableView: UITableView!
    struct User{
        let name: String
        let email: String
        let city: String
    }
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
       
       parseJSON()
   
    }
   
    func parseJSON(){
        guard let url = URL(string: "http://jsonplaceholder.typicode.com/users/") else {return}
        let session = URLSession.shared
        
        session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error ?? "")
            }
            if data != nil {
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
                    guard let JSon = json as? [Dictionary<String, Any>] else {return}
                    for nam in JSon{
                        guard let na = nam["name"] as? String else { return }
                        guard let em = nam["email"] as? String else { return }
                        guard let add = nam["address"] as? [String: Any],
                            let ci = add["city"] as? String else{ return }
                        
                         let user = User(name: na, email: em, city: ci)
                        self.users.append(user)
                       }
                    OperationQueue.main.addOperation ({
                         self.tableView.reloadData()
                    })
                    }catch{
                    print(error)
                }
            }
            
            }.resume()
      
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return users.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TabelCell 
        let user = users[indexPath.row]
        
        cell.nameLabel.text = user.name
        cell.emailLabel.text = user.email
        cell.cityLabel.text = user.city
        // add code to download the image from fruit.imageURL
        return cell
    }

}

