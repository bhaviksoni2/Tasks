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
  private let jsonFromAlamofire = JsonFromAlamofire()
  @IBOutlet weak var tableView: UITableView!
 
  var users = [User]()
  lazy var refresher: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.tintColor = .red
    refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
    return refreshControl
  }()
  override func viewDidLoad() {
    super.viewDidLoad()
    jsonParse()
    if #available(iOS 10.0, *){
      tableView.refreshControl = refresher
    }else {
      tableView.addSubview(refresher)
    }
  }
  @objc func requestData() {
    print("refreshing data")
    let deadLine = DispatchTime.now() + .milliseconds(1000)
    DispatchQueue.main.asyncAfter(deadline: deadLine){
      self.refresher.endRefreshing()
    }
  }
  func jsonParse(){
    guard let urlToExecute = URL(string: "http://jsonplaceholder.typicode.com/users") else { return }
    do {
    jsonFromAlamofire.execute(urlToExecute) { (json, error) in
      if error != nil {
        print("Error!")
      }else if let json = json {
        print("HI")
        for nam in json{
        guard let na = nam["name"] as? String else { return }
        guard let em = nam["email"] as? String else { return }
        guard let add = nam["address"] as? [String: Any],
          let ci = add["city"] as? String else{ return }
        let user = User(name: na, email: em, city: ci)
        self.users.append(user)
        }
        print(self.users)
      }
      OperationQueue.main.addOperation ({
        self.tableView.reloadData()
      })
    }
    }catch{
  print(error)
  }
    
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
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == UITableViewCell.EditingStyle.delete {
      users.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    }
  }
}

