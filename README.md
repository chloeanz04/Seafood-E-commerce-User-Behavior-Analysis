# Seafood E-commerce User Behavior Analysis
## Project Overview
This project analyzes user behavior on a seafood e-commerce website. The goal is to extract insights from website events to understand user interactions, purchase behavior, and conversion rates across products and categories.  

Key tasks include:  
- Calculating purchase and abandonment rates.  
- Identifying top-viewed, top-added-to-cart, and top-purchased products.  
- Generating aggregated reports at both product and category levels.  
- Calculating conversion metrics such as view-to-purchase and cart-to-purchase rates.  

## Database and Data
The analysis uses the following database and tables:

### Database
- **seafood_db**: Created from `casestudy.sql`.

### Tables
1. **page_hierarchy**: Contains product information including `product_id`, `product_name`, and `category`. Products include Salmon, Kingfish, Tuna, Russian Caviar, Black Truffle, Abalone, Lobster, Crab, and Oyster.  
2. **users**: Tracks users via `cookie_id`.  
3. **event_identifier**: Stores event types and names (Page View, Add to Cart, Purchase, Ad Impression, Ad Click).  
4. **campaign_identifier**: Contains information on the 3 marketing campaigns run by the website.  
5. **events**: Records each user action, including `cookie_id`, `page_id`, `event_type`, `event_time`, and `sequence_number`.  

## Analysis Questions
The project addresses the following questions:  

1. Percentage of sessions with a purchase event.  
2. Percentage of sessions viewing the checkout page but without a purchase.  
3. Top 3 pages with the most views.  
4. Number of views and add-to-cart events per product category.  
5. Top 3 products by purchase count.  
6. Generate a table per product with:
   - Number of views
   - Number of add-to-cart events
   - Number of abandoned carts (added to cart but not purchased)
   - Number of purchases
7. Generate a similar aggregated table per product category.  
8. Identify products with the highest views, add-to-cart, and purchase counts.  
9. Identify products with the highest cart abandonment.  
10. Identify products with the highest view-to-purchase conversion rate.  
11. Calculate average view-to-add-to-cart conversion rate.  
12. Calculate average add-to-cart-to-purchase conversion rate.  
