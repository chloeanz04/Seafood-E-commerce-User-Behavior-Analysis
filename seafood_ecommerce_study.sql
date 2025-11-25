SET search_path = hqtcsdl;
SELECT current_schema
-- 1. Tỷ lệ phần trăm lượt truy cập có sự kiện mua hàng là bao nhiêu?
SELECT ROUND(SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END)::numeric/(COUNT(DISTINCT(e.visit_id)))::numeric, 3)
FROM events e JOIN event_identifier ei ON e.event_type = ei.event_type

-- 2. Tỷ lệ phần trăm lượt truy cập xem trang thanh toán nhưng không có sự kiện mua hàng là bao nhiêu?
WITH checkout_visit AS (
	SELECT DISTINCT visit_id
	FROM events e NATURAL JOIN page_hierarchy ph
	WHERE ph.page_name = 'Checkout'
),
purchase AS (
	SELECT DISTINCT visit_id
	FROM events e NATURAL JOIN event_identifier ei
	WHERE ei.event_name = 'Purchase'
)
SELECT ROUND((SELECT COUNT(*) FROM checkout_visit WHERE visit_id NOT IN 
(SELECT visit_id FROM purchase))::numeric/(SELECT COUNT(DISTINCT(visit_id)) FROM events)::numeric, 3) AS view_checkout_no_purchase

-- 3. 3 trang có số lượt xem nhiều nhất là những trang nào?
SELECT ph.page_name, COUNT(DISTINCT(e.visit_id)) AS view_count
FROM events e JOIN page_hierarchy ph ON e.page_id = ph.page_id
JOIN event_identifier ei ON e.event_type = ei.event_type
WHERE ei.event_name = 'Page View'
GROUP BY ph.page_name
ORDER BY COUNT(DISTINCT(e.visit_id)) DESC
LIMIT 3

-- 4. Số lượt xem và số lần thêm vào giỏ hàng cho từng danh mục sản phẩm là bao nhiêu?
SELECT ph.product_category,
	   SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS page_view_count,
	   SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS add_to_cart_count
FROM events e NATURAL JOIN page_hierarchy ph
NATURAL JOIN event_identifier ei
WHERE product_category IS NOT NULL
GROUP BY ph.product_category

-- 5. 3 sản phẩm có số lượt mua nhiều nhất là gì?
WITH check_purchase AS (
SELECT DISTINCT(e.visit_id)
FROM events e JOIN event_identifier ei ON e.event_type = ei.event_type
WHERE ei.event_name = 'Purchase'
),
add_to_cart AS (
SELECT e.visit_id, ph.product_id, ph.page_name
FROM events e JOIN page_hierarchy ph ON e.page_id = ph.page_id
JOIN event_identifier ei ON e.event_type = ei.event_type
WHERE ei.event_name = 'Add to Cart' AND e.visit_id IN (SELECT visit_id FROM check_purchase)
)
SELECT product_id, COUNT(*) AS purchase_count
FROM add_to_cart
GROUP BY product_id
ORDER BY COUNT(*) DESC
LIMIT 3

-- 6. Sử dụng một truy vấn SQL duy nhất - tạo một bảng đầu ra mới có các chi tiết sau:
CREATE TEMP TABLE product_analysis AS (
	-- Mỗi sản phẩm được xem bao nhiêu lần
	WITH prod_page_view AS (
		SELECT DISTINCT(ph.product_id), COUNT(*) AS product_view
		FROM events e NATURAL JOIN page_hierarchy ph
		NATURAL JOIN event_identifier ei
		WHERE ei.event_name = 'Page View' AND ph.product_id IS NOT NULL 
		GROUP BY ph.product_id
	),
	-- Mỗi sản phẩm được thêm vào giỏ hàng bao nhiêu lần
	prod_add_to_cart AS (
		SELECT DISTINCT(ph.product_id), COUNT(*) AS product_to_cart
		FROM events e NATURAL JOIN page_hierarchy ph
		NATURAL JOIN event_identifier ei
		WHERE ei.event_name = 'Add to Cart' AND ph.product_id IS NOT NULL 
		GROUP BY ph.product_id
	),
	-- Mỗi sản phẩm được thêm vào giỏ hàng nhưng không được mua (bị bỏ rơi) bao nhiêu lần?
	check_purchase AS (
		SELECT DISTINCT(e.visit_id)
		FROM events e JOIN event_identifier ei ON e.event_type = ei.event_type
		WHERE ei.event_name = 'Purchase'
	),
	add_to_cart_not_buy AS (
		SELECT ph.product_id, COUNT(*) AS product_not_buy
		FROM events e JOIN page_hierarchy ph ON e.page_id = ph.page_id
		JOIN event_identifier ei ON e.event_type = ei.event_type
		WHERE ei.event_name = 'Add to Cart' AND e.visit_id NOT IN (SELECT visit_id FROM check_purchase)
		GROUP BY ph.product_id
	),
	-- Mỗi sản phẩm được mua bao nhiêu lần?
	add_to_cart_buy AS (
		SELECT ph.product_id, COUNT(*) AS product_buy
		FROM events e JOIN page_hierarchy ph ON e.page_id = ph.page_id
		JOIN event_identifier ei ON e.event_type = ei.event_type
		WHERE ei.event_name = 'Add to Cart' AND e.visit_id IN (SELECT visit_id FROM check_purchase)
		GROUP BY ph.product_id
	)
	SELECT ppv.product_id, ppv.product_view, patc.product_to_cart, anb.product_not_buy, acb.product_buy
	FROM prod_page_view ppv JOIN prod_add_to_cart patc ON ppv.product_id = patc.product_id
	JOIN add_to_cart_not_buy anb ON ppv.product_id = anb.product_id
	JOIN add_to_cart_buy acb ON ppv.product_id = acb.product_id
	ORDER BY ppv.product_id
)

