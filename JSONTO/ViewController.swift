import UIKit
import SQLite
import Alamofire
class User: Decodable{
  let name: String
  let email: String
  let address: City
  init(name: String, email: String, address: City){
    self.address = address
    self.name = name
    self.email = email
  }
}
class City: Decodable {
  let city: String
  init(city: String){
    self.city = city
  }
}
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
  
  var user = [User]()
  let name = Expression<String>("name")
  let email =  Expression<String>("emial")
  let city = Expression<String>("city")
  let usersTable = Table("uSer5")
  var db : Connection!
  
  @IBOutlet weak var tableView: UITableView!
  
  lazy var refresher: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.tintColor = .red
    refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
    return refreshControl
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("UsersData28.sqlite")
    print(fileUrl.path)
    do{
      db = try Connection(fileUrl.path)
      print(type(of: db))
      createTable()
    }catch{
      print("Error Making Connection")
    }
    if #available(iOS 10.0, *){
      tableView.refreshControl = refresher
    }else {
      tableView.addSubview(refresher)
    }
  }
  
  @objc func requestData() {
    let deadLine = DispatchTime.now() + .milliseconds(1000)
    DispatchQueue.main.asyncAfter(deadline: deadLine){
      self.loadDataFromApi()
      self.refresher.endRefreshing()
    }
  }
  
  func createTable(){
    do{
      try db.scalar(usersTable.exists)
      tableAlreadyExists()
      return
    }catch{
      print(error.localizedDescription)
    }
    do{
      try db.run(usersTable.create { t in
        t.column(name)
        t.column(email)
        t.column(city)
      })
    }catch{
       print("Error Creating Table")
    }
    loadDataFromApi()
  }
  
  func tableAlreadyExists(){
    do{
      for user in try db.prepare(usersTable) {
        let name = user[self.name]
        let email = user[self.email]
        let city = user[self.city]
        let city1 = City(city: city)
        let user2 = User(name: name, email: email, address: city1)
        self.user.append(user2)
      }
      OperationQueue.main.addOperation ({
      self.tableView.reloadData()
      })
      print("From tableAlreadyExists")
      loadDataFromApi()
    }catch{
      print(error.localizedDescription)
    }
  }

  func loadDataFromApi(){
    Alamofire.request("http://jsonplaceholder.typicode.com/users").responseData { respone in
      if let data = respone.result.value{
        do{
          let decoder = JSONDecoder()
          let userdata = try decoder.decode([User].self, from: data)
          self.user = userdata
          self.insertDataToTable()
          OperationQueue.main.addOperation ({
            self.tableView.reloadData()
          })
        }catch{
          print("Error Decoding JSON data")
        }
      }
    }
  }
  func insertDataToTable(){
    var iterator = self.user.makeIterator()
    while let value = iterator.next(){
      print("Data adding to the table")
      let insert = self.usersTable.insert(self.name <- value.name, self.email <- value.email, self.city <- value.address.city)
      do{
        try self.db.run(insert)
      }catch{
        print(error.localizedDescription)
      }
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return user.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableCell
    let users = user[indexPath.row]
    cell.nameLabel.text = users.name
    cell.emailLabel.text = users.email
    cell.cityLabel.text = users.address.city
    return cell
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == UITableViewCell.EditingStyle.delete {
      user.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    }
  }
}
