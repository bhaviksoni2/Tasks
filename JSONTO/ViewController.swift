import UIKit
import SQLite
import Alamofire
class Users: Decodable{
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
  var user = [Users]()
  let name = Expression<String>("name")
  let email =  Expression<String>("emial")
  let city = Expression<String>("city")
  let usersTable = Table("uSer4")
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
    }
    catch{
      print("Error Making Connection")
    }
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
  func createTable(){
      do{
        print("Inside Do block")
        try db.scalar(usersTable.exists)
        print("Inside try block")
        for user in try db.prepare(usersTable) {
          print("Table is available")
          guard let name = user[name] as? String else { return }
          guard let email = user[email] as? String else { return }
          guard let city = user[city] as? String else { return }
          let city1 = City(city: city)
          let user2 = Users(name: name, email: email, address: city1)
          self.user.append(user2)
        }
        OperationQueue.main.addOperation ({
          self.tableView.reloadData()
        })
        print("From create table")
        jsonParse()
      }catch{
        print("Table is not available")
        do{
        try db.run(usersTable.create { t in
          t.column(name)
          t.column(email)
          t.column(city)
        })}catch{
          print("Error Creating Table")
        }
        jsonParse()
      }
  }
  func jsonParse(){
    print("Everything is Fine")
    do {
      Alamofire.request("http://jsonplaceholder.typicode.com/users").responseData { respone in
        if let data = respone.result.value, let utf8s = String(data: data, encoding: .utf8) {
          do{
            let decoder = JSONDecoder()
            let userdata = try decoder.decode([Users].self, from: data)
            self.user = userdata
            print("Data Added to array by jsonParse")
            var iterator = self.user.makeIterator()
            print("Iterator created")
            while let value = iterator.next(){
              print("data adding to the table")
              let insert = self.usersTable.insert(self.name <- value.name, self.email <- value.email, self.city <- value.address.city)
              do{
                try self.db.run(insert)
              }catch{
                print(error.localizedDescription)
              }
            }
            OperationQueue.main.addOperation ({
              self.tableView.reloadData()
            })
          }catch{
            print("Error Decoding JSON data")
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
