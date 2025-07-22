SET SQL_SAFE_UPDATES = 0;

CREATE DATABASE Manufacturing_Data;
												USE Manufacturing_Data;

												Select * from ManufacturingData;

ALTER TABLE ManufacturingData MODIFY COLUMN `Primary Date` DATETIME;
ALTER TABLE ManufacturingData MODIFY COLUMN `Wastage Qty` float;
ALTER TABLE ManufacturingData MODIFY COLUMN `Manufactured Qty` float;

                                                        -- See a small sample of each column for date format --
SELECT `Primary Date`, `WO Date`, `Doc Date`
FROM ManufacturingData
WHERE `Primary Date` IS NOT NULL
      OR `WO Date`   IS NOT NULL
      OR `Doc Date`  IS NOT NULL
LIMIT 50;

														-- YYYY-MM-DD  (already valid) --
SELECT 'Primary Date' AS Col, COUNT(*)
FROM ManufacturingData
WHERE `Primary Date` REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
UNION ALL
SELECT 'WO Date'      , COUNT(*) FROM ManufacturingData
WHERE `WO Date` REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
UNION ALL
SELECT 'Doc Date'     , COUNT(*) FROM ManufacturingData
WHERE `Doc Date` REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

														-- DD-MM-YYYY  (needs conversion) --
SELECT 'Primary Date' AS Col, COUNT(*) 
FROM ManufacturingData
WHERE `Primary Date` REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
UNION ALL
SELECT 'WO Date'      , COUNT(*) FROM ManufacturingData
WHERE `WO Date` REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
UNION ALL
SELECT 'Doc Date'     , COUNT(*) FROM ManufacturingData
WHERE `Doc Date` REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$';
                   
                                                        -- Casting Primary, WO, Doc Date as Date --
UPDATE ManufacturingData
SET `Primary Date` = CAST(`Primary Date` AS DATE)
WHERE `Primary Date` REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

UPDATE ManufacturingData
SET `WO Date` = CAST(`WO Date` AS DATE)
WHERE `WO Date` REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

UPDATE ManufacturingData
SET `Doc Date` = CAST(`Doc Date` AS DATE)
WHERE `Doc Date` REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';
                                                           -- dd-mm-yyyy date format --
SELECT Distinct
  DATE_FORMAT(`Primary Date`, '%d-%m-%Y') AS `Primary Date`,
  DATE_FORMAT(`WO Date`,      '%d-%m-%Y') AS `WO Date`,
  DATE_FORMAT(`Doc Date`,     '%d-%m-%Y') AS `Doc Date`
FROM ManufacturingData
WHERE `Primary Date` IS NOT NULL
   OR `WO Date`      IS NOT NULL
   OR `Doc Date`     IS NOT NULL;

ALTER TABLE ManufacturingData MODIFY COLUMN `Doc Date` DATETIME;
DESC ManufacturingData;

SELECT DISTINCT Buyer FROM ManufacturingData;
SELECT DISTINCT `Doc Date`,`WO Date`,`Primary Date` FROM ManufacturingData;

                                                              -- Total KPIs --
                                                              
							SELECT SUM(`Manufactured Qty`) AS Total_Manufactured_Qty FROM ManufacturingData;
                            
							SELECT SUM(`Rejected Qty`) AS Total_Rejected_Qty FROM ManufacturingData;
                            
							SELECT SUM(`Processed Qty`) AS Total_Processed_Qty FROM ManufacturingData;
                            
							SELECT 
							  SUM(`Rejected Qty`) AS Total_Rejected_Qty,
							  SUM(`Processed Qty`) AS Total_Processed_Qty,
							  ROUND(SUM(`Rejected Qty`) / SUM(`Processed Qty`) * 100, 2) AS Wastage_Percentage
							FROM ManufacturingData
							WHERE `Rejected Qty` IS NOT NULL AND `Processed Qty` IS NOT NULL;

                                         -- Total Manufactured Quantity/Day --
                                         
