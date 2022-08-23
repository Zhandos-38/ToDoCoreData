//
//  ViewController.swift
//  ToDoListCoreData
//
//  Created by Zhandos38 on 24.08.2022.
//

import UIKit
import CoreData
import SwipeCellKit

class ViewController: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var items = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.rowHeight = 80.0
        getAllItems()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        print(item.name!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Core Data methods
    func saveChanges(){
        do {
            try context.save()
        } catch {
            print("Error saving changes")
        }
    }
    
    func getAllItems() {
        do {
            items = try context.fetch(Item.fetchRequest())
        } catch {
            print("Error fetching all items")
        }
        tableView.reloadData()
    }
    
    func createItem(name: String) {
        let newItem = Item(context: context)
        newItem.name = name
        newItem.dateCreated = Date()
        saveChanges()
        getAllItems()
    }
    
    func editItem(name: String,at indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.name = name
        saveChanges()
        getAllItems()
    }
    
    func deleteItem(at indexPath: IndexPath) {
        context.delete(items[indexPath.row])
        saveChanges()
        getAllItems()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add To-Do item", message: "", preferredStyle: .alert)
        let createAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            self.createItem(name: textField.text!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Example: buy milk, feed cat"
            textField = alertTextField
        }
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    

}

extension ViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
            var textField = UITextField()
            let alert = UIAlertController(title: "Edit To-do item", message: "", preferredStyle: .alert)
            let editAction = UIAlertAction(title: "Submit", style: .destructive) { (action) in
                self.editItem(name: textField.text!, at: indexPath)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addTextField { alertTextField in
                alertTextField.placeholder = "Example: buy milk, feed cat"
                textField = alertTextField
            }
            alert.addAction(cancelAction)
            alert.addAction(editAction)
            self.present(alert, animated: true, completion: nil)
        }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.deleteItem(at: indexPath)
        }
        
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction, editAction]
    }
}
