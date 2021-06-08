//
//  ItemsViewController.swift
//  TaskList
//
//  Created by Andrey Apanasik on 21/10/2019.
//  Copyright © 2019 Andrey Apanasik. All rights reserved.
//

import UIKit
import CoreData

class ItemsViewController: UITableViewController, UISearchBarDelegate, UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		return nil
	}
	

	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		loadItems()
		self.title = selectedCategory?.name
		tableView.rowHeight = 75
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        let item = items[indexPath.row]
		cell.textLabel?.text = item.title
		cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    
	
	// MARK: - TableView delegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		items[indexPath.row].done = !items[indexPath.row].done
		tableView.deselectRow(at: indexPath, animated: true)
		saveItem()
	}
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let delete = UIContextualAction(style: .destructive, title: "") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
			self.context.delete(self.items[indexPath.row])
			self.items.remove(at: indexPath.row)
			self.saveItem()
		}
		delete.image = UIImage(systemName: "trash")
		
		return UISwipeActionsConfiguration(actions: [delete])
	}
	
	
	
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in

			let rename = UIAction(title: "Rename", image: UIImage(systemName: "square.and.pencil")) { action in
				var alertTextFieald = UITextField()
				let alert = UIAlertController(title: "Rename", message: "", preferredStyle: .alert)
				
				alert.addTextField { (text) in
					text.placeholder = "Enter New Name"
					alertTextFieald = text
				}
				
				let aceptAction = UIAlertAction(title: "OK", style: .default) { (action) in
					if let text = alertTextFieald.text {
						self.items[indexPath.row].title = text
					}
					self.saveItem()
				}
				let cancleAction = UIAlertAction(title: "Cancle", style: .cancel) { (action) in }
				
				alert.addAction(aceptAction)
				alert.addAction(cancleAction)
				
				self.present(alert, animated: true, completion: nil)
			}
				return UIMenu(title: "", children: [rename])
		}
	}
	
	
    
    // MARK: - Data manipulation
    
    func saveItem() {
		do {
			try context.save()
		} catch {
			print("Error saving items, \(error)")
		}
		tableView.reloadData()
    }
    
	func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
		let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
		if let newPredicate = predicate {
			request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [newPredicate, categoryPredicate])
		} else {
			request.predicate = categoryPredicate
		}
		
		do {
			items = try context.fetch(request)
		} catch {
			print("Error loading items, \(error)")
		}
		tableView.reloadData()
    }
    
    
    // MARK: - Add new item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var alertTextField = UITextField()
        let alert = UIAlertController(title: "Add", message: "", preferredStyle: .alert)
        
        alert.addTextField { (text) in
            text.placeholder = "Enter new task"
            alertTextField = text
        }
        
        let alertAddAction = UIAlertAction(title: "Add", style: .default) { (action) in
            guard let text = alertTextField.text, !text.isEmpty else { return }
			let newItem = Item(context: self.context)
            newItem.title = text
            newItem.done = false
			if let currentCategory = self.selectedCategory {
				newItem.parentCategory = currentCategory
			}
			self.items.append(newItem)
			self.saveItem()
			self.tableView.reloadData()
        }
		
		let alertCancleAction = UIAlertAction(title: "Cancle", style: .destructive) { (action) in }
		
		alert.addAction(alertAddAction)
		alert.addAction(alertCancleAction)
		
		present(alert, animated: true, completion: nil)
    }
    
	
	
	// MARK: - SeachBar
	
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		searchBar.showsCancelButton = true
		let request : NSFetchRequest<Item> = Item.fetchRequest()
		if searchBar.text!.count == 0 {
			loadItems()
			searchBar.showsCancelButton = false
			searchBar.endEditing(true)
		} else {
			let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
			request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
			loadItems(with: request, predicate: predicate)
		}
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.text = ""
		loadItems()
		searchBar.showsCancelButton = false
		searchBar.endEditing(true)
	}

}
