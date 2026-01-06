# Nebim V3 – WS Order Cancel & SP

This repository contains a stored procedure used to cancel a specific WS order
and fully clear remaining quantities from reserve and order tables.

## Stored Procedure
- `dbo.sp_CancelSpecificOrder_WS`

## What it does
Given an `@OrderNumber`, the procedure:
- finds related `OrderLineID` records for `ProcessCode = 'WS'`
- updates `trOrderLine.CancelQty1` by adding the current `stOrder.Qty1`
- sets `stReserve.Qty1` and `stReserve.FcQty1` to `0`
- sets `stOrder.Qty1` to `0`

## Parameters
- `@OrderNumber` (required)
- `@CompanyId` (optional, default = 2)

## Example
```sql
EXEC dbo.sp_CancelSpecificOrder_WS @OrderNumber = 'WS-2025-000123';
