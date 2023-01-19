-- -- CUSTOMER
CREATE TABLE CUSTOMER(
    CustID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    Name VARCHAR(255) NOT NULL,
    Phone VARCHAR(255) NOT NULL
); 

-- -- RATE
CREATE TABLE RATE (
    Type INT NOT NULL,
    Category INT NOT NULL,
    Weekly INT NOT NULL,
    Daily INT NOT NULL,
    PRIMARY KEY (Type, Category)
);


-- VEHICLE
CREATE TABLE VEHICLE(
      VehicleID Int NOT NULL,
      Description VARCHAR(255) NOT NULL,
      Year  INT  NOT NULL,
      Type  INT  NOT NULL,
      Category INT NOT NULL,
      PRIMARY KEY(VehicleID),
      FOREIGN KEY(Type, Category) REFERENCES RATE(Type,Category)
);

-- RENTAL
CREATE TABLE RENTAL(
    CustID INT NOT NULL,
    VehicleID VARCHAR(255) NOT NULL,
    StartDate DATE NOT NULL,
    OrderDate DATE NOT NULL,
    RentalType INT NOT NULL,
    Qty INT NOT NULL,
    ReturnDate DATE NOT NULL, 
    TotalAmount INT NOT NULL, 
    PaymentDate DATE,
    FOREIGN KEY (CustID) REFERENCES CUSTOMER(CustID),
    FOREIGN KEY (VehicleID) REFERENCES VEHICLE(VehicleID)
);


QUERY 1
ALTER TABLE RENTAL
ADD Returned INT;

UPDATE RENTAL
SET Returned = 
    CASE WHEN PaymentDate = 'NULL' THEN 0
    ELSE 1

    END ;



CREATE VIEW vRentalInfo AS
SELECT R.OrderDate, 
R.StartDate, R.ReturnDate, R.Qty * R.RentalType AS TotalDays, R.VehicleID AS VIN, V.Description AS VEHICLE,
CASE V.Type
       WHEN 1 THEN  'Compact'
       WHEN 2 THEN 'Medium'
       WHEN 3 THEN  'Large'
       WHEN 4 THEN   'SUV'
       WHEN 5 THEN  'Truck'
  ELSE 'VAN'
  END AS 'Type',

  CASE V.Category
    WHEN 0 then 'Basic'
      Else 'Luxury'
      END AS 'Category',

C.CustID AS CustomerID, C.Name AS CustomerName, R.TotalAmount AS OrderAmount, 
CASE R.PaymentDate
WHEN 'NULL' THEN R.TotalAmount
ELSE 0
END AS 'RentalBalance'

FROM RENTAL R, VEHICLE V, CUSTOMER C
WHERE C.CustID = R.CustID AND R.VehicleID = V.VehicleID
ORDER BY R.StartDate ASC;

from tkinter import *
from tkinter import ttk
from datetime import date

import sqlite3

root = Tk()
root.title('Car Rental')

# The size
root.geometry("300x300")

# connect to the DB
conn = sqlite3.connect('CarDB.db')
print("Connected to DB successfully")

# Create a cursor
add_book_c = conn.cursor()


# Add Customer Information
def CustomerF():
    t3 = Toplevel(root)
    t3.geometry('500x500')
    t3.title("Add Customer")
    
    def add_cust():
        submit_conn = sqlite3.connect('CarDB.db')
        submit_cur = submit_conn.cursor()
        
        submit_cur.execute("INSERT INTO CUSTOMER VALUES(null, :Name, :Phone)",
                        {
                            'Name': Name.get(),
                            'Phone': Phone.get()
                        })

        submit_conn.commit()
        submit_conn.close()
    Name = Entry(t3, width=30)
    Name.grid(row=0, column=1, padx = 20)

    Phone = Entry(t3, width=30)
    Phone.grid(row=1, column=1)

    #labels
    name_label = Label(t3, text = 'Name: ')
    name_label.grid(row = 0, column=0)
    phone_label = Label(t3, text = 'Phone No: ')
    phone_label.grid(row =1, column = 0)

    submit_btn = Button(t3, text ='Add Customer ', command = add_cust)
    submit_btn.grid(row = 7, column =0, columnspan = 2, pady = 10, padx = 10, ipadx = 140)

