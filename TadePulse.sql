
/*
-- 1. Create the database
IF DB_ID('TradePulseDB') IS NOT NULL
BEGIN
    ALTER DATABASE TradePulseDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TradePulseDB;
END
GO

CREATE DATABASE TradePulseDB;
GO
USE TradePulseDB;
GO


 --  02. TRADER TABLE

CREATE TABLE Trader
(
    TraderID       INT IDENTITY(1,1) NOT NULL,
    FirstName      NVARCHAR(50)      NOT NULL,
    LastName       NVARCHAR(50)      NOT NULL,
    AccountBalance DECIMAL(15,2)     NOT NULL,
    CONSTRAINT PK_Trader PRIMARY KEY (TraderID),
    CONSTRAINT CK_Trader_AccountBalance CHECK (AccountBalance >= 0)
);
GO

--   3. INSTRUMENT TABLE

CREATE TABLE Instrument
(
    InstrumentID   INT IDENTITY(1,1) NOT NULL,
    Symbol         NVARCHAR(10)      NOT NULL,
    CompanyName    NVARCHAR(100)     NOT NULL,
    TradingStatus  NVARCHAR(20)      NOT NULL CONSTRAINT DF_Instrument_TradingStatus DEFAULT 'Open',
    CONSTRAINT PK_Instrument PRIMARY KEY (InstrumentID),
    CONSTRAINT UQ_Instrument_Symbol UNIQUE (Symbol),
    CONSTRAINT CK_Instrument_TradingStatus CHECK (TradingStatus IN ('Open','Closed','Halted'))
);
GO


--   4. ORDER TABLE

CREATE TABLE [Order]
(
    OrderID           BIGINT IDENTITY(1,1) NOT NULL,
    TraderID          INT                  NOT NULL,
    InstrumentID      INT                  NOT NULL,
    Side              NVARCHAR(4)          NOT NULL,
    OrderType         NVARCHAR(10)         NOT NULL,
    Price             DECIMAL(12,4)        NOT NULL,
    Quantity          INT                  NOT NULL,
    RemainingQuantity INT                  NOT NULL,
    SubmittedAt       DATETIME2(6)         NOT NULL CONSTRAINT DF_Order_SubmittedAt DEFAULT SYSUTCDATETIME(),
    Status            NVARCHAR(20)         NOT NULL CONSTRAINT DF_Order_Status DEFAULT 'Open',
    CONSTRAINT PK_Order PRIMARY KEY (OrderID),
    CONSTRAINT FK_Order_Trader     FOREIGN KEY (TraderID)     REFERENCES Trader(TraderID),
    CONSTRAINT FK_Order_Instrument FOREIGN KEY (InstrumentID) REFERENCES Instrument(InstrumentID),
    CONSTRAINT CK_Order_Side          CHECK (Side IN ('Buy','Sell')),
    CONSTRAINT CK_Order_OrderType     CHECK (OrderType IN ('Market','Limit','Stop','StopLimit')),
    CONSTRAINT CK_Order_Quantity      CHECK (Quantity > 0),
    CONSTRAINT CK_Order_RemainingQty  CHECK (RemainingQuantity >= 0 AND RemainingQuantity <= Quantity),
    CONSTRAINT CK_Order_Price         CHECK (Price >= 0),
    CONSTRAINT CK_Order_Status        CHECK (Status IN ('Open','PartiallyFilled','Filled','Cancelled','Rejected'))
);

CREATE INDEX IX_Order_Instrument_Side_Price
    ON [Order] (InstrumentID, Side, Price);
GO


  -- 5. TRADE TABLE
  
CREATE TABLE Trade
(
    TradeID       BIGINT IDENTITY(1,1) NOT NULL,
    BuyOrderID    BIGINT               NOT NULL,
    SellOrderID   BIGINT               NOT NULL,
    InstrumentID  INT                  NOT NULL,
    Price         DECIMAL(12,4)        NOT NULL,
    Quantity      INT                  NOT NULL,
    ExecutedAt    DATETIME2(6)         NOT NULL CONSTRAINT DF_Trade_ExecutedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Trade PRIMARY KEY (TradeID),
    CONSTRAINT FK_Trade_BuyOrder    FOREIGN KEY (BuyOrderID)    REFERENCES [Order](OrderID),
    CONSTRAINT FK_Trade_SellOrder   FOREIGN KEY (SellOrderID)   REFERENCES [Order](OrderID),
    CONSTRAINT FK_Trade_Instrument  FOREIGN KEY (InstrumentID)  REFERENCES Instrument(InstrumentID),
    CONSTRAINT CK_Trade_Quantity    CHECK (Quantity > 0),
    CONSTRAINT CK_Trade_Price       CHECK (Price >= 0),
    CONSTRAINT CK_Trade_DifferentOrders CHECK (BuyOrderID <> SellOrderID)
);
GO

--   6. PRICELEVEL TABLE

CREATE TABLE PriceLevel
(
    LevelID       INT IDENTITY(1,1) NOT NULL,
    InstrumentID  INT               NOT NULL,
    Side          NVARCHAR(4)       NOT NULL,
    Price         DECIMAL(12,4)     NOT NULL,
    TotalQuantity INT               NOT NULL,
    CONSTRAINT PK_PriceLevel PRIMARY KEY (LevelID),
    CONSTRAINT FK_PriceLevel_Instrument FOREIGN KEY (InstrumentID) REFERENCES Instrument(InstrumentID),
    CONSTRAINT CK_PriceLevel_Side     CHECK (Side IN ('Buy','Sell')),
    CONSTRAINT CK_PriceLevel_Price    CHECK (Price >= 0),
    CONSTRAINT CK_PriceLevel_Qty      CHECK (TotalQuantity >= 0)
);

CREATE INDEX IX_PriceLevel_Instrument_Side_Price
    ON PriceLevel (InstrumentID, Side, Price);
GO

 --  7. SAMPLE DATA - TRADERS (50 rows)

SET IDENTITY_INSERT Trader ON;

INSERT INTO Trader (TraderID, FirstName, LastName, AccountBalance) VALUES
(1,  'Arjun',    'Mehta',    1500000.00),
(2,  'Priya',    'Sharma',   2750000.50),
(3,  'Rahul',    'Verma',     980000.75),
(4,  'Sneha',    'Iyer',     3200000.00),
(5,  'Vikram',   'Nair',      750000.25),
(6,  'Ananya',   'Reddy',    4100000.00),
(7,  'Karan',    'Patel',     625000.00),
(8,  'Meera',    'Krishnan', 1850000.10),
(9,  'Rohit',    'Gupta',     540000.60),
(10, 'Divya',    'Menon',    2950000.90),
(11, 'Sanjay',   'Kulkarni', 1200000.00),
(12, 'Lakshmi',  'Rao',      3800000.00),
(13, 'Amit',     'Joshi',     860000.40),
(14, 'Pooja',    'Desai',    2250000.00),
(15, 'Nikhil',   'Bhat',      430000.15),
(16, 'Ritika',   'Singh',    1750000.00),
(17, 'Suresh',   'Pillai',   2650000.80),
(18, 'Kavya',    'Subramanian', 3100000.00),
(19, 'Manoj',    'Agarwal',   690000.00),
(20, 'Neha',     'Kapoor',   1480000.45),
(21, 'Ashwin',   'Kamath',   5200000.00),
(22, 'Deepa',    'Varghese', 1130000.00),
(23, 'Gaurav',   'Trivedi',   395000.60),
(24, 'Shruti',   'Bose',     2450000.00),
(25, 'Ravi',     'Chandran', 1820000.00),
(26, 'Anjali',   'Mishra',    925000.00),
(27, 'Varun',    'Sinha',    3050000.75),
(28, 'Tanya',    'Chopra',    780000.00),
(29, 'Harsh',    'Bansal',   4950000.00),
(30, 'Ishita',   'Ghosh',    1560000.00),
(31, 'Prashant', 'Kumar',     875000.30),
(32, 'Rupali',   'Jain',     2700000.00),
(33, 'Sameer',   'Shaikh',   1350000.00),
(34, 'Vidya',    'Hegde',     645000.00),
(35, 'Anil',     'Deshmukh', 3450000.00),
(36, 'Bhavna',   'Shetty',   2150000.00),
(37, 'Chetan',   'Prabhu',    555000.00),
(38, 'Dhruv',    'Malhotra', 4750000.00),
(39, 'Esha',     'Arora',    1020000.00),
(40, 'Farhan',   'Qureshi',  2280000.00),
(41, 'Gita',     'Shenoy',    815000.00),
(42, 'Hemant',   'Pawar',    3640000.00),
(43, 'Ira',      'Trivedi',  1485000.00),
(44, 'Jatin',    'Sodhi',    2760000.00),
(45, 'Kirti',    'Bhatia',    690000.00),
(46, 'Lalit',    'Yadav',    1900000.00),
(47, 'Madhuri',  'Pillai',   2510000.00),
(48, 'Naveen',   'Rajan',     830000.00),
(49, 'Ojas',     'Khandelwal', 4100000.00),
(50, 'Pallavi',  'Nambiar',  1670000.00);

SET IDENTITY_INSERT Trader OFF;
GO

--   8. SAMPLE DATA - INSTRUMENTS (50 rows)

SET IDENTITY_INSERT Instrument ON;

INSERT INTO Instrument (InstrumentID, Symbol, CompanyName, TradingStatus) VALUES
(1,  'AAPL',  'Apple Inc.',                        'Open'),
(2,  'MSFT',  'Microsoft Corporation',             'Open'),
(3,  'GOOGL', 'Alphabet Inc.',                     'Open'),
(4,  'AMZN',  'Amazon.com Inc.',                   'Open'),
(5,  'TSLA',  'Tesla Inc.',                        'Open'),
(6,  'META',  'Meta Platforms Inc.',               'Open'),
(7,  'NVDA',  'NVIDIA Corporation',                'Open'),
(8,  'NFLX',  'Netflix Inc.',                      'Open'),
(9,  'ORCL',  'Oracle Corporation',                'Open'),
(10, 'CRM',   'Salesforce Inc.',                   'Open'),
(11, 'INTC',  'Intel Corporation',                 'Open'),
(12, 'AMD',   'Advanced Micro Devices Inc.',       'Open'),
(13, 'IBM',   'IBM Corporation',                   'Open'),
(14, 'CSCO',  'Cisco Systems Inc.',                'Open'),
(15, 'ADBE',  'Adobe Inc.',                        'Open'),
(16, 'PYPL',  'PayPal Holdings Inc.',              'Open'),
(17, 'AVGO',  'Broadcom Inc.',                     'Open'),
(18, 'QCOM',  'Qualcomm Inc.',                     'Open'),
(19, 'TXN',   'Texas Instruments Inc.',            'Open'),
(20, 'AMAT',  'Applied Materials Inc.',            'Open'),
(21, 'JPM',   'JPMorgan Chase & Co.',              'Open'),
(22, 'BAC',   'Bank of America Corp.',             'Open'),
(23, 'WFC',   'Wells Fargo & Co.',                 'Open'),
(24, 'C',     'Citigroup Inc.',                    'Open'),
(25, 'GS',    'Goldman Sachs Group Inc.',          'Open'),
(26, 'MS',    'Morgan Stanley',                    'Open'),
(27, 'V',     'Visa Inc.',                         'Open'),
(28, 'MA',    'Mastercard Inc.',                   'Open'),
(29, 'AXP',   'American Express Co.',              'Open'),
(30, 'BLK',   'BlackRock Inc.',                    'Open'),
(31, 'JNJ',   'Johnson & Johnson',                 'Open'),
(32, 'PFE',   'Pfizer Inc.',                       'Open'),
(33, 'MRK',   'Merck & Co. Inc.',                  'Open'),
(34, 'ABT',   'Abbott Laboratories',               'Open'),
(35, 'TMO',   'Thermo Fisher Scientific Inc.',     'Open'),
(36, 'WMT',   'Walmart Inc.',                      'Open'),
(37, 'COST',  'Costco Wholesale Corp.',            'Open'),
(38, 'TGT',   'Target Corporation',                'Open'),
(39, 'HD',    'Home Depot Inc.',                   'Open'),
(40, 'LOW',   'Lowe's Companies Inc.',             'Open'),
(41, 'KO',    'Coca-Cola Company',                 'Open'),
(42, 'PEP',   'PepsiCo Inc.',                      'Open'),
(43, 'MCD',   'McDonald's Corporation',            'Open'),
(44, 'SBUX',  'Starbucks Corporation',             'Open'),
(45, 'NKE',   'Nike Inc.',                         'Open'),
(46, 'DIS',   'Walt Disney Company',               'Open'),
(47, 'CMCSA', 'Comcast Corporation',               'Open'),
(48, 'VZ',    'Verizon Communications Inc.',       'Open'),
(49, 'T',     'AT&T Inc.',                         'Open'),
(50, 'TMUS',  'T-Mobile US Inc.',                  'Open');

SET IDENTITY_INSERT Instrument OFF;
GO


--   9. SAMPLE DATA - ORDERS (50 rows)
--   Mix of Buy/Sell, Limit/Market, all linked to valid traders/instruments

SET IDENTITY_INSERT [Order] ON;

INSERT INTO [Order] (OrderID, TraderID, InstrumentID, Side, OrderType, Price, Quantity, RemainingQuantity, SubmittedAt, Status) VALUES
(1,  1,  1,  'Buy',  'Limit',  150.0000, 100, 100, '2026-01-15 09:30:00.123456', 'Open'),
(2,  2,  1,  'Sell', 'Limit',  152.0000, 150, 150, '2026-01-15 09:30:01.234567', 'Open'),
(3,  3,  2,  'Buy',  'Market', 0.0000,   200, 200, '2026-01-15 09:30:02.345678', 'Open'),
(4,  4,  2,  'Sell', 'Limit',  250.5000, 300, 300, '2026-01-15 09:30:03.456789', 'Open'),
(5,  5,  3,  'Buy',  'Limit',  120.0000, 50,  50,  '2026-01-15 09:30:04.567890', 'Open'),
(6,  6,  3,  'Sell', 'Limit',  125.0000, 75,  75,  '2026-01-15 09:30:05.678901', 'Open'),
(7,  7,  4,  'Buy',  'Limit',  180.2500, 120, 120, '2026-01-15 09:30:06.789012', 'Open'),
(8,  8,  4,  'Sell', 'Limit',  182.5000, 200, 200, '2026-01-15 09:30:07.890123', 'Open'),
(9,  9,  5,  'Buy',  'Limit',  300.0000, 80,  80,  '2026-01-15 09:30:08.901234', 'Open'),
(10, 10, 5,  'Sell', 'Limit',  305.0000, 100, 100, '2026-01-15 09:30:09.012345', 'Open'),
(11, 11, 6,  'Buy',  'Limit',  400.0000, 60,  60,  '2026-01-15 09:30:10.123456', 'Open'),
(12, 12, 6,  'Sell', 'Limit',  405.0000, 90,  90,  '2026-01-15 09:30:11.234567', 'Open'),
(13, 13, 7,  'Buy',  'Limit',  950.0000, 40,  40,  '2026-01-15 09:30:12.345678', 'Open'),
(14, 14, 7,  'Sell', 'Limit',  960.0000, 55,  55,  '2026-01-15 09:30:13.456789', 'Open'),
(15, 15, 8,  'Buy',  'Limit',  600.0000, 70,  70,  '2026-01-15 09:30:14.567890', 'Open'),
(16, 16, 8,  'Sell', 'Limit',  610.0000, 85,  85,  '2026-01-15 09:30:15.678901', 'Open'),
(17, 17, 9,  'Buy',  'Limit',  85.0000,  500, 500, '2026-01-15 09:30:16.789012', 'Open'),
(18, 18, 9,  'Sell', 'Limit',  87.0000,  600, 600, '2026-01-15 09:30:17.890123', 'Open'),
(19, 19, 10, 'Buy',  'Limit',  220.0000, 90,  90,  '2026-01-15 09:30:18.901234', 'Open'),
(20, 20, 10, 'Sell', 'Limit',  225.0000, 110, 110, '2026-01-15 09:30:19.012345', 'Open'),
(21, 21, 11, 'Buy',  'Limit',  45.0000,  1000, 1000, '2026-01-15 09:30:20.123456', 'Open'),
(22, 22, 11, 'Sell', 'Limit',  46.0000,  1200, 1200, '2026-01-15 09:30:21.234567', 'Open'),
(23, 23, 12, 'Buy',  'Limit',  120.0000, 300, 300, '2026-01-15 09:30:22.345678', 'Open'),
(24, 24, 12, 'Sell', 'Limit',  122.5000, 400, 400, '2026-01-15 09:30:23.456789', 'Open'),
(25, 25, 13, 'Buy',  'Limit',  140.0000, 150, 150, '2026-01-15 09:30:24.567890', 'Open'),
(26, 26, 13, 'Sell', 'Limit',  142.0000, 200, 200, '2026-01-15 09:30:25.678901', 'Open'),
(27, 27, 14, 'Buy',  'Limit',  55.0000,  700, 700, '2026-01-15 09:30:26.789012', 'Open'),
(28, 28, 14, 'Sell', 'Limit',  56.5000,  800, 800, '2026-01-15 09:30:27.890123', 'Open'),
(29, 29, 15, 'Buy',  'Limit',  500.0000, 100, 100, '2026-01-15 09:30:28.901234', 'Open'),
(30, 30, 15, 'Sell', 'Limit',  510.0000, 120, 120, '2026-01-15 09:30:29.012345', 'Open'),
(31, 31, 16, 'Buy',  'Limit',  75.0000,  400, 400, '2026-01-15 09:30:30.123456', 'Open'),
(32, 32, 16, 'Sell', 'Limit',  77.0000,  500, 500, '2026-01-15 09:30:31.234567', 'Open'),
(33, 33, 17, 'Buy',  'Limit',  850.0000, 60,  60,  '2026-01-15 09:30:32.345678', 'Open'),
(34, 34, 17, 'Sell', 'Limit',  860.0000, 80,  80,  '2026-01-15 09:30:33.456789', 'Open'),
(35, 35, 18, 'Buy',  'Limit',  140.0000, 200, 200, '2026-01-15 09:30:34.567890', 'Open'),
(36, 36, 18, 'Sell', 'Limit',  143.0000, 250, 250, '2026-01-15 09:30:35.678901', 'Open'),
(37, 37, 19, 'Buy',  'Limit',  175.0000, 180, 180, '2026-01-15 09:30:36.789012', 'Open'),
(38, 38, 19, 'Sell', 'Limit',  178.0000, 220, 220, '2026-01-15 09:30:37.890123', 'Open'),
(39, 39, 20, 'Buy',  'Limit',  130.0000, 300, 300, '2026-01-15 09:30:38.901234', 'Open'),
(40, 40, 20, 'Sell', 'Limit',  132.0000, 350, 350, '2026-01-15 09:30:39.012345', 'Open'),
(41, 41, 21, 'Buy',  'Limit',  155.0000, 500, 500, '2026-01-15 09:30:40.123456', 'Open'),
(42, 42, 21, 'Sell', 'Limit',  157.5000, 600, 600, '2026-01-15 09:30:41.234567', 'Open'),
(43, 43, 22, 'Buy',  'Limit',  35.0000,  1500, 1500, '2026-01-15 09:30:42.345678', 'Open'),
(44, 44, 22, 'Sell', 'Limit',  36.0000,  1800, 1800, '2026-01-15 09:30:43.456789', 'Open'),
(45, 45, 23, 'Buy',  'Limit',  48.0000,  900, 900, '2026-01-15 09:30:44.567890', 'Open'),
(46, 46, 23, 'Sell', 'Limit',  49.5000,  1000, 1000, '2026-01-15 09:30:45.678901', 'Open'),
(47, 47, 24, 'Buy',  'Limit',  55.0000,  600, 600, '2026-01-15 09:30:46.789012', 'Open'),
(48, 48, 24, 'Sell', 'Limit',  56.0000,  700, 700, '2026-01-15 09:30:47.890123', 'Open'),
(49, 49, 25, 'Buy',  'Limit',  380.0000, 100, 100, '2026-01-15 09:30:48.901234', 'Open'),
(50, 50, 25, 'Sell', 'Limit',  385.0000, 150, 150, '2026-01-15 09:30:49.012345', 'Open');

SET IDENTITY_INSERT [Order] OFF;
GO

/* 10. SAMPLE DATA - TRADES (50 rows)
   Each trade pairs a Buy order with a Sell order on the SAME instrument.
   We use orders 1..50; for a valid trade, we need a Buy order and a Sell
   order for the same InstrumentID. Since orders 1,2 are both instrument 1
   (one Buy one Sell), etc., we pair them as (Buy=odd, Sell=even).*/

SET IDENTITY_INSERT Trade ON;

INSERT INTO Trade (TradeID, BuyOrderID, SellOrderID, InstrumentID, Price, Quantity, ExecutedAt) VALUES
(1,  1,  2,  1,  151.0000, 100, '2026-01-15 09:31:00.111111'),
(2,  3,  4,  2,  250.5000, 200, '2026-01-15 09:31:01.222222'),
(3,  5,  6,  3,  122.5000, 50,  '2026-01-15 09:31:02.333333'),
(4,  7,  8,  4,  181.3750, 120, '2026-01-15 09:31:03.444444'),
(5,  9,  10, 5,  302.5000, 80,  '2026-01-15 09:31:04.555555'),
(6,  11, 12, 6,  402.5000, 60,  '2026-01-15 09:31:05.666666'),
(7,  13, 14, 7,  955.0000, 40,  '2026-01-15 09:31:06.777777'),
(8,  15, 16, 8,  605.0000, 70,  '2026-01-15 09:31:07.888888'),
(9,  17, 18, 9,  86.0000,  500, '2026-01-15 09:31:08.999999'),
(10, 19, 20, 10, 222.5000, 90,  '2026-01-15 09:31:09.101010'),
(11, 21, 22, 11, 45.5000,  1000,'2026-01-15 09:31:10.202020'),
(12, 23, 24, 12, 121.2500, 300, '2026-01-15 09:31:11.303030'),
(13, 25, 26, 13, 141.0000, 150, '2026-01-15 09:31:12.404040'),
(14, 27, 28, 14, 55.7500,  700, '2026-01-15 09:31:13.505050'),
(15, 29, 30, 15, 505.0000, 100, '2026-01-15 09:31:14.606060'),
(16, 31, 32, 16, 76.0000,  400, '2026-01-15 09:31:15.707070'),
(17, 33, 34, 17, 855.0000, 60,  '2026-01-15 09:31:16.808080'),
(18, 35, 36, 18, 141.5000, 200, '2026-01-15 09:31:17.909090'),
(19, 37, 38, 19, 176.5000, 180, '2026-01-15 09:31:18.010101'),
(20, 39, 40, 20, 131.0000, 300, '2026-01-15 09:31:19.111111'),
(21, 41, 42, 21, 156.2500, 500, '2026-01-15 09:31:20.212121'),
(22, 43, 44, 22, 35.5000,  1500,'2026-01-15 09:31:21.313131'),
(23, 45, 46, 23, 48.7500,  900, '2026-01-15 09:31:22.414141'),
(24, 47, 48, 24, 55.5000,  600, '2026-01-15 09:31:23.515151'),
(25, 49, 50, 25, 382.5000, 100, '2026-01-15 09:31:24.616161'),
-- Additional trades reusing existing open orders (valid FKs) on instruments 1..25
(26, 1,  4,  2,  250.5000, 50,  '2026-01-15 09:31:25.717171'),
(27, 3,  6,  3,  122.5000, 75,  '2026-01-15 09:31:26.818181'),
(28, 5,  8,  4,  181.3750, 50,  '2026-01-15 09:31:27.919191'),
(29, 7,  10, 5,  302.5000, 80,  '2026-01-15 09:31:28.020202'),
(30, 9,  12, 6,  402.5000, 60,  '2026-01-15 09:31:29.121212'),
(31, 11, 14, 7,  955.0000, 40,  '2026-01-15 09:31:30.222222'),
(32, 13, 16, 8,  605.0000, 55,  '2026-01-15 09:31:31.323232'),
(33, 15, 18, 9,  86.0000,  70,  '2026-01-15 09:31:32.424242'),
(34, 17, 20, 10, 222.5000, 90,  '2026-01-15 09:31:33.525252'),
(35, 19, 22, 11, 45.5000,  90,  '2026-01-15 09:31:34.626262'),
(36, 21, 24, 12, 121.2500, 300, '2026-01-15 09:31:35.727272'),
(37, 23, 26, 13, 141.0000, 150, '2026-01-15 09:31:36.828282'),
(38, 25, 28, 14, 55.7500,  150, '2026-01-15 09:31:37.929292'),
(39, 27, 30, 15, 505.0000, 100, '2026-01-15 09:31:38.030303'),
(40, 29, 32, 16, 76.0000,  100, '2026-01-15 09:31:39.131313'),
(41, 31, 34, 17, 855.0000, 60,  '2026-01-15 09:31:40.232323'),
(42, 33, 36, 18, 141.5000, 200, '2026-01-15 09:31:41.333333'),
(43, 35, 38, 19, 176.5000, 180, '2026-01-15 09:31:42.434343'),
(44, 37, 40, 20, 131.0000, 200, '2026-01-15 09:31:43.535353'),
(45, 39, 42, 21, 156.2500, 300, '2026-01-15 09:31:44.636363'),
(46, 41, 44, 22, 35.5000,  500, '2026-01-15 09:31:45.737373'),
(47, 43, 46, 23, 48.7500,  1000,'2026-01-15 09:31:46.838383'),
(48, 45, 48, 24, 55.5000,  600, '2026-01-15 09:31:47.939393'),
(49, 47, 50, 25, 382.5000, 100, '2026-01-15 09:31:48.040404'),
(50, 49, 2,  1,  151.0000, 100, '2026-01-15 09:31:49.141414');