-- 7. Hãy tạo một bảng khác để tổng hợp thêm dữ liệu tương tự như câu 6 nhưng lần
-- này là cho từng danh mục sản phẩm thay vì từng sản phẩm riêng lẻ.
CREATE TEMP TABLE category_analysis AS (
	-- Mỗi danh mục được xem bao nhiêu lần
	WITH cat_page_view AS (
		SELECT DISTINCT(ph.product_category), COUNT(*) AS category_view
		FROM events e NATURAL JOIN page_hierarchy ph
		NATURAL JOIN event_identifier ei
		WHERE ei.event_name = 'Page View' AND ph.product_category IS NOT NULL 
		GROUP BY ph.product_category
	),
	-- Mỗi danh mục được thêm vào giỏ hàng bao nhiêu lần
	cat_add_to_cart AS (
		SELECT DISTINCT(ph.product_category), COUNT(*) AS category_to_cart
		FROM events e NATURAL JOIN page_hierarchy ph
		NATURAL JOIN event_identifier ei
		WHERE ei.event_name = 'Add to Cart' AND ph.product_category IS NOT NULL 
		GROUP BY ph.product_category
	),
	-- Mỗi danh mục được thêm vào giỏ hàng nhưng không được mua (bị bỏ rơi) bao nhiêu lần?
	check_purchase AS (
		SELECT DISTINCT(e.visit_id)
		FROM events e JOIN event_identifier ei ON e.event_type = ei.event_type
		WHERE ei.event_name = 'Purchase'
	),
	add_to_cart_not_buy AS (
		SELECT ph.product_category, COUNT(*) AS category_not_buy
		FROM events e JOIN page_hierarchy ph ON e.page_id = ph.page_id
		JOIN event_identifier ei ON e.event_type = ei.event_type
		WHERE ei.event_name = 'Add to Cart' AND e.visit_id NOT IN (SELECT visit_id FROM check_purchase)
		GROUP BY ph.product_category
	),
	-- Mỗi danh mục được mua bao nhiêu lần?
	add_to_cart_buy AS (
		SELECT ph.product_category, COUNT(*) AS category_buy
		FROM events e JOIN page_hierarchy ph ON e.page_id = ph.page_id
		JOIN event_identifier ei ON e.event_type = ei.event_type
		WHERE ei.event_name = 'Add to Cart' AND e.visit_id IN (SELECT visit_id FROM check_purchase)
		GROUP BY ph.product_category
	)
	SELECT cpv.product_category, cpv.category_view, catc.category_to_cart, anb.category_not_buy, acb.category_buy
	FROM cat_page_view cpv JOIN cat_add_to_cart catc ON cpv.product_category = catc.product_category
	JOIN add_to_cart_not_buy anb ON cpv.product_category = anb.product_category
	JOIN add_to_cart_buy acb ON cpv.product_category = acb.product_category
	ORDER BY cpv.product_category
)

-- 8. Sản phẩm nào có nhiều lượt xem, thêm vào giỏ hàng và mua nhất?
-- Lượt xem nhiều nhất
SELECT product_id, product_view
FROM product_analysis
ORDER BY product_view DESC
LIMIT 1
-- Thêm vào giỏ hàng nhiều nhất
SELECT product_id, product_to_cart
FROM product_analysis
ORDER BY product_to_cart DESC
LIMIT 1
-- Nhiều lượt mua nhất
SELECT product_id, product_buy
FROM product_analysis
ORDER BY product_buy DESC
LIMIT 1

-- Lượt xem, lượt thêm vào giỏ hàng, lượt mua nhiều nhất
SELECT product_id, product_view, product_to_cart, product_buy
FROM product_analysis
ORDER BY product_view, product_to_cart, product_buy DESC
LIMIT 1

-- 9. Sản phẩm nào có khả năng bị bỏ rơi (thêm vào giỏ hàng nhưng không được mua) nhiều nhất?
SELECT product_id, product_not_buy
FROM product_analysis
ORDER BY product_not_buy DESC
LIMIT 1

-- 10. Sản phẩm nào có tỷ lệ phần trăm lượt xem thành mua (view to purchase) cao nhất?
SELECT product_id, ROUND(product_buy::numeric/product_view::numeric, 3) AS purchase_ratio
FROM product_analysis
ORDER BY ROUND(product_buy::numeric/product_view::numeric, 3) DESC
LIMIT 1

-- 11. Tỷ lệ chuyển đổi trung bình từ lượt xem thành thêm vào giỏ hàng (from view to cart add) là bao nhiêu?
SELECT ROUND(AVG(product_to_cart::numeric/product_view::numeric), 3) AS to_cart_ratio
FROM product_analysis

-- 12. Tỷ lệ chuyển đổi trung bình từ thêm vào giỏ hàng thành mua (from cart add to purchase) là bao nhiêu?
SELECT ROUND(AVG(product_buy::numeric/product_to_cart::numeric), 3) AS to_cart_ratio
FROM product_analysis

SELECT * FROM category_analysis

SELECT *
FROM events e NATURAL JOIN page_hierarchy ph
NATURAL JOIN event_identifier ei