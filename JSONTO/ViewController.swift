//
//  ViewController.swift
//  JSONTO
//
//  Created by Brijesh Patel on 23/05/19.
//  Copyright © 2019 Brijesh Patel. All rights reserved.
//

import UIKit
import SQLite
import Alamofire
class Users:  NSObject, Decodable{
  let id: Int
  let name: String
  let username: String
  let email: String
  let address: City
  let phone: String
  let website: String
  init(id: Int,name: String,username: String, email: String, address: City, phone: String, website: String) {
    self.id = id
    self.name = name
    self.username = username
    self.email =  email
    self.address = address
    self.phone = phone
    self.website = website
  }
}
class City: Decodable {
  let street: String
  let suite: String
  let city: String
  let zipcode: String
  init(street: String, suite: String, city: String, zipcode: String) {
    self.street = street
    self.suite = suite
    self.city = city
    self.zipcode = zipcode
  }
}
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
  var user = [Users]()
  @IBOutlet weak var tableView: UITableView!
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
    let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("UsersData22.sqlite")
    print(fileUrl.path)
    print("Everything is Fine")
    do {
      Alamofire.request("http://jsonplaceholder.typicode.com/users").responseData { respone in
        if let data = respone.result.value, let utf8s = String(data: data, encoding: .utf8) {
          do{
            let decoder = JSONDecoder()
            let userdata = try decoder.decode([Users].self, from: data)
            self.user = userdata
            let db = try Connection(fileUrl.path)
            print("Done")
            let name = Expression<String>("name")
            let email =  Expression<String>("emial")
            let city = Expression<String>("city")
            let usersTable = Table("USERS6")
            do {
              try db.scalar(usersTable.exists)
              for user in try db.prepare(usersTable) {
                print("name: \(user[name]), email: \(user[email]), city: \(user[city])")
                // id: 1, name: Optional("Alice"), email: alice@mac.com
              }
            } catch {
            }
            try db.run(usersTable.create { t in
              t.column(name, primaryKey: true)
              t.column(email)
              t.column(city)
            })
            var iterator = self.user.makeIterator()
            while let value = iterator.next(){
              let insert = usersTable.insert(name <- value.name, email <- value.email, city <- value.address.city)
              try db.run(insert)
            }
            OperationQueue.main.addOperation ({
              self.tableView.reloadData()
            })
          }catch{
            print("Table is already created")
            OperationQueue.main.addOperation ({
              self.tableView.reloadData()
            })
          }
        }
      }
    }
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return user.count
  }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 85.0
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TabelCell
    let users = user
    cell.nameLabel.text = users[indexPath.row].name    
    cell.emailLabel.text = users[indexPath.row].email
    cell.cityLabel.text = users[indexPath.row].address.city
    // add code to download the image from fruit.imageURL
    return cell
  }
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == UITableViewCell.EditingStyle.delete {
      user.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    }
  }
}