# Add Vehicle Information
def addVehicle():
    
    t2 = Toplevel(root)
    t2.geometry('500x500')
    t2.title("Add Vehicle")
    
    def insert_addVehicle():
        add_conn = sqlite3.connect('CarDB.db')
        add_cur = add_conn.cursor()
        
        add_cur.execute("INSERT INTO VEHICLE VALUES(:VehicleID, :Description,:Year,:Type,:Category)",
                        {
                            'VehicleID': VehicleID.get(),
                            'Description': Description.get(),
                            'Year': Year.get(),
                            'Type': Type.get(),
                            'Category': Category.get(),
                        })

        add_conn.commit()
        add_conn.close()
    
    VehicleID = Entry(t2, width=30)
    VehicleID.grid(row=0, column=1, padx = 20)

    Description = Entry(t2, width=30)
    Description.grid(row=1, column=1)

    Year = Entry(t2, width=30)
    Year.grid(row=2, column=1)

    Type = Entry(t2, width=30)
    Type.grid(row=3, column=1)

    Category = Entry(t2, width=30)
    Category.grid(row=4, column=1)

    VehicleID_label = Label(t2, text = 'VehicleID: ')
    VehicleID_label.grid(row = 0, column=0)
    Description_label = Label(t2, text = 'Description: ')
    Description_label.grid(row =1, column = 0)
    Year_label = Label(t2, text = 'Year: ')
    Year_label.grid(row =2, column = 0)
    Type_label = Label(t2, text = 'Type: ')
    Type_label.grid(row =3, column = 0)
    Category_label = Label(t2, text = 'Category: ')
    Category_label.grid(row =4, column = 0)

    submit_btn1 = Button(t2, text ='Add Vehicle ', command = insert_addVehicle)
    submit_btn1.grid(row = 7, column =0, columnspan = 2, pady = 10, padx = 10, ipadx = 140)

# Task 2.3
# Add Rental Information
# Customer input = StartDate, ReturnDate, Type, Category

