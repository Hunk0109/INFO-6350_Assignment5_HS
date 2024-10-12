import Foundation

// MARK: - MenuItem Class
class MenuItem {
    var name: String
    var description: String
    var price: Double
    var category: String

    init(name: String, description: String, price: Double, category: String) {
        self.name = name
        self.description = description
        self.price = price
        self.category = category
    }

    func display() {
        print("\(name) (\(category)) - \(description): $\(price)")
    }
}

// MARK: - Customer Class
class Customer {
    var customerID: Int
    var name: String
    var email: String
    var phoneNumber: String

    init(customerID: Int, name: String, email: String, phoneNumber: String) {
        self.customerID = customerID
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
    }

    func display() {
        print("Customer ID: \(customerID), Name: \(name), Email: \(email), Phone: \(phoneNumber)")
    }
}

// MARK: - Order Class
enum OrderStatus: String {
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
    case delivered = "Delivered"
}

class Order {
    var orderID: Int
    var customer: Customer
    var items: [MenuItem]
    var totalAmount: Double
    var status: OrderStatus
    var orderDate: String

    init(orderID: Int, customer: Customer, items: [MenuItem], status: OrderStatus) {
        self.orderID = orderID
        self.customer = customer
        self.items = items
        self.status = status
        self.totalAmount = items.reduce(0, { $0 + $1.price })
        self.orderDate = Date().formattedDate()
    }

    func display() {
        print("Order \(orderID) for \(customer.name) - \(status.rawValue) on \(orderDate)")
        for item in items {
            print("- \(item.name): $\(item.price)")
        }
        print("Total: $\(totalAmount)\n")
    }
}

// MARK: - Date Extension for Formatted Date
extension Date {
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy HH:mm"
        return formatter.string(from: self)
    }
}

// MARK: - Restaurant Management Class
class RestaurantManagement {
    private var menuItems: [MenuItem] = []
    private var orders: [Order] = []
    private var customers: [Customer] = []
    private var nextOrderID = 1
    private var nextCustomerID = 1

    func start() {
        var running = true
        while running {
            print("""
            \nWelcome to Restaurant Management System
            1. Manage Menu Items
            2. Manage Orders
            3. Manage Customers
            4. Exit
            """)
            if let choice = readLine(), let option = Int(choice) {
                switch option {
                case 1: manageMenuItems()
                case 2: manageOrders()
                case 3: manageCustomers()
                case 4: running = false
                default: print("Invalid option, please try again.")
                }
            }
        }
    }

    // MARK: - Menu Items Management
    private func manageMenuItems() {
        print("""
        \nMenu Items Management
        1. Add Menu Item
        2. View Menu Items
        3. Update Menu Item
        4. Delete Menu Item
        5. Back to Main Menu
        """)
        if let choice = readLine(), let option = Int(choice) {
            switch option {
            case 1: addMenuItem()
            case 2: viewMenuItems()
            case 3: updateMenuItem()
            case 4: deleteMenuItem()
            case 5: return
            default: print("Invalid option.")
            }
        }
    }

    private func addMenuItem() {
        print("Enter name of menu item:")
        guard let name = readLine(), !menuItems.contains(where: { $0.name == name }) else {
            print("Menu item with this name already exists.")
            return
        }

        print("Enter description:")
        let description = readLine() ?? ""

        print("Enter price:")
        guard let priceInput = readLine(), let price = Double(priceInput), price > 0 else {
            print("Invalid price.")
            return
        }

        print("Enter category:")
        let category = readLine() ?? ""

        let newItem = MenuItem(name: name, description: description, price: price, category: category)
        menuItems.append(newItem)
        print("Menu item added successfully.")
    }

    private func viewMenuItems() {
        let sortedItems = menuItems.sorted(by: { $0.category < $1.category })
        for item in sortedItems {
            item.display()
        }
    }

    private func updateMenuItem() {
        print("Enter the name of the item to update:")
        guard let name = readLine(), let menuItem = menuItems.first(where: { $0.name == name }) else {
            print("Menu item not found.")
            return
        }

        print("Enter new price (greater than 0):")
        guard let priceInput = readLine(), let price = Double(priceInput), price > 0 else {
            print("Invalid price.")
            return
        }

        menuItem.price = price
        print("Menu item updated successfully.")
    }

    private func deleteMenuItem() {
        print("Enter the name of the item to delete:")
        guard let name = readLine(), let index = menuItems.firstIndex(where: { $0.name == name }) else {
            print("Menu item not found.")
            return
        }

        if orders.contains(where: { $0.items.contains(where: { $0.name == name }) }) {
            print("Cannot delete menu item. It is part of an active order.")
            return
        }

        menuItems.remove(at: index)
        print("Menu item deleted successfully.")
    }