SET IDENTITY_INSERT Trade OFF;
GO

/* 11. SAMPLE DATA - PRICELEVEL (50 rows)
   Derived from the open book (best bid/ask per instrument).*/

SET IDENTITY_INSERT PriceLevel ON;

INSERT INTO PriceLevel (LevelID, InstrumentID, Side, Price, TotalQuantity) VALUES
(1,  1,  'Buy',  150.0000, 100),
(2,  1,  'Sell', 152.0000, 150),
(3,  2,  'Buy',  0.0000,   200),
(4,  2,  'Sell', 250.5000, 300),
(5,  3,  'Buy',  120.0000, 50),
(6,  3,  'Sell', 125.0000, 75),
(7,  4,  'Buy',  180.2500, 120),
(8,  4,  'Sell', 182.5000, 200),
(9,  5,  'Buy',  300.0000, 80),
(10, 5,  'Sell', 305.0000, 100),
(11, 6,  'Buy',  400.0000, 60),
(12, 6,  'Sell', 405.0000, 90),
(13, 7,  'Buy',  950.0000, 40),
(14, 7,  'Sell', 960.0000, 55),
(15, 8,  'Buy',  600.0000, 70),
(16, 8,  'Sell', 610.0000, 85),
(17, 9,  'Buy',  85.0000,  500),
(18, 9,  'Sell', 87.0000,  600),
(19, 10, 'Buy',  220.0000, 90),
(20, 10, 'Sell', 225.0000, 110),
(21, 11, 'Buy',  45.0000,  1000),
(22, 11, 'Sell', 46.0000,  1200),
(23, 12, 'Buy',  120.0000, 300),
(24, 12, 'Sell', 122.5000, 400),
(25, 13, 'Buy',  140.0000, 150),
(26, 13, 'Sell', 142.0000, 200),
(27, 14, 'Buy',  55.0000,  700),
(28, 14, 'Sell', 56.5000,  800),
(29, 15, 'Buy',  500.0000, 100),
(30, 15, 'Sell', 510.0000, 120),
(31, 16, 'Buy',  75.0000,  400),
(32, 16, 'Sell', 77.0000,  500),
(33, 17, 'Buy',  850.0000, 60),
(34, 17, 'Sell', 860.0000, 80),
(35, 18, 'Buy',  140.0000, 200),
(36, 18, 'Sell', 143.0000, 250),
(37, 19, 'Buy',  175.0000, 180),
(38, 19, 'Sell', 178.0000, 220),
(39, 20, 'Buy',  130.0000, 300),
(40, 20, 'Sell', 132.0000, 350),
(41, 21, 'Buy',  155.0000, 500),
(42, 21, 'Sell', 157.5000, 600),
(43, 22, 'Buy',  35.0000,  1500),
(44, 22, 'Sell', 36.0000,  1800),
(45, 23, 'Buy',  48.0000,  900),
(46, 23, 'Sell', 49.5000,  1000),
(47, 24, 'Buy',  55.0000,  600),
(48, 24, 'Sell', 56.0000,  700),
(49, 25, 'Buy',  380.0000, 100),
(50, 25, 'Sell', 385.0000, 150);