CREATE OR REPLACE VIEW vw_ManufacturedQty1 AS
SELECT `WO Date`,
    SUM(`Manufactured Qty`) AS Total_Manufactured_Qty
FROM ManufacturingData
GROUP BY `WO Date`;
												SELECT * FROM vw_ManufacturedQty1;

                                                 -- Total Rejected Quantity By Day--
CREATE VIEW vw_RejectedQty AS
SELECT `Primary Date`,
    SUM(`Rejected Qty`) AS Total_Rejected_Qty
FROM ManufacturingData
GROUP BY `Primary Date`;
													SELECT * FROM vw_RejectedQty;

													-- Total Processed Quantity By Day
CREATE VIEW vw_ProcessedQty AS
SELECT `Primary Date`,
    SUM(`Processed Qty`) AS Total_Processed_Qty
FROM ManufacturingData
GROUP BY `Primary Date`;
													SELECT * FROM vw_ProcessedQty;

                                                    -- Total Wastage Percent by Day --
DROP VIEW IF EXISTS vw_WastageQty;
CREATE VIEW vw_WastagePercentage AS
SELECT 
    `Primary Date`,
    SUM(`Rejected Qty`) AS Total_Rejected_Qty,
    SUM(`Processed Qty`) AS Total_Processed_Qty,
    ROUND(SUM(`Rejected Qty`) / SUM(`Processed Qty`) * 100, 2) AS Wastage_Percentage
FROM ManufacturingData
WHERE `Rejected Qty` IS NOT NULL AND `Processed Qty` IS NOT NULL
GROUP BY `Primary Date`;
													SELECT * FROM vw_WastagePercentage;

DROP VIEW IF EXISTS vw_EmployeeRejectedQty;
                                                         -- Employee-wise Rejected Quantity --
CREATE VIEW vw_EmployeeRejectedQty AS
SELECT `Emp Name`, `EMP Code`,
    SUM(`Rejected Qty`) AS Rejected_By_Employee
FROM ManufacturingData
GROUP BY `Emp Name`, `EMP Code`
ORDER BY Rejected_By_Employee DESC LIMIT 5;
													SELECT * FROM vw_EmployeeRejectedQty;

DROP VIEW IF EXISTS vw_MachineRejectedQty;
                                                          -- Machine-wise Rejected Quantity --
CREATE VIEW vw_MachineRejectedQty AS
SELECT `Machine Code`,
    SUM(`Rejected Qty`) AS Rejected_By_Machine
FROM ManufacturingData
GROUP BY `Machine Code`
ORDER BY Rejected_By_Machine DESC LIMIT 5;
														SELECT * FROM vw_MachineRejectedQty;


                                                          -- Employee wise Rejected Qty--
CREATE OR REPLACE VIEW vw_RejectedByEmployee AS
SELECT 
    `EMP Code` AS Employee_Code,
    `Emp Name` AS Employee_Name,
    SUM(`Rejected Qty`) AS Total_Rejected_Qty
FROM ManufacturingData
WHERE `EMP Code` IS NOT NULL
GROUP BY `EMP Code`, `Emp Name`
ORDER BY Total_Rejected_Qty DESC
LIMIT 5;
													SELECT * FROM vw_RejectedByEmployee;
                                                    
                                                               -- Top Wastage Items --
CREATE OR REPLACE VIEW vw_Top5FrequentWastageItems AS
SELECT 
    `Item Name`,
    COUNT(*) AS Wastage_Count
FROM ManufacturingData
WHERE `Wastage Qty` IS NOT NULL
GROUP BY `Item Name`
ORDER BY Wastage_Count DESC
LIMIT 5;

														SELECT * FROM  vw_Top5FrequentWastageItems;

SHOW COLUMNS FROM ManufacturingData;

DROP VIEW IF EXISTS vw_ProductionTrend;
                                                              -- Production Comparison Trend --
