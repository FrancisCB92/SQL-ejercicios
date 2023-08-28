Sentencias SQL y PPT


DROP TABLE oehr_total_order;

CREATE TABLE oehr_total_order (
order_id number(22),
order_date DATE,
cantidad NUMBER(4),
precio_unitario NUMBER(10,2),
total_order GENERATED ALWAYS AS (cantidad * precio_unitario) VIRTUAL
);



INSERT INTO oehr_total_order (order_id, order_date, cantidad, precio_unitario)
SELECT o.order_id, TO_CHAR(o.order_date, 'MM/DD/YYYY'), i.quantity, i.unit_price
FROM oehr_orders o
INNER JOIN oehr_order_items i
ON o.order_id = i.order_id;

SELECT * FROM oehr_total_order;



DESCRIBE user_tables;



SELECT table_name, iot_type, partitioned, cluster_name
FROM user_tables;



DROP TABLE sales_range;

CREATE TABLE sales_range (
order_id NUMBER(5),
sales_date DATE,
total NUMBER(10,2))
PARTITION BY RANGE(sales_date) (
PARTITION sales_2019 VALUES LESS THAN(TO_DATE('01/01/2020','DD/MM/YYYY')),
PARTITION sales_2020 VALUES LESS THAN(TO_DATE('01/01/2021','DD/MM/YYYY')),
PARTITION sales_2021 VALUES LESS THAN(TO_DATE('01/01/2022','DD/MM/YYYY')),
PARTITION sales_2022 VALUES LESS THAN(TO_DATE('01/01/2023','DD/MM/YYYY'))
);



INSERT INTO sales_range (order_id, sales_date, total)
SELECT o.order_id, o.order_date fecha, SUM(i.quantity * i.unit_price) total
FROM oehr_orders o
INNER JOIN oehr_order_items i
ON o.order_id = i.order_id
GROUP BY o.order_id, o.order_date;


SELECT * FROM sales_range;

SELECT count(*) FROM sales_range;

SELECT * FROM sales_range PARTITION (sales_2020);

SELECT COUNT(*) FROM sales_range PARTITION (sales_2020);
SELECT * FROM sales_range PARTITION (sales_2021)

SELECT COUNT(*) FROM sales_range PARTITION (sales_2021);


DROP TABLE country_iot;

CREATE TABLE country_iot
(country_id CHAR(2),
country_name VARCHAR2(40),
region_id NUMBER,
CONSTRAINT COUNTRY_IOT_PK PRIMARY KEY (country_id) ENABLE
) ORGANIZATION INDEX NOCOMPRESS ;


INSERT INTO country_iot select * from oehr_countries;

SELECT * FROM oehr_countries WHERE country_id = 'AR';
SELECT * FROM country_iot WHERE country_id = 'AR';

SELECT * FROM oehr_countries WHERE country_name = 'Argentina';
SELECT * FROM country_iot WHERE country_name = 'Argentina';

DESCRIBE country_iot;







DROP TABLE departments_cluster;
DROP TABLE employees_cluster;
DROP INDEX idx_emp_dept_cluster;
DROP CLUSTER employees_departments_cluster;


CREATE CLUSTER employees_departments_cluster
(department_id NUMBER(4));

CREATE INDEX idx_emp_dept_cluster
ON CLUSTER employees_departments_cluster;

CREATE TABLE employees_cluster (
employee_id NUMBER(4),
first_name VARCHAR2(30),
last_name VARCHAR2(30),
department_id NUMBER(4,0)
)
CLUSTER employees_departments_cluster (department_id);
CREATE TABLE departments_cluster (
department_id NUMBER(4,0),
department_name VARCHAR2(30),
manager_id NUMBER(4)
)
CLUSTER employees_departments_cluster (department_id);
INSERT INTO departments_cluster(department_id,department_name, manager_id)
SELECT department_id,department_name, manager_id
FROM oehr_departments;
INSERT INTO employees_cluster (employee_id, first_name, last_name, department_id)
SELECT employee_id, first_name, last_name, department_id
FROM oehr_employees;
SELECT employee_id, first_name || ' ' || last_name, department_name
FROM employees_cluster e
INNER JOIN departments_cluster d
ON e.department_id = d.department_id
WHERE e.department_id = 60;