def addRental():
    t1 = Toplevel(root)
    t1.geometry('500x500')
    t1.title("Book Rental")
    
    def sub():
        input_qry_btn['state'] = 'disabled'
        def show():
            
            def confirmPurchase():
                returned_val = bool_val.get()
                add_conn = sqlite3.connect('CarDB.db')
                add_cur = add_conn.cursor()
                
                def payDate(val):
                    if val == 1:
                        return orderDate
                    else:
                        return 'NULL'
                pay_date = payDate(returned_val)
                
                add_cur.execute("INSERT INTO RENTAL VALUES(:CustID, :VehicleID,:StartDate,:OrderDate,:RentalType,:Qty, :ReturnDate, :TotalAmount, :PaymentDate, :Returned)",
                                {
                                    'CustID':custID,
                                    'VehicleID': get_vin,
                                    'StartDate': start_date,
                                    'OrderDate':orderDate,
                                    'RentalType': Rental_type,
                                    'Qty':qty,
                                    'ReturnDate':return_date,
                                    'TotalAmount': total_a,
                                    'PaymentDate': pay_date,
                                    'Returned':returned_val
                                })

                add_conn.commit()
                add_conn.close()
                
                print_success_msg = Label(t1, text='Reservation Successful!', fg='#006400')
                print_success_msg.grid(row=13, columnspan = 2, pady = 10, padx = 10, ipadx = 140)
                
                
                
            
            myButton['state'] = 'disabled'
            answer = dropDown.get()
            index_num = dropDown.current()
            get_vin = records[index_num][1]
            bool_val = IntVar()

            
            Total_price_show_label = Label(t1, text='Total Amount:')
            Total_price_show_label.grid(row=10, column=0)
            total_price_text = Label(t1,text=total_a)
            total_price_text.grid(column=1, row = 10)
            
            # Checkbox to ask if want to make payment
            payment_check_label = Label(t1, text='PAY')
            payment_check_label.grid(row=11, column=0)
            payment_check_box = Checkbutton(t1, variable=bool_val)
            payment_check_box.grid(row=11, column=1)
            
            confirm_button = Button(t1, text="Confirm Purchase", command=confirmPurchase)
            confirm_button.grid(row = 12, column =0, columnspan = 2, pady = 10, padx = 10, ipadx = 140)
            
            
        
        custID = cust_id.get()
        orderDate = Order_Date.get()
        start_date = Start_Date.get()
        return_date = Return_Date.get()
        type_vehicle = Type.get()
        category_c = Category.get()

        # Returned 0 or 1 to enter in the rental table
        l1 = start_date.split('-')
        l2 = return_date.split('-')
        
        date_s = date((int)(l1[0]),(int)(l1[1]),(int)(l1[2]))
        date_e = date((int)(l2[0]),(int)(l2[1]),(int)(l2[2]))
        total_days = date_e - date_s
        
        def decideRentalType(totaldays):
            if(totaldays % 7 == 0):
                return 7
            else:
                return 1

        # The rental type to insert
        Rental_type = decideRentalType((total_days.days))
        
        def decideQty(r_type):
            if r_type == 7:
                return (int)(total_days.days/7)
            else:
                return total_days.days
            
        # The quantity to insert
        qty = decideQty(Rental_type)


        # Query for getting available vehicles
        iq = sqlite3.connect('CarDB.db')
        iq_cur = iq.cursor()
        iq_cur.execute("SELECT DISTINCT V.Description, V.VehicleID FROM VEHICLE V, RENTAL R WHERE (R.StartDate <= ? OR R.StartDate >= ?) and (R.ReturnDate < ? OR R.ReturnDate > ?) and V.Type = ? and V.Category = ? AND R.VehicleID = V.VehicleID GROUP BY V.VehicleID ", (start_date, return_date,start_date, return_date, type_vehicle,category_c))
        
        # Query for getting rates
        iq2 = sqlite3.connect('CarDB.db')
        iq_cur2 = iq2.cursor()
        iq_cur2.execute("SELECT Weekly, Daily FROM RATE WHERE Type = ? AND Category = ? ",(type_vehicle, category_c))
        
        records2 = iq_cur2.fetchone()
        
        # TotalAmount to insert in the rental
        def amount_T(rental_type):
            if rental_type == 1:
                return qty*records2[1]
            else:
                return qty*records2[0]
        total_a = amount_T(Rental_type)
        
        
        
        records = iq_cur.fetchall()
        if len(records)==0:
            print("no cars")
            t1.destroy()
        else:    
            print_records = []
            for record in records:
                print_records.append(str(record[0]))
            dropDown = ttk.Combobox(t1, value =print_records)
            dropDown.current(0)
            dropDown.grid(column=1, row=8)
            drop_down_label = Label(t1, text = 'Pick a Vehicle: ')
            drop_down_label.grid(row =8, column = 0)
     

        myButton = Button(t1, text="Select Vehicle", command=show)
        myButton.grid(row = 9, column =0, columnspan = 2, pady = 10, padx = 10, ipadx 
    = 140)
        
        iq.commit()
        iq.close()
    
    
    cust_id = Entry(t1, width=30)
    cust_id.grid(row=0, column=1, padx = 20)
    
    Order_Date = Entry(t1, width=30)
    Order_Date.grid(row=1, column=1, padx = 20)

    Start_Date = Entry(t1, width=30)
    Start_Date.grid(row=2, column=1, padx = 20)

    Return_Date = Entry(t1, width=30)
    Return_Date.grid(row=3, column=1)

    Type = Entry(t1, width=30)
    Type.grid(row=4, column=1)

    Category = Entry(t1, width=30)
    Category.grid(row=5, column=1)
    

    Customer_id_label = Label(t1, text = 'CustomerID: ')
    Customer_id_label.grid(row =0, column = 0)
    Order_date_label = Label(t1, text = 'OrderDate: ')
    Order_date_label.grid(row =1, column = 0)
    StartDate_label = Label(t1, text = 'StartDate: ')
    StartDate_label.grid(row = 2, column=0)
    Return_Date_label = Label(t1, text = 'ReturnDate: ')
    Return_Date_label.grid(row =3 , column = 0)
    Type_label = Label(t1, text = 'Type: ')
    Type_label.grid(row =4, column = 0)
    Category_label = Label(t1, text = 'Category: ')
    Category_label.grid(row =5, column = 0)


    input_qry_btn = Button(t1, text = 'Show Records', command=sub)
    input_qry_btn.grid(row = 7, column =0, columnspan = 2, pady = 10, padx = 10, ipadx 
    = 140)
    
def returnVehicle():
    
    t4 = Toplevel(root)
    t4.geometry('500x500')
    t4.title("Return Rental")

    def getRental():
    
        def paymentProcess():
            iq5 = sqlite3.connect('CarDB.db')
            iq_cur5 = iq5.cursor()
            if bool_val_2.get() == 1:
                iq_cur5.execute("UPDATE RENTAL SET Returned = 1 WHERE CustID = ? AND VehicleID = ? AND ReturnDate = ?", (total_amount[1], getVin, getReturnDate))
                
                print_success_msg = Label(t4, text='Payment Successful!', fg='#006400')
                print_success_msg.grid(row=7, columnspan = 2, pady = 10, padx = 10, ipadx = 140)
            else:
                print("Select Check Box")
                
            iq5.commit()
            iq5.close()
    
        name_customer = name.get()
        getReturnDate = returnDate.get()
        getVin = Vin.get()
        
        # Getting the rental info
        iq4 = sqlite3.connect('CarDB.db')
        iq_cur4 = iq4.cursor()
        iq_cur4.execute("SELECT TotalAmount, C.CustID FROM RENTAL R, CUSTOMER C WHERE R.CustID = C.CustID AND C.Name = ? AND VehicleID = ? AND ReturnDate = ?", (name_customer, getVin, getReturnDate))
        total_amount = iq_cur4.fetchone()

        
        balancedue_label = Label(t4, text='Total Amount:')
        balancedue_label.grid(row=4, column=0)
        balacedue_text = Label(t4,text=total_amount[0])
        balacedue_text.grid(column=1, row = 4)
        
        bool_val_2 = IntVar()
        payment_check_label = Label(t4, text='PAY')
        payment_check_label.grid(row=5, column=0)
        payment_check_box = Checkbutton(t4, variable=bool_val_2)
        payment_check_box.grid(row=5, column=1)
        
        
        MakePayment_btn = Button(t4, text = 'Make Payment', command= paymentProcess)
        MakePayment_btn.grid(row = 6, column =0, columnspan = 2, pady = 10, padx = 10, ipadx = 140)

        
        iq4.commit()
        iq4.close()
        


    name = Entry(t4, width=30)
    name.grid(row=0, column=1, padx = 20)
    
    returnDate = Entry(t4, width=30)
    returnDate.grid(row=1, column=1, padx = 20)

    Vin = Entry(t4, width=30)
    Vin.grid(row=2, column=1, padx = 20)

    name_label = Label(t4, text = 'Name: ')
    name_label.grid(row =0, column = 0)
    returnDate_label = Label(t4, text = 'ReturnDate: ')
    returnDate_label.grid(row =1, column = 0)
    Vin_label = Label(t4, text = 'VIN: ')
    Vin_label.grid(row = 2, column=0)
    

    input_qry_btn = Button(t4, text = 'Get Reservation', command= getRental)
    input_qry_btn.grid(row = 3, column =0, columnspan = 2, pady = 10, padx = 10, ipadx = 140)
    

def balanceResult():
    
    print("inside search")                
    t5 = Toplevel(root)
    t5.geometry('600x600')
    t5.title("Customer Search")
    my_tree = ttk.Treeview(t5)
    my_tree['columns'] = ("Name", "Customer ID", "Balance")
    
    my_tree.column("#0", width=0,stretch=NO)
    my_tree.column("Name", anchor=W, width=100)
    my_tree.column("Customer ID", anchor=CENTER, width=80)
    my_tree.column("Balance", anchor=W, width=100)
    
    my_tree.heading("#0", text="", anchor=W)
    my_tree.heading("Name", text="Name", anchor=W)
    my_tree.heading("Customer ID", text="Customer ID", anchor=CENTER)
    my_tree.heading("Balance", text="Balance", anchor=W)
    
    def getCustBalanceDue():
        
        for record in my_tree.get_children():
            my_tree.delete(record)
        
        name_search = name_entry.get()
        custid_search = custid_entry.get()
        iq6 = sqlite3.connect('CarDB.db')
        iq_cur6 = iq6.cursor()
        
        if len(name_search)>0:
            iq_cur6.execute("SELECT CustomerName, CustomerID, SUM(RentalBalance) FROM vRentalInfo WHERE (CustomerName = ? OR CustomerID = ? OR CustomerName LIKE ?) GROUP BY CustomerName", (name_search,custid_search,'%'+name_search+'%'))
        elif len(custid_search) > 0:
            iq_cur6.execute("SELECT CustomerName, CustomerID, SUM(RentalBalance) FROM vRentalInfo WHERE (CustomerName = ? OR CustomerID = ?)", (name_search,custid_search))
        else:
            iq_cur6.execute("SELECT CustomerName, CustomerID, SUM(RentalBalance) FROM vRentalInfo GROUP BY CustomerName ORDER BY Count(RentalBalance) DESC")
        
        
        results = iq_cur6.fetchall()
    
        for record in results:
            my_tree.insert(parent='', index='end', text = "", values=(record[0], record[1], "${:,.2f}".format(record[2])))                                                                                                                                                                                                                                                                                           
        my_tree.grid(padx=10, pady=10)
        
            
    name_entry = Entry(t5, width=30)
    name_entry.grid(row=0, column=1, padx = 20)
    
    custid_entry = Entry(t5, width=30)
    custid_entry.grid(row=1, column=1, padx = 20)
            
    custName_label = Label(t5, text="Enter Name:")
    custName_label.grid(row = 0, column=0)
    
    cust_id_label = Label(t5, text="Cust ID:")
    cust_id_label.grid(row = 1, column=0 )
    
    get_results_btn = Button(t5, text = 'Get Results', command= getCustBalanceDue)
    get_results_btn.grid(row = 2, column =0, columnspan = 2, pady = 10, padx = 10, ipadx = 140)
    