CREATE OR REPLACE VIEW vw_ProductionTrend AS
SELECT 
    DATE_FORMAT(`Primary Date`, '%d-%m-%Y') AS Formatted_Date,
    YEAR(`Primary Date`) AS Year,
    MONTHNAME(`Primary Date`) AS Month,
    SUM(`Manufactured Qty`) AS Manufactured,
    SUM(`Processed Qty`) AS Processed,
    SUM(`Rejected Qty`) AS Rejected
FROM ManufacturingData
WHERE `Primary Date` IS NOT NULL
GROUP BY 
    DATE_FORMAT(`Primary Date`, '%d-%m-%Y'),
    YEAR(`Primary Date`),
    MONTHNAME(`Primary Date`);
														SELECT * FROM vw_ProductionTrend;

DROP VIEW IF EXISTS vw_ManufactureVsRejected;
                                                               -- Manufactured vs Rejected --
CREATE OR REPLACE VIEW vw_ManufacturedVsRejected AS
SELECT
    SUM(`Manufactured Qty`) AS Total_Manufactured_Qty,
    SUM(`Rejected Qty`) AS Total_Rejected_Qty
FROM ManufacturingData
WHERE `Manufactured Qty` IS NOT NULL AND `Rejected Qty` IS NOT NULL;

															SELECT * FROM vw_ManufacturedVsRejected;
                                                           
                                                           -- Rejection % for Manufacture Qty --
CREATE OR REPLACE VIEW vw_ManufacturedVsRejected1 AS
SELECT
    SUM(`Manufactured Qty`) AS Total_Manufactured_Qty,
    SUM(`Rejected Qty`) AS Total_Rejected_Qty,
    ROUND(SUM(`Rejected Qty`) / SUM(`Manufactured Qty`) * 100, 2) AS Rejection_Percentage
FROM ManufacturingData
WHERE `Manufactured Qty` IS NOT NULL AND `Rejected Qty` IS NOT NULL;
														
															SELECT * FROM vw_ManufacturedVsRejected1 ;


DROP VIEW IF EXISTS vw_DeptWise_ManufactureVsRejected;
                                                     -- Department-wise Manufactured vs Rejected --
CREATE VIEW vw_DeptWise_ManufactureVsRejected AS
SELECT `Department Name`,
    SUM(`Manufactured Qty`) AS Manufactured,
    SUM(`Rejected Qty`) AS Rejected
FROM ManufacturingData
GROUP BY `Department Name`;
														SELECT * FROM vw_DeptWise_ManufactureVsRejected;
 
Desc ManufacturingData;
ALTER TABLE ManufacturingData
MODIFY COLUMN `SO Expected Delivery F` DATE;
SELECT `SO Expected Delivery F` FROM ManufacturingData;

                                                         -- Estimated Days Required --
CREATE OR REPLACE VIEW Estimated_days AS
SELECT DISTINCT
  `WO Number`,
  DATEDIFF(`SO Expected Delivery F`, `WO Date`) AS Estimated_Days
FROM ManufacturingData
WHERE `WO Date` IS NOT NULL AND `SO Expected Delivery F` IS NOT NULL
ORDER BY Estimated_Days DESC
LIMIT 5;
															SELECT * FROM Estimated_days;
                                                            
                                                      -- Average Estimated Days --
											SELECT 
											  ROUND(AVG(DATEDIFF(`SO Expected Delivery F`, `WO Date`)), 2) AS Avg_Estimated_Days
											FROM ManufacturingData
											WHERE `WO Date` IS NOT NULL AND `SO Expected Delivery F` IS NOT NULL;

                                                         -- On time delivery% -- 
											SELECT 
											  ROUND(
												(COUNT(CASE 
													WHEN `U_unitdeldt` <= `SO Expected Delivery F` THEN 1 
												 END) * 100.0) / COUNT(`WO Number`), 2) AS Delivery_Percentage
											FROM ManufacturingData
											WHERE `U_unitdeldt` IS NOT NULL AND `SO Expected Delivery F` IS NOT NULL;




