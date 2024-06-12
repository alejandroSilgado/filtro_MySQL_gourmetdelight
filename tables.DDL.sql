
CREATE DATABASE gourmetdelight;
USE gourmetdelight;

CREATE TABLE gourmetdelight.clientes (
	id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    correo_electronico VARCHAR(100),
    telefono VARCHAR(15),
    fecha_registro DATE
);

CREATE TABLE gourmetdelight.pedidos (
	id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT,
    fecha DATE,
    total DECIMAL(10,2),
    
    CONSTRAINT FK_clientes_pedidos FOREIGN KEY (id_cliente) REFERENCES gourmetdelight.clientes(id_cliente)
);

CREATE TABLE gourmetdelight.menus (
	id_menu INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    descripcion TEXT,
    precio DECIMAL(10,2)
);

CREATE TABLE gourmetdelight.detallespedidos (
	id_pedido INT ,
	id_menu INT ,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    
	CONSTRAINT FK_pedidos_detallespedidos FOREIGN KEY (id_pedido) REFERENCES gourmetdelight.pedidos (id_pedido),
    CONSTRAINT FK_menus_detallespedidos FOREIGN KEY (id_menu) REFERENCES gourmetdelight.menus (id_menu)
);
