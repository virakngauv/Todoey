//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Virak Ngauv on 2/23/18.
//  Copyright © 2018 Virak Ngauv. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {
    let realm = try! Realm()
    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    
    
    //MARK: - TableView Datasource Methods
    //(Gets called when tableView.reloadData() is run)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
        guard let bgColor = UIColor.init(hexString: (categories?[indexPath.row].bgColor)!) else {fatalError()}
        cell.backgroundColor = bgColor
        cell.textLabel?.textColor = ContrastColorOf(bgColor, returnFlat: true)
        return cell
    }
    
    
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    
    //MARK: - Data Manipulation Methods
    func saveCategories(category : Category){
        do {try realm.write {realm.add(category)}}
        catch {print("Error trying to save context, \(error)")}
        
        loadCategories()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //Delete data
    override func updateModel(at indexPath: IndexPath) {
        if let swipedCell = self.categories?[indexPath.row] {
            do {try self.realm.write { self.realm.delete(swipedCell)}}
            catch {print("Error deleting cell, \(error)")}
        }
    }
    
    
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Add Category", style: .default){(action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.bgColor = UIColor.randomFlat.hexValue()
            print(newCategory.bgColor)
            
            self.saveCategories(category: newCategory)
        }
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}
