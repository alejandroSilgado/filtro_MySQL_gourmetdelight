-- 1.Obtener la lista de todos los menús con sus precios

SELECT 	
	m.nombre,
    m.precio
FROM 
	menus AS m ;

-- 2. Encontrar todos los pedidos realizados por el cliente 'Juan Perez'
SELECT 
	p.id_cliente, 
    p.fecha, 
    p.total
FROM 
	pedidos AS p
JOIN 
	clientes AS c ON p.id_cliente = c.id_cliente
WHERE 
	c.nombre="Juan Perez";

-- 3. Listar los detalles de todos los pedidos, incluyendo el 
-- nombre del menú, cantidad y precio unitario

SELECT 
	dp.id_pedido,
    m.nombre,
	dp.cantidad,
	dp.precio_unitario
FROM 
	detallespedidos AS dp
JOIN  
	menus AS m ON dp.id_menu = m.id_menu;
    
-- 4. Calcular el total gastado por cada cliente en todos sus pedidos
SELECT 
	c.nombre, 
	SUM(p.total) AS TotalGastado
FROM 
	clientes AS c
JOIN 
	pedidos AS p ON c.id_cliente = p.id_cliente
GROUP BY 
	c.nombre;
    
-- 5. Encontrar los menús con un precio mayor a $10
SELECT
	m.nombre,
    m.precio
FROM 
	menus AS m 
WHERE 
	m.precio > 10;
    
-- 6.Obtener el menú más caro pedido al menos una vez
SELECT 
	m.nombre,
	MAX(m.precio) as precio
FROM 
	detallespedidos AS dp
JOIN  
	menus AS m ON dp.id_menu = m.id_menu
GROUP BY 
	m.nombre
ORDER BY 
	precio DESC
LIMIT 1;

-- 6.Listar los clientes que han realizado más de un pedido

SELECT 
	c.nombre, 
    c.correo_electronico
FROM 
	clientes AS c 
JOIN
	(
		SELECT 
			id_cliente
		FROM 
			pedidos
		GROUP BY 
			id_cliente
		HAVING 
			COUNT(id_pedido) > 1
	) AS p ON p.id_cliente = c.id_cliente;
    

-- 7.Obtener el cliente con el mayor gasto total

SELECT  
	c.nombre,
    SUM(p.total) AS TotalGastado 
FROM 
	clientes AS c
JOIN 
	pedidos AS p ON c.id_cliente = p.id_cliente
GROUP BY 
	c.nombre
ORDER BY 
	TotalGastado DESC
LIMIT 1;
-- 8.Mostrar el pedido más reciente de cada cliente
SELECT 
	c.nombre, 
    p.fecha,
    p.total
FROM 
	pedidos AS p 
JOIN 
	clientes AS c ON c.id_cliente = p.id_cliente
WHERE 
	(p.id_cliente, p.fecha) IN (
		SELECT 
			id_cliente, MAX(fecha)
		FROM 
			pedidos
		GROUP BY 
			id_cliente
	)
ORDER BY 
	p.fecha DESC;
-- 9. Obtener el detalle de pedidos (menús y cantidades) para el cliente 'Juan Perez'.

SELECT 
	dp.id_pedido,
    m.nombre, 
	dp.cantidad, 
	dp.precio_unitario
FROM  
	detallespedidos AS dp 
JOIN 
	menus AS m ON m.id_menu = dp.id_menu
JOIN 
	pedidos AS p ON p.id_pedido = dp.id_pedido
JOIN 
	clientes AS c ON c.id_cliente = p.id_cliente
WHERE 
	c.nombre = "Juan Perez";
    E
-------------------------------------------------
---------- PROCEDIMIENTOS ALMACENADOS -----------
-------------------------------------------------
-- Crear un procedimiento almacenado para agregar un nuevo cliente

