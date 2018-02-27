//
//  ViewController.swift
//  Todoey
//
//  Created by Virak Ngauv on 2/10/18.
//  Copyright © 2018 Virak Ngauv. All rights reserved.
//

import UIKit
import RealmSwift


class TodoListViewController: UITableViewController {
    var todoItems : Results<Item>?
    let realm = try! Realm()
    var selectedCategory : Category?{didSet{loadItems()}}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
}

    
    
    //MARK: TableView Datasource Methods
    //How cells are loaded and displayed
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(todoItems?.count ?? 1)
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
    
        return cell
    }
    
    
    
    //MARK: TableView Delegate Methods
    //Allows user to check and uncheck task
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
    }

    
    
    //MARK: Add new tasks to todo list
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        //Action that gets triggered when user "Adds Item"
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let item = Item()
                        item.title = textField.text!
                        item.dateCreated = Date()
                        currentCategory.items.append(item)
                    }
                }
                catch {print("Error trying to save item, \(error)")}
            }
            
            self.loadItems()
        }
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        //Show completed alert
        present(alert, animated: true, completion: nil)
    }
    
    
    
    //MARK: Model Manipulation Methods
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)

        tableView.reloadData()
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
