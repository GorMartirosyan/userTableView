//
//  ViewController.swift
//  userTableView
//
//  Created by Gor on 12/31/20.
//

import UIKit

class ViewController: UIViewController {
    
    var filteredUsers = [User](){
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var savedUsers = [User]()
    var users = [User]()
    var searchActive = false
    
    
    @IBOutlet var segmentOutlet: UISegmentedControl!
    @IBOutlet var searchBarOutlet: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBarOutlet.delegate = self
        
        addTopBorderWithColor(tableView, color: #colorLiteral(red: 0.7018831372, green: 0.7020055652, blue: 0.7018753886, alpha: 1), width: self.view.frame.width)
        
        savedUsers = UserSaver.shared.readUsers()
        NetworkManager.shared.loadJson() { [weak self] users in
            guard users != nil else { return }
            DispatchQueue.main.async {
                self?.users = users ?? []
            }
            DispatchQueue.main.async {
                self?.filteredUsers = self?.users ?? []
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.title = "Users"
        tableView.tableFooterView = UIView()
        if searchActive == false {
            segmentAction(segmentOutlet)
        }
    }
    
    func addTopBorderWithColor(_ objView : UIView, color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: objView.frame.size.width, height: 0.3)
        objView.layer.addSublayer(border)
    }
    
    func footerView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
    
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filteredUsers = users
        case 1:
            tableView.tableFooterView = UIView()
            filteredUsers = savedUsers
        default:
            break
        }
        tableView.reloadData()
    }
}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else { return TableViewCell() }
        cell.setUp(with: filteredUsers[indexPath.row])
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = Storyboard.instantiateViewController(identifier: "DetailViewController") as! DetailViewController
        detailVC.delegate = self
        detailVC.user = User(gender: filteredUsers[indexPath.row].gender?.capitalized,
                             name: filteredUsers[indexPath.row].name,
                             location: filteredUsers[indexPath.row].location,
                             email: filteredUsers[indexPath.row].email,
                             login: filteredUsers[indexPath.row].login,
                             dob: filteredUsers[indexPath.row].dob,
                             registered: filteredUsers[indexPath.row].registered,
                             phone: filteredUsers[indexPath.row].phone,
                             cell: filteredUsers[indexPath.row].cell,
                             id: filteredUsers[indexPath.row].id,
                             picture: filteredUsers[indexPath.row].picture,
                             nat: filteredUsers[indexPath.row].nat)
        let _ = detailVC.view
        if savedUsers.contains(detailVC.user!){
            detailVC.isSaved = true
        }else{
            detailVC.isSaved = false
        }
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
    
}

extension ViewController : UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let position = scrollView.contentOffset.y
        let reloadPostion = self.tableView.contentSize.height - 100 - scrollView.frame.size.height
        if position > reloadPostion &&
            NetworkManager.shared.isFetching == false &&
            self.searchActive == false &&
            self.segmentOutlet.selectedSegmentIndex == 0  {
            
            DispatchQueue.main.async {
                self.tableView.tableFooterView = self.footerView()
            }
            
            DispatchQueue.global().async {
                NetworkManager.shared.loadJson() { [weak self] users in
                    DispatchQueue.main.async {
                        
                        self?.users.append(contentsOf: users ?? [])
                        self?.filteredUsers = self!.users
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.tableView.tableFooterView = nil
                }
            }
        }
    }
}

extension ViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var currentusers : [User] = []
        
        if segmentOutlet.selectedSegmentIndex == 0 {
            currentusers = users
        }else{
            currentusers = savedUsers
        }
        if (searchText == ""){
            filteredUsers = currentusers
        }
        else{
            searchActive = true
            filteredUsers = []
            
            let terms = searchText.lowercased().components(separatedBy: " ")
            self.filteredUsers = currentusers.filter { item in
                
                let name = item.name?.first?.lowercased()
                let lastName = item.name?.last?.lowercased()
                let gender = item.gender?.lowercased()
                let phoneNumber = item.phone?.lowercased()
                let country = item.location?.country?.lowercased()
                let postcode = item.location?.postcode?.lowercased()
                let streetName = (item.location?.street?.name)!
                let state = (item.location?.state)!
                
                let targetsContainTerm: [Bool] = terms.map {
                    (name?.contains($0))! ||
                        (lastName?.contains($0))! ||
                        (gender?.contains($0))! ||
                        (phoneNumber?.contains($0))! ||
                        (country?.contains($0))! ||
                        (postcode?.contains($0))! ||
                        streetName.contains($0) ||
                        state.contains($0)
                }
                return targetsContainTerm.allSatisfy { $0 == true}
            }
            
        }
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        self.segmentOutlet.isUserInteractionEnabled = false
        self.segmentOutlet.isEnabled = false
        self.searchBarOutlet.showsCancelButton = true
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            searchBarCancelButtonClicked(self.searchBarOutlet)
        }
        self.searchBarOutlet.resignFirstResponder()
        self.searchBarOutlet.endEditing(true)
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarOutlet.endEditing(true)
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarOutlet.text = ""
        var currentusers : [User] = []
        if segmentOutlet.selectedSegmentIndex == 0 {
            currentusers = users
        }else{
            currentusers = savedUsers
        }
        filteredUsers = currentusers
        searchActive = false
        self.segmentOutlet.isUserInteractionEnabled = true
        self.segmentOutlet.isEnabled = true
        self.searchBarOutlet.showsCancelButton = false
        self.searchBarOutlet.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        self.tableView.reloadData()
    }
}

extension ViewController: DetailViewControllerDelegate {
    
    func removeUser(_ user: User) {
        if let index:Int = self.savedUsers.firstIndex(where: {$0 == user}) {
            self.savedUsers.remove(at: index)
        }
        UserSaver.shared.writeUsers(savedUsers)
    }
    
    func saveUser(_ user: User) {
        savedUsers.append(user)
        UserSaver.shared.writeUsers(savedUsers)
    }
    
}