DELIMITER $$
CREATE PROCEDURE nuevo_cliente (
	IN i_nombre VARCHAR(100),
    IN i_correo_electronico VARCHAR(100),
    IN i_telefono VARCHAR(15),
    IN i_fecha_registro DATE
)
BEGIN 
	INSERT INTO clientes (nombre, correo_electronico, telefono, fecha_registro) 
    VALUES (i_nombre,i_correo_electronico,i_telefono,i_fecha_registro);
END$$
DELIMITER ;

CALL nuevo_cliente("Andres Silgado", "andres.silgado@gmail.com","3138529155","2024-01-19");

-- Crear un procedimiento almacenado para obtener los detalles de un pedido
DELIMITER $$
CREATE PROCEDURE detalles_pedidos (
	IN i_id_pedido INT
)
BEGIN 
    DECLARE msg VARCHAR(255);

    IF NOT EXISTS (SELECT 1 FROM pedidos WHERE id_pedido = i_id_pedido) THEN
        SET msg = CONCAT('El ID ingresado no existe: ', i_id_pedido);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    ELSE
		SELECT dp.id_pedido,m.nombre, dp.cantidad, dp.precio_unitario
		FROM  detallespedidos AS dp 
		JOIN menus AS m ON m.id_menu = dp.id_menu
		JOIN pedidos AS p ON p.id_pedido = dp.id_pedido
		WHERE dp.id_pedido =i_id_pedido;
    
        SET msg = CONCAT('Se mostro correctamente los detalles del ID: ', i_id_pedido);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;
END$$
DELIMITER ;

call detalles_pedidos (3);

-- 3. Crear un procedimiento almacenado para actualizar el precio de un menú

DELIMITER $$
CREATE PROCEDURE actualizar_precio_menu (
	IN p_id_menu INT,
	IN p_precio DECIMAL(10,2)
)
BEGIN 
    DECLARE v_msg VARCHAR(255);

    IF NOT EXISTS (SELECT 1 FROM menus WHERE id_menu = p_id_menu) THEN
        SET v_msg = CONCAT('El ID ingresado no existe: ', p_id_menu);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    ELSE
        UPDATE 
			menus
        SET 
			precio = p_precio
        WHERE 
			id_menu = p_id_menu;
        SET v_msg = CONCAT('Se actualizo correctamente el precio del ID: ', p_id_menu);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;
END$$
DELIMITER ;

CALL actualizar_precio_menu(6, 8.00);
-- Crear un procedimiento almacenado para eliminar un cliente y sus pedidos


DELIMITER $$ 
CREATE PROCEDURE eliminar_cliente_pedidos ( 
in p_id_cliente INT ) 
BEGIN 
	DECLARE v_msg VARCHAR(255);
    
	IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente = p_id_cliente) THEN
		SET v_msg = CONCAT('El ID ingresado no existe: ', p_id_cliente);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
	ELSE
		DELETE FROM 
			pedidos
		WHERE 
			id_cliente = p_id_cliente;
		DELETE FROM 
			clientes
		WHERE 
			id_cliente = p_id_cliente;
		SET v_msg = CONCAT('Se eliminó correctamente el cliente y sus pedidos con ID: ', p_id_cliente);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
END IF;
END$$ 
DELIMITER ;

CALL eliminar_cliente_pedidos (13);

-- Crear un procedimiento almacenado para obtener el total gastado por un cliente
DELIMITER $$
CREATE PROCEDURE total_gastado_por_cliente ( 
	IN p_id_cliente INT 
) 
BEGIN 
	DECLARE v_msg VARCHAR(255);
    
	IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente = p_id_cliente) THEN
		SET v_msg = CONCAT('El ID ingresado no existe: ', p_id_cliente);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
	ELSE
		SELECT 
			SUM(total) AS total_gastado
		FROM 
			pedidos
		WHERE 
			id_cliente = p_id_cliente;
	END IF;
END$$ 
DELIMITER ;

CALL total_gastado_por_cliente(2);
