//
//  CategoryViewController.swift
//  TaskList
//
//  Created by Andrey Apanasik on 21/10/2019.
//  Copyright © 2019 Andrey Apanasik. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController, UIContextMenuInteractionDelegate {

    
	var categories = [Category]()
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
		tableView.rowHeight = 75
		navigationController?.hidesBarsOnSwipe = true
    }

    
    
    // MARK: - TableView Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
		cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "goToItems" {
			let itemsVC = segue.destination as! ItemsViewController
			itemsVC.selectedCategory = categories[index]
		}
    }
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let delete = UIContextualAction(style: .destructive, title: "") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
			for item in self.categories[indexPath.row].items! {
				self.context.delete(item as! NSManagedObject)
			}
			self.context.delete(self.categories[indexPath.row])
			self.categories.remove(at: indexPath.row)
			self.saveCategory()
		}
		delete.image = UIImage(systemName: "trash")
		return UISwipeActionsConfiguration(actions: [delete])
	}
    
    
	
	// MARK: - Context Menu Delegate
	
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
						self.categories[indexPath.row].name = text
					}
					self.saveCategory()
				}
				let cancleAction = UIAlertAction(title: "Cancle", style: .cancel) { (action) in }
				
				alert.addAction(aceptAction)
				alert.addAction(cancleAction)
				
				self.present(alert, animated: true, completion: nil)
			}
			
			let clear = UIAction(title: "Clear", image: UIImage(systemName: "clear"), attributes: .destructive) { action in
				
				let alert = UIAlertController(title: "Delete all tasks in \(self.categories[indexPath.row].name!)?", message: "", preferredStyle: .alert)
				
				let aceptAction = UIAlertAction(title: "Yes", style: .default) { (action) in
					for item in self.categories[indexPath.row].items! {
						self.context.delete(item as! NSManagedObject)
					}
					self.saveCategory()
				}
				
				let cancleAction = UIAlertAction(title: "Cancle", style: .cancel) { (action) in }
				
				alert.addAction(aceptAction)
				alert.addAction(cancleAction)
				
				self.present(alert, animated: true, completion: nil)
			}
			

		return UIMenu(title: "", children: [rename, clear])
		}
	}
	
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		return nil
	}
	
	
	
    // MARK: - Data Manipulation
    
    func saveCategory() {
		do {
			try context.save()
		} catch {
			print("Error saving categories, \(error)")
		}
		tableView.reloadData()
    }
    
	func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
		do {
			categories = try context.fetch(request)
		} catch {
			print("Error loading categories, \(error)")
		}
    }
    
    
    
    // MARK: - Add New Category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var alertTextField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        alert.addTextField { (text) in
            text.placeholder = "Enter new category"
            alertTextField = text
        }
        
        let alertAddAction = UIAlertAction(title: "Add", style: .default) { (action) in
            guard let text = alertTextField.text, !text.isEmpty else { return }
			let newCategory = Category(context: self.context)
            newCategory.name = text
			self.categories.append(newCategory)
            self.saveCategory()
        }
        let alertCancleAction = UIAlertAction(title: "Cancle", style: .destructive) { (action) in }
        
        alert.addAction(alertAddAction)
        alert.addAction(alertCancleAction)
        present(alert, animated: true, completion: nil)
    }
    
    
}