    // MARK: - Orders Management
    private func manageOrders() {
        print("""
        \nOrders Management
        1. Place New Order
        2. View Orders
        3. Update Order Status
        4. Cancel Order
        5. Back to Main Menu
        """)
        if let choice = readLine(), let option = Int(choice) {
            switch option {
            case 1: placeNewOrder()
            case 2: viewOrders()
            case 3: updateOrderStatus()
            case 4: cancelOrder()
            case 5: return
            default: print("Invalid option.")
            }
        }
    }

    private func placeNewOrder() {
        print("Enter customer email:")
        guard let email = readLine(), let customer = customers.first(where: { $0.email == email }) else {
            print("Customer not found.")
            return
        }

        print("Enter menu item names separated by commas:")
        guard let itemsInput = readLine() else { return }
        let itemNames = itemsInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let items = menuItems.filter { itemNames.contains($0.name) }

        if items.isEmpty {
            print("No valid items found.")
            return
        }

        let newOrder = Order(orderID: nextOrderID, customer: customer, items: items, status: .pending)
        orders.append(newOrder)
        nextOrderID += 1
        print("Order placed successfully.")
    }

    private func viewOrders() {
        let sortedOrders = orders.sorted(by: { $0.orderDate > $1.orderDate })
        for order in sortedOrders {
            order.display()
        }
    }

    private func updateOrderStatus() {
        print("Enter order ID to update:")
        guard let orderIDInput = readLine(), let orderID = Int(orderIDInput), let order = orders.first(where: { $0.orderID == orderID }) else {
            print("Order not found.")
            return
        }

        if order.status == .completed {
            print("Cannot update a completed order.")
            return
        }

        print("Enter new status (Pending, In Progress, Completed, Delivered):")
        guard let statusInput = readLine(), let newStatus = OrderStatus(rawValue: statusInput) else {
            print("Invalid status.")
            return
        }

        order.status = newStatus
        print("Order status updated successfully.")
    }

    private func cancelOrder() {
        print("Enter order ID to cancel:")
        guard let orderIDInput = readLine(), let orderID = Int(orderIDInput), let index = orders.firstIndex(where: { $0.orderID == orderID }) else {
            print("Order not found.")
            return
        }

        if orders[index].status == .delivered {
            print("Cannot cancel a delivered order.")
            return
        }

        orders.remove(at: index)
        print("Order canceled successfully.")
    }

    // MARK: - Customers Management
    private func manageCustomers() {
        print("""
        \nCustomers Management
        1. Register New Customer
        2. View Customers
        3. Update Customer Information
        4. Delete Customer
        5. Back to Main Menu
        """)
        if let choice = readLine(), let option = Int(choice) {
            switch option {
            case 1: registerCustomer()
            case 2: viewCustomers()
            case 3: updateCustomer()
            case 4: deleteCustomer()
            case 5: return
            default: print("Invalid option.")
            }
        }
    }

    private func registerCustomer() {
        print("Enter customer name:")
        let name = readLine() ?? ""

        print("Enter customer email:")
        let email = readLine() ?? ""

        print("Enter customer phone number:")
        let phoneNumber = readLine() ?? ""

        let newCustomer = Customer(customerID: nextCustomerID, name: name, email: email, phoneNumber: phoneNumber)
        customers.append(newCustomer)
        nextCustomerID += 1
        print("Customer registered successfully.")
    }

    private func viewCustomers() {
        for customer in customers {
            customer.display()
        }
    }

    private func updateCustomer() {
        print("Enter customer ID to update:")
        guard let customerIDInput = readLine(), let customerID = Int(customerIDInput), let customer = customers.first(where: { $0.customerID == customerID }) else {
            print("Customer not found.")
            return
        }

        print("Enter new email:")
        customer.email = readLine() ?? ""

        print("Enter new phone number:")
        customer.phoneNumber = readLine() ?? ""

        print("Customer updated successfully.")
    }

    private func deleteCustomer() {
        print("Enter customer ID to delete:")
        guard let customerIDInput = readLine(), let customerID = Int(customerIDInput), let index = customers.firstIndex(where: { $0.customerID == customerID }) else {
            print("Customer not found.")
            return
        }

        if orders.contains(where: { $0.customer.customerID == customerID }) {
            print("Cannot delete customer. They have active orders.")
            return
        }

        customers.remove(at: index)
        print("Customer deleted successfully.")
    }
}

// MARK: - Start the Program
let restaurantManagement = RestaurantManagement()
restaurantManagement.start()
