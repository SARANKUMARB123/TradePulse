# TradePulseDB

**Real-Time Order Book & Trade Matching Engine — Database Layer**

A normalized SQL Server database built for **TradePulse**, the real-time backend for Meridian Capital Markets. This repository contains the complete database creation script, sample data, and verification queries for Sprint 1 (Database).

---

## Table of Contents

1. [Overview](#overview)
2. [Tech Stack](#tech-stack)
3. [Schema Design](#schema-design)
4. [Entity Relationships](#entity-relationships)
5. [Constraints & Indexes](#constraints--indexes)
6. [Sample Data](#sample-data)
7. [How to Run](#how-to-run)
8. [Verification](#verification)
9. [Design Decisions](#design-decisions)
10. [Issues Encountered & Fixes](#issues-encountered--fixes)
11. [Deliverables Checklist](#deliverables-checklist)
12. [Project Structure](#project-structure)

---

## Overview

TradePulseDB stores all data required by the TradePulse matching engine:

- **Traders** who place orders
- **Instruments** (equities) that are traded
- **Orders** submitted by traders
- **Trades** executed when a buy and sell order match
- **PriceLevels** representing aggregated depth on each side of the book

The database enforces strict referential integrity through primary keys, foreign keys, unique constraints, check constraints, and indexes — so the matching engine can rely on clean, consistent data at all times.

---

## Tech Stack

| Component | Choice |
|---|---|
| Database | Microsoft SQL Server (2019 / 2022 / Azure SQL) |
| Script language | T-SQL |
| Timestamp precision | `DATETIME2(6)` — microsecond precision |
| Money type | `DECIMAL(15,2)` for balances, `DECIMAL(12,4)` for prices |
| Auto-generated keys | `INT IDENTITY(1,1)` / `BIGINT IDENTITY(1,1)` |

---

## Schema Design

The database contains **5 tables**, created in dependency order (parents first, children after):

| # | Table | Purpose |
|---|---|---|
| 1 | `Trader` | Registered traders and their account balances |
| 2 | `Instrument` | Tradeable equities and their trading status |
| 3 | `Order` | Buy/Sell orders submitted by traders |
| 4 | `Trade` | Executed matches between a buy order and a sell order |
| 5 | `PriceLevel` | Aggregated quantity available at each price on each side |

### Column Definitions

#### `Trader`

| Column | Type | Constraints |
|---|---|---|
| `TraderID` | `INT IDENTITY(1,1)` | **PK**, auto-generated |
| `FirstName` | `NVARCHAR(50)` | NOT NULL |
| `LastName` | `NVARCHAR(50)` | NOT NULL |
| `AccountBalance` | `DECIMAL(15,2)` | NOT NULL, CHECK ≥ 0 |

#### `Instrument`

| Column | Type | Constraints |
|---|---|---|
| `InstrumentID` | `INT IDENTITY(1,1)` | **PK**, auto-generated |
| `Symbol` | `NVARCHAR(10)` | NOT NULL, **UNIQUE** |
| `CompanyName` | `NVARCHAR(100)` | NOT NULL |
| `TradingStatus` | `NVARCHAR(20)` | DEFAULT `'Open'`, CHECK IN (`Open`,`Closed`,`Halted`) |

#### `Order`

| Column | Type | Constraints |
|---|---|---|
| `OrderID` | `BIGINT IDENTITY(1,1)` | **PK**, auto-generated |
| `TraderID` | `INT` | **FK → Trader.TraderID** |
| `InstrumentID` | `INT` | **FK → Instrument.InstrumentID** |
| `Side` | `NVARCHAR(4)` | CHECK IN (`Buy`,`Sell`) |
| `OrderType` | `NVARCHAR(10)` | CHECK IN (`Market`,`Limit`,`Stop`,`StopLimit`) |
| `Price` | `DECIMAL(12,4)` | CHECK ≥ 0 |
| `Quantity` | `INT` | CHECK > 0 |
| `RemainingQuantity` | `INT` | CHECK 0 ≤ RemainingQuantity ≤ Quantity |
| `SubmittedAt` | `DATETIME2(6)` | DEFAULT `SYSUTCDATETIME()` |
| `Status` | `NVARCHAR(20)` | DEFAULT `'Open'`, CHECK IN (`Open`,`PartiallyFilled`,`Filled`,`Cancelled`,`Rejected`) |

#### `Trade`

| Column | Type | Constraints |
|---|---|---|
| `TradeID` | `BIGINT IDENTITY(1,1)` | **PK**, auto-generated |
| `BuyOrderID` | `BIGINT` | **FK → Order.OrderID** |
| `SellOrderID` | `BIGINT` | **FK → Order.OrderID** |
| `InstrumentID` | `INT` | **FK → Instrument.InstrumentID** |
| `Price` | `DECIMAL(12,4)` | CHECK ≥ 0 |
| `Quantity` | `INT` | CHECK > 0 |
| `ExecutedAt` | `DATETIME2(6)` | DEFAULT `SYSUTCDATETIME()` |

#### `PriceLevel`

| Column | Type | Constraints |
|---|---|---|
| `LevelID` | `INT IDENTITY(1,1)` | **PK**, auto-generated |
| `InstrumentID` | `INT` | **FK → Instrument.InstrumentID** |
| `Side` | `NVARCHAR(4)` | CHECK IN (`Buy`,`Sell`) |
| `Price` | `DECIMAL(12,4)` | CHECK ≥ 0 |
| `TotalQuantity` | `INT` | CHECK ≥ 0 |

---

## Entity Relationships

| # | From | To | Cardinality | FK Column |
|---|---|---|---|---|
| 1 | `Trader` | `Order` | 1 : N | `Order.TraderID` |
| 2 | `Instrument` | `Order` | 1 : N | `Order.InstrumentID` |
| 3 | `Order` | `Trade` (buy side) | 1 : N | `Trade.BuyOrderID` |
| 4 | `Order` | `Trade` (sell side) | 1 : N | `Trade.SellOrderID` |
| 5 | `Instrument` | `Trade` | 1 : N | `Trade.InstrumentID` |
| 6 | `Instrument` | `PriceLevel` | 1 : N | `PriceLevel.InstrumentID` |

> **Note:** `Order` connects to `Trade` **twice** — once as the buy side, once as the sell side. Two foreign keys (`BuyOrderID` and `SellOrderID`) model this correctly.