SET IDENTITY_INSERT PriceLevel OFF;
GO
*/

--   12. VERIFICATION QUERIES

SELECT 'Trader'     AS TableName, COUNT(*) AS [RowCount] FROM Trader     UNION ALL
SELECT 'Instrument',              COUNT(*)               FROM Instrument UNION ALL
SELECT 'Order',                   COUNT(*)               FROM [Order]    UNION ALL
SELECT 'Trade',                   COUNT(*)               FROM Trade      UNION ALL
SELECT 'PriceLevel',              COUNT(*)               FROM PriceLevel;
GO

-- Sample joins to verify FK integrity 
-- Best bid/ask per instrument
SELECT i.Symbol,
       MAX(CASE WHEN o.Side = 'Buy'  THEN o.Price END) AS BestBid,
       MIN(CASE WHEN o.Side = 'Sell' THEN o.Price END) AS BestAsk
FROM Instrument i
LEFT JOIN [Order] o ON o.InstrumentID = i.InstrumentID
WHERE o.Status = 'Open'
GROUP BY i.Symbol
ORDER BY i.Symbol;

-- Trade summary per instrument
SELECT i.Symbol, COUNT(t.TradeID) AS TradeCount, SUM(t.Quantity) AS TotalQty
FROM Instrument i
LEFT JOIN Trade t ON t.InstrumentID = i.InstrumentID
GROUP BY i.Symbol
ORDER BY i.Symbol;
GO