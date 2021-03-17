//
//  ViewController.swift
//  SectionedTableView
//
//  Created by Scott Leonard on 3/16/21.
//

import UIKit

class TestViewController: UIViewController {
	
	var tableView: UITableView = {
		let tableView = UITableView()
		tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CELL_KEY")
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.backgroundColor = .red
		tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
		return tableView
	}()
	
	lazy var dataSource = setDataSource()

	override func viewDidLoad() {
		super.viewDidLoad()
		setDataSource()
		tableView.delegate = self
		view.addSubview(tableView)
		setupTableViewConstraints()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		createSnapShot(sections: [
			.account,
			.general,
			.homebase
		], rowItems: [
			CustomizableTableViewItem(title: "Email", section: .account),
			CustomizableTableViewItem(title: "Change Account Password", section: .account, hasDisclosureIndicator: true),
			CustomizableTableViewItem(title: "Privacy", section: .account, hasDisclosureIndicator: true),
			CustomizableTableViewItem(title: "Push Notification", section: .general, hasDisclosureIndicator: true),
			CustomizableTableViewItem(title: "Security", section: .general, hasDisclosureIndicator: true),
			CustomizableTableViewItem(title: "Firmware Version", section: .homebase),
			CustomizableTableViewItem(title: "Paired Wifi: XXXXXX", section: .homebase, isHidden: false),
			CustomizableTableViewItem(title: "Update Wifi Credential", section: .homebase, hasDisclosureIndicator: true, action: { print("Tapped") }),
			CustomizableTableViewItem(title: "Disable Home Base", section: .homebase, textColor: .orange),
			CustomizableTableViewItem(title: "Reboot Home Base", section: .homebase, textColor: .orange),
			CustomizableTableViewItem(title: "Remove Home Base", section: .homebase, textColor: .red),
		])
	}
	
	func setupTableViewConstraints() {
		NSLayoutConstraint.activate([
			tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			tableView.heightAnchor.constraint(equalTo: view.heightAnchor),
			tableView.widthAnchor.constraint(equalTo: view.widthAnchor)
		])
	}
	
	func createSnapShot(sections: [TableViewSections], rowItems: [CustomizableTableViewItem]) {
		var snapshot = NSDiffableDataSourceSnapshot<TableViewSections,CustomizableTableViewItem>()
		
		
		var accountSectionItems: [CustomizableTableViewItem] = []
		var generalSectionItems: [CustomizableTableViewItem] = []
		var homebaseSectionItems: [CustomizableTableViewItem] = []
		
		rowItems.forEach({
			if $0.isHidden == false {
				switch $0.section {
				case .account:
					accountSectionItems.append($0)
				case .general:
					generalSectionItems.append($0)
				case .homebase:
					homebaseSectionItems.append($0)
				}
			}
		})
		
		if !accountSectionItems.isEmpty {
			snapshot.appendSections(sections.filter({ $0 == .account }))
			snapshot.appendItems(accountSectionItems, toSection: .account)
		}
		
		if !generalSectionItems.isEmpty {
			snapshot.appendSections(sections.filter({ $0 == .general }))
			snapshot.appendItems(generalSectionItems, toSection: .general)
		}
		
		if !homebaseSectionItems.isEmpty {
			snapshot.appendSections(sections.filter({ $0 == .homebase }))
			snapshot.appendItems(homebaseSectionItems, toSection: .homebase)
		}
		
		dataSource?.apply(snapshot, animatingDifferences: true, completion: { })
	}
}

extension TestViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		40
	}

	@discardableResult
	func setDataSource() -> CustomTableViewDataSource? {
		dataSource = CustomTableViewDataSource(tableView: tableView, cellProvider: { (tableView, index, item) -> UITableViewCell? in
			let cell = tableView.dequeueReusableCell(withIdentifier: "CELL_KEY") as? CustomTableViewCell
			cell?.textLabel?.text = item.title
			cell?.textLabel?.textColor = item.textColor
			cell?.textLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
			cell?.accessoryType = item.hasDisclosureIndicator ? .disclosureIndicator : .none
			
			return cell
		})
		
		return dataSource
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		(view as? UITableViewHeaderFooterView)?.contentView.backgroundColor = .white
		(view as? UITableViewHeaderFooterView)?.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
		
		let line = UIView()
		line.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(line)
		
		line.backgroundColor = .black
		line.alpha = 0.3
		
		NSLayoutConstraint.activate([
			line.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			line.heightAnchor.constraint(equalToConstant: 0.4),
			line.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
			line.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		40
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 2))
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let action = dataSource?.itemIdentifier(for: indexPath)
		action?.performAction()
	}
	
	class CustomTableViewDataSource: UITableViewDiffableDataSource<TableViewSections, CustomizableTableViewItem> {
		override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
			switch section {
			case 0:
				return "Account"
			case 1:
				return "General"
			case 2:
				return "Home Base"
			default:
				return nil
			}
		}
				
	}
}

class CustomTableViewCell: UITableViewCell { }

struct CustomizableTableViewItem: Hashable {
	var title: String
	var section: TableViewSections
	var hasDisclosureIndicator: Bool = false
	var textColor: UIColor = .black
	var isHidden: Bool = false
	var action: () -> Void = { }
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(title)
	}
	
	func performAction() {
		action()
	}
	
	static func == (lhs: CustomizableTableViewItem, rhs: CustomizableTableViewItem) -> Bool {
		lhs.title == rhs.title
	}
}

enum TableViewSections: CaseIterable {
	case account
	case general
	case homebase
}