def search_vehicle():
    
    
    conn=sqlite3.connect("CarDB.Db")
    cursor=conn.cursor()            
    t6 = Toplevel(root)
    t6.geometry('800x800')
    t6.title("Vehicle Search")
    
    my_tree = ttk.Treeview(t6)
    my_tree['columns'] = ("VIN", "Description", "Daily Average")
    
    my_tree.column("#0", width=0,stretch=NO)
    my_tree.column("VIN", anchor=W, width=200)
    my_tree.column("Description", anchor=CENTER, width=200)
    my_tree.column("Daily Average", anchor=W, width=200)
    
    my_tree.heading("#0", text="", anchor=W)
    my_tree.heading("VIN", text="VIN", anchor=W)
    my_tree.heading("Description", text="Description", anchor=CENTER)
    my_tree.heading("Daily Average", text="Daily Average", anchor=W)


    def returnSelectedVehicle():
        
        for record in my_tree.get_children():
            my_tree.delete(record)
            
        getVin = Vin_entry.get().strip()
        getDescription = description_entry.get()

        if len(getVin)>0:
            cursor.execute('''SELECT VIN, VEHICLE, CAST(SUM(OrderAmount) AS FLOAT)/SUM(TotalDays) FROM vRentalInfo WHERE VIN = ?
                           UNION 
                           SELECT VehicleID, Description, 'Not Applicable' FROM VEHICLE WHERE VehicleID = ? AND VehicleID NOT IN(SELECT DISTINCT VIN FROM vRentalInfo) ORDER BY VehicleID''',([getVin, getVin]))
        
        elif len(getDescription)>0:
            cursor.execute('''SELECT VIN, VEHICLE, CAST(SUM(OrderAmount) AS FLOAT)/SUM(TotalDays) FROM vRentalInfo WHERE VEHICLE = ? OR VEHICLE LIKE ? GROUP  BY VIN
                           UNION 
                           SELECT VehicleID, Description, 'Not Applicable' FROM VEHICLE WHERE Description = ? OR Description LIKE ? AND VehicleID NOT IN(SELECT DISTINCT VIN FROM vRentalInfo) ORDER BY VehicleID''', (getDescription, '%'+ getDescription+'%', getDescription, '%'+ getDescription+'%' ))
        else:
            cursor.execute('''SELECT VIN, VEHICLE, CAST(SUM(OrderAmount) AS FLOAT)/SUM(TotalDays) FROM vRentalInfo GROUP BY VIN
                           UNION 
                           SELECT VehicleID, Description, 'Not Applicable' AS Average_price FROM VEHICLE WHERE VehicleID NOT IN(SELECT DISTINCT VIN FROM vRentalInfo) ORDER BY Average_price''')
            
        
        results = cursor.fetchall()
        
        myList = []
        for i in results:
            myList.append(i[2])
         
        for i in range(0, len(myList)):
            if type(myList[i])==float:
                answer = myList[i]
                myList[i] = '$' + str(round(answer, 2))
        
        for i in range(0, len(results)):
            my_tree.insert(parent='', index='end', text = "", values=(results[i][0], results[i][1], myList[i]))                                                                                                                                                                                                                                                                                                                                                                                                                    
        my_tree.grid(padx=10, pady=10)
  
    Vin_entry = Entry(t6, width=30)
    Vin_entry.grid(row=0, column=1, padx = 20)
    
    description_entry = Entry(t6, width=30)
    description_entry.grid(row=1, column=1, padx = 20)
            
    Vin_label = Label(t6, text="Enter VIN:")
    Vin_label.grid(row = 0, column=0)
    
    description_label = Label(t6, text="Enter Description:")
    description_label.grid(row = 1, column=0 )
    
    search_vehicle_btn= Button(t6, text = 'Search Vehicle', command= returnSelectedVehicle)
    search_vehicle_btn.grid(row = 2, column =0, columnspan = 2, pady = 10, padx = 10, ipadx = 140)
    

customer_add_btn = Button(root, text="Add New Customer", command=CustomerF)
customer_add_btn.grid(row = 0, column=0, padx=10, pady=10)

add_vehicle_btn = Button(root, text="Add New Vehicle", command=addVehicle)
add_vehicle_btn.grid(row = 1, column=0, padx=10, pady=10)

rental_book_btn = Button(root, text="Book Rental", command=addRental)
rental_book_btn.grid(row = 2, column=0, padx=10, pady=10)

handle_return_button = Button(root, text="Return Vehicle", command=returnVehicle)
handle_return_button.grid(row=3, column=0, padx=10,pady=10)

search_name_button = Button(root, text="Search by Customer", command=balanceResult)
search_name_button.grid(row=4, column=0, padx=10,pady=10)

search_vehicle_id = Button(root, text = "Search by Vehicle ", command=search_vehicle)
search_vehicle_id.grid(row=5, column=0, padx=10, pady=10)



root.mainloop()


