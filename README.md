# [SQL] Seafood E-commerce User Behavior Analysis
## Overview
This project analyzes user behavior on a seafood e-commerce website. The goal is to extract insights from website events to understand user interactions, purchase behavior, and conversion rates across products and categories.  

Key tasks include:  
- Calculating purchase and abandonment rates.  
- Identifying top-viewed, top-added-to-cart, and top-purchased products.  
- Generating aggregated reports at both product and category levels.  
- Calculating conversion metrics such as view-to-purchase and cart-to-purchase rates.

---

## Database and tables description
The analysis uses the following database and tables:

### Database
- **seafood_db**: Created from `casestudy.sql`.

### Tables
1. **page_hierarchy**: Contains product information including `product_id`, `product_name`, and `category`. Products include Salmon, Kingfish, Tuna, Russian Caviar, Black Truffle, Abalone, Lobster, Crab, and Oyster.  
2. **users**: Tracks users via `cookie_id`.  
3. **event_identifier**: Stores event types and names (Page View, Add to Cart, Purchase, Ad Impression, Ad Click).  
4. **campaign_identifier**: Contains information on the 3 marketing campaigns run by the website.  
5. **events**: Records each user action, including `cookie_id`, `page_id`, `event_type`, `event_time`, and `sequence_number`.

---

## Analysis Questions
The project addresses the following questions:  

1. **Percentage of sessions with a purchase event:** 49.9%  
2. **Percentage of sessions viewing the checkout page but without a purchase:** 9.1%  
3. **Top 3 pages with the most views:** All Products (3174), Checkout (2103), Home Page (1782)  
4. **Number of views and add-to-cart events per product category:**
   - **Shellfish:** 6204 views | 3792 add-to-carts
   - **Fish:** 4633 views | 2789 add-to-carts
   - **Luxury:** 3032 views | 1870 add-to-carts
5. **Top 3 products by purchase count:** Product 1 (754), Product 9 (726), Product 8 (719)  
6. **Product-level Analysis Table:**
   - Generated a detailed table containing Views, Add-to-cart, Abandoned carts, and Purchases for each product (ID 1-9).
   - *Insight:* Product 1 has the highest purchases (754), while Product 9 has the highest views (1568).
7. **Category-level Analysis Table:** Generated an aggregated table for Fish, Luxury, and Shellfish categories showing the funnel metrics.
8. **Products with highest engagement metrics:**
   - **Most Views:** Product 9 (1568 views)
   - **Most Add-to-Cart:** Product 7 (968 adds)
   - **Most Purchases:** Product 1 (754 purchases)  
9. **Product with the highest cart abandonment:** Product 4 (249 abandoned carts)  
10. **Product with the highest view-to-purchase conversion rate:** Product 7 (48.7% conversion rate)  
11. **Average view-to-add-to-cart conversion rate:** 61.0%  
12. **Average add-to-cart-to-purchase conversion rate:** 75.9%  
