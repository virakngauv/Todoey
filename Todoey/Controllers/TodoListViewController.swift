//
//  ViewController.swift
//  Todoey
//
//  Created by Virak Ngauv on 2/10/18.
//  Copyright © 2018 Virak Ngauv. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class TodoListViewController: SwipeTableViewController {
    let realm = try! Realm()
    var todoItems : Results<Item>?
    var selectedCategory : Category?{didSet{loadItems()}}
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        
        guard let colorHex = selectedCategory?.bgColor else { fatalError() }

        updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }

    
    
    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colorHexCode : String){
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist (like the limit).")}
        
        guard let navBarColor = UIColor.init(hexString: colorHexCode)  else {fatalError()}
        
        navBar.barTintColor = navBarColor
        
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        
        searchBar.barTintColor = navBarColor
    }
    
    
    //MARK: TableView Datasource Methods
    //(Gets called when tableView.reloadData() is run)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.backgroundColor = UIColor.init(hexString: selectedCategory!.bgColor)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count))
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            cell.accessoryType = item.done ? .checkmark : .none
        } else {cell.textLabel?.text = "No Items Added"}
    
        return cell
    }
    
    
    
    //MARK: TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Allows user to check and uncheck task
        if let item = todoItems?[indexPath.row] {
            do {try realm.write {item.done = !item.done}}
            catch {print("Error saving done status, \(error)")}
        }
        
        tableView.reloadData()
    }

    
    
    //MARK: Data Manipulation Methods
    func saveItems(_ item : Item, in category : Category) {
        do {try self.realm.write {category.items.append(item)}}
        catch {print("Error trying to save item, \(error)")}
        
        loadItems()
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)
        
        tableView.reloadData()
    }
    
    //Delete data
    override func updateModel(at indexPath: IndexPath) {
        if let swipedCell = self.todoItems?[indexPath.row] {
            do {try self.realm.write { self.realm.delete(swipedCell)}}
            catch {print("Error deleting cell, \(error)")}
        }
    }
    
    
    
    //MARK: Add new tasks to todo list
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        //Action that gets triggered when user "Adds Item"
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let currentCategory = self.selectedCategory {
                let item = Item()
                item.title = textField.text!
                item.dateCreated = Date()
                
                self.saveItems(item, in: currentCategory)
            }
        }
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    


}

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
