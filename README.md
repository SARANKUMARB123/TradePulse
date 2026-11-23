
# 📈 TradePulse – Real-Time Order Book & Trade Matching Engine

## Project Overview

TradePulse is a console-based **Real-Time Order Book & Trade Matching Engine** developed as an incremental capstone project. The application simulates the backend of a stock trading platform where traders can place buy and sell orders, maintain an order book, and execute trades based on **Price-Time Priority**.

The project focuses on backend development using **Python** and **Microsoft SQL Server**, without a graphical user interface or external APIs.

---

# Project Objectives

- Design a normalized relational database.
- Maintain trader and instrument information.
- Store and manage buy/sell orders.
- Simulate a real-time order book.
- Execute trades using a matching engine.
- Record trade history.
- Demonstrate database design, SQL programming, and Python integration.

---

# Technology Stack

| Technology | Purpose |
|------------|---------|
| Python | Console Application |
| SQL Server | Relational Database |
| SQL Server Management Studio (SSMS) | Database Management |
| pyodbc | Python-SQL Server Connectivity |
| Git & GitHub | Version Control |

---

# Database Name

```
TradePulseDB
```

---

# Database Tables

## 1. Trader

Stores trader information.

**Attributes**

- TraderID
- FirstName
- LastName
- AccountBalance

---

## 2. Instrument

Stores tradable financial instruments.

**Attributes**

- InstrumentID
- Symbol
- CompanyName
- TradingStatus

---

## 3. Order

Stores every buy and sell order submitted by traders.

**Attributes**

- OrderID
- TraderID
- InstrumentID
- Side
- OrderType
- Price
- Quantity
- RemainingQuantity
- SubmittedAt
- Status

---

## 4. Trade

Stores successfully executed trades.

**Attributes**

- TradeID
- BuyOrderID
- SellOrderID
- InstrumentID
- Price
- Quantity
- ExecutedAt

---

## 5. PriceLevel

Maintains market depth for each instrument.

**Attributes**

- LevelID
- InstrumentID
- Side
- Price
- TotalQuantity

---

# Database Features

- Primary Keys
- Foreign Keys
- CHECK Constraints
- DEFAULT Constraints
- UNIQUE Constraints
- Identity Columns
- Optimized Indexes
- Normalized Database Design (3NF)

---

# Core Functionalities

- Trader Management
- Instrument Management
- Buy Order Placement
- Sell Order Placement
- Order Book Management
- Trade Matching
- Trade History
- Market Depth Display

---

# Order Matching Logic

TradePulse follows the **Price-Time Priority** algorithm.

### Buy Orders

- Higher price receives higher priority.
- If prices are equal, the earliest order is executed first.

### Sell Orders

- Lower price receives higher priority.
- If prices are equal, the earliest order is executed first.

---

# Project Workflow

```
Trader
    │
    ▼
Place Buy / Sell Order
    │
    ▼
Store Order in SQL Server
    │
    ▼
Matching Engine
    │
    ▼
Trade Executed
    │
    ▼
Update Order Book
    │
    ▼
Store Trade History
```

---

# Project Structure

```
TradePulse
│
├── database
│   ├── 01_Database.sql
│   ├── 02_Trader.sql
│   ├── 03_Instrument.sql
│   ├── 04_Order.sql
│   ├── 05_Trade.sql
│   └── 06_PriceLevel.sql
│
├── python
│   ├── main.py
│   ├── db_connection.py
│   ├── trader.py
│   ├── instrument.py
│   ├── order.py
│   ├── trade.py
│   └── matching_engine.py
│
└── README.md
```

---

# Future Enhancements

- User Authentication
- Portfolio Management
- Wallet Management
- Order Cancellation
- Stop-Loss Orders
- Market Orders
- Limit Orders
- Performance Analytics
- Trade Reports
- REST API Integration
- Web-Based Dashboard
- Live Market Data Integration

---

# Learning Outcomes

Through this project, the following concepts are implemented and demonstrated:

- Database Design
- Relational Database Management
- SQL Server
- Normalization
- Constraints
- Indexing
- Python Database Connectivity
- Object-Oriented Programming
- Order Book Management
- Trade Matching Algorithms
- Console-Based Application Development

---

# Developed By

**SARANKUMAR B**

B.E. Computer Science and Engineering

Incremental Capstone Project

Hexaware Foundation Training Program

2026
