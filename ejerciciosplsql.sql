SET SERVEROUTPUT ON;


DECLARE

PROCEDURE ejercicio3 IS
    nif         cliente.nif%type;
    nombre      cliente.nombre%type;
    apellidos   cliente.apellidos%type; 
    ventas      cliente.ventas%type;

    BEGIN
        SELECT nif, nombre, apellidos, ventas
            INTO nif, nombre, apellidos, ventas
            FROM cliente 
            WHERE ventas = 
                (SELECT MAX(ventas) FROM cliente);
    
        DBMS_OUTPUT.PUT_LINE('CLIENTE CON MAS VENTAS:');
        DBMS_OUTPUT.PUT_LINE(
        nif || ' ' || nombre || ' ' || apellidos || ' ' || ventas);
        
END ejercicio3;



    
PROCEDURE ejercicio4 IS

    referencia      articulo.referencia%type;
    descripcion     articulo.descripcion%type;
    
    BEGIN
        SELECT referencia, descripcion
            INTO referencia, descripcion
            FROM articulo
            WHERE und_vendidas = 
            (SELECT MAX(und_vendidas) 
                FROM articulo);
                
        DBMS_OUTPUT.PUT_LINE( referencia || ' ' || descripcion );
    
END ejercicio4;




PROCEDURE ejercicio5 IS
    
    direccion direccion_envio.direccion%type;
    
    BEGIN
    
    SELECT direccion 
        INTO direccion
        FROM direccion_envio
        JOIN envio USING (nif, id_dir_env)
        WHERE nenvio = 1;
        
    DBMS_OUTPUT.PUT_LINE(direccion);
    
END ejercicio5;
    

PROCEDURE ejercicio6 IS

    pedido_count    NUMBER;
    
    BEGIN
    
    SELECT COUNT(distinct nenvio) INTO pedido_count 
        FROM lenvio WHERE npedido = 3;
    
    IF pedido_count > 1 THEN
    
        FOR fila IN (SELECT precio, dto, npedido 
                        FROM lpedido 
                        JOIN lenvio USING (nlinea, npedido)
                        WHERE npedido = 3) LOOP
            
            DBMS_OUTPUT.PUT_LINE(fila.precio - fila.precio*fila.dto);
        
        END LOOP;
    
    END IF;
            
END ejercicio6;

PROCEDURE ejercicio7 IS
    
    fecha_art_reciente      pedido.fecha%type;
    pvp_art_reciente        articulo.pvp%type;
    
    BEGIN
        SELECT MAX(fecha) INTO fecha_art_reciente
            FROM pedido
            JOIN lpedido USING (npedido)
            WHERE referencia = 'FRUT0001';
        
        
        DBMS_OUTPUT.PUT_LINE(fecha_art_reciente);
        
        
        IF fecha_art_reciente < '01/02/2025' THEN
        
            SELECT pvp INTO pvp_art_reciente
                FROM articulo
                WHERE referencia = 'FRUT0001';
        
            IF pvp_art_reciente > 1.5 THEN
            
                DBMS_OUTPUT.PUT_LINE('PVP ES MAYOR QUE 1.5, ACTUALIZANDO PVP...');
                UPDATE articulo 
                    SET pvp = pvp - 1 
                    WHERE referencia = 'FRUT0001';
            ELSE
                DBMS_OUTPUT.PUT_LINE('NO SE PUEDE BAJAR MÁS EL PVP');
            END IF;
            
        ELSE
            DBMS_OUTPUT.PUT_LINE('LA ULTIMA VENTA ES DE DEPUES DE 01/02/2025');

        END IF;

END ejercicio7;

PROCEDURE ejercicio8 IS
    
    nlineas_envio NUMBER;
    
    BEGIN
    SELECT COUNT(nenvio) 
        INTO nlineas_envio 
        FROM lenvio
        JOIN lpedido USING(npedido, nlinea)
        WHERE lenvio.unidades = lpedido.unidades
        AND nenvio = 1
        ;
    
    IF nlineas_envio > 2 THEN
        DBMS_OUTPUT.PUT_LINE('DISMINUYENDO PRECIO...');

    /*
    Si se quiere disminuir el precio
    se puede hacer aumentando la columna dto
    o modificando el precio directamente
    */
        UPDATE lpedido 
            SET dto = dto + 0.1
            WHERE (npedido, nlinea) in 
            (SELECT npedido, nlinea FROM lenvio 
                WHERE nenvio = 1);
    
    -- COMPROBACION
    /*
        SELECT * FROM lpedido
            WHERE (npedido, nlinea) IN 
            (SELECT npedido,nlinea FROM lenvio 
                WHERE nenvio = 1);
    */
    ELSE
        DBMS_OUTPUT.PUT_LINE('NO HAY SUFICIENTES ENVIOS');
    END IF;
    
    
END ejercicio8;    


PROCEDURE ejercicio9 IS
    
    res_count   NUMBER;
    res_avg     NUMBER;
    
    BEGIN
        SELECT COUNT(nif) INTO res_count
            FROM reseña WHERE nif = '30000001A'
            AND clasificacion < 3;
        
        IF res_count > 1 THEN
            DBMS_OUTPUT.PUT_LINE('Este cliente se queja mucho');
        ELSE
        /*
        "De lo contrario que muestre por pantalla la media de todas sus reseñas."
        Entiendo que se refiere a la media de clasificacion
        */
            SELECT AVG(clasificacion) INTO res_avg
                FROM reseña WHERE nif = '30000001A';
            DBMS_OUTPUT.PUT_LINE('MEDIA: ' || res_avg);

        END IF;


END ejercicio9;



PROCEDURE ejercicio10 IS
    --SELECT ADD_MONTHS(SYSDATE,-1) FROM DUAL;

    fecha_pedido pedido.fecha%type;
    fecha_hace_un_mes DATE := ADD_MONTHS(SYSDATE,-1);
    
    BEGIN
        SELECT fecha INTO fecha_pedido
            FROM pedido WHERE npedido = 1;
            
        DBMS_OUTPUT.PUT_LINE('FECHA PEDIDO: ' || fecha_pedido);
        DBMS_OUTPUT.PUT_LINE('FECHA ACTUAL: ' || SYSDATE);

        -- Si el pedido es mayor que la fecha actual menos un mes entonces 
        -- fue hace menos de un mes
        IF fecha_pedido > fecha_hace_un_mes THEN
            DBMS_OUTPUT.PUT_LINE('el pedido fue hace MENOS de un mes');
        ELSE
            DBMS_OUTPUT.PUT_LINE('el pedido fue hace MÁS de un mes');
        END IF;
        
    
END ejercicio10;



PROCEDURE ejercicio11 IS
    nfactura_envio NUMBER;
    factura_fecha DATE;
    
    BEGIN
        SELECT nfactura INTO nfactura_envio
            FROM envio WHERE nenvio = 7;
            
        IF nfactura_envio is not null THEN
            DBMS_OUTPUT.PUT_LINE('El envio esta facturado');
        
            SELECT fecha INTO factura_fecha 
                FROM factura WHERE nfactura = nfactura_envio;
            DBMS_OUTPUT.PUT_LINE(factura_fecha);
        
        ELSE 
            DBMS_OUTPUT.PUT_LINE('El envio no esta facturado');
            DBMS_OUTPUT.PUT_LINE('Creando la factura para el envio 7...');

            INSERT INTO factura(nfactura, fecha) 
                values(nfactura_envio, SYSDATE);
        
        END IF;

END ejercicio11;


PROCEDURE ejercicio12 IS
    
    suma_totales NUMBER;
    
    BEGIN
        SELECT SUM(total_pedido) INTO suma_totales
            FROM pedido 
            JOIN cliente USING (nif)
            WHERE nombre || ' ' || apellidos = 'Rafael González Gómez'
            AND EXTRACT(MONTH FROM fecha) = 1;
            
        CASE
            WHEN suma_totales is null 
                THEN DBMS_OUTPUT.PUT_LINE('Bonificación 0%');
            WHEN suma_totales BETWEEN 0 AND 500 
                THEN DBMS_OUTPUT.PUT_LINE('Ventas de ' || suma_totales || ' con bonificación de 1,5%');
            WHEN suma_totales BETWEEN 500 AND 1000 
                THEN DBMS_OUTPUT.PUT_LINE('Ventas de ' || suma_totales || ' con bonificación de 2,75%');
            WHEN suma_totales BETWEEN 1000 AND 1500 
                THEN DBMS_OUTPUT.PUT_LINE('Ventas de ' || suma_totales || ' con bonificación de 3,5%');
            WHEN suma_totales > 1500 
                THEN DBMS_OUTPUT.PUT_LINE('Ventas de ' || suma_totales || ' con bonificación de 5%');
        END CASE;
            

END ejercicio12;

PROCEDURE ejercicio13 IS

    nvendidas NUMBER;
    refe articulo.referencia%type;
    
    BEGIN
    
        SELECT referencia, und_vendidas INTO refe, nvendidas
        FROM articulo 
        WHERE LOWER(descripcion) = 'puntero laser';
    
        DBMS_OUTPUT.PUT_LINE('Unidades vendidas: ' || nvendidas);
        
        CASE
            WHEN nvendidas = 0 
                THEN UPDATE articulo 
                    SET pvp = pvp - (pvp * 0.2)
                    WHERE referencia = refe;
                    
                    DBMS_OUTPUT.PUT_LINE('DISMINUYENDO 20%');

            WHEN nvendidas BETWEEN 1 AND 3
                THEN UPDATE articulo 
                    SET pvp = pvp - (pvp * 0.1)
                    WHERE referencia = refe;
                    
                    DBMS_OUTPUT.PUT_LINE('DISMINUYENDO 10%');
            
            WHEN nvendidas BETWEEN 4 AND 6 
                THEN UPDATE articulo 
                    SET pvp = pvp - (pvp * 0.05)
                    WHERE referencia = refe;
                    
                    DBMS_OUTPUT.PUT_LINE('DISMINUYENDO 5%');
                    
            WHEN nvendidas BETWEEN 7 AND 10 
                THEN UPDATE articulo 
                    SET dto_venta = dto_venta + 0.05
                    WHERE referencia = refe;
                    
                    DBMS_OUTPUT.PUT_LINE('AUMENTANDO DTO 5%');
                    
            WHEN nvendidas > 10 
                THEN UPDATE articulo 
                    SET pvp = pvp + (pvp * 0.05)
                    WHERE referencia = refe;
                    
                    DBMS_OUTPUT.PUT_LINE('AUMENTANDO PVP 5%');
        END CASE;
                

    
END ejercicio13;



PROCEDURE ejercicio14 IS
    
    ventas NUMBER;
    
    BEGIN
        SELECT SUM(total_pedido) INTO ventas
            FROM pedido 
            JOIN cliente USING (nif)
            WHERE nombre || ' ' || apellidos = 'Rafael González Gómez'
            AND EXTRACT(MONTH FROM fecha) = 1;
        
        DBMS_OUTPUT.PUT_LINE('Ventas: ' || ventas);

        
        CASE 
          WHEN ventas > 10000 THEN
             DBMS_OUTPUT.PUT_LINE('Cliente excelente.');
          WHEN ventas < 1000 THEN
             DBMS_OUTPUT.PUT_LINE('Cliente esporádico.');
          WHEN ventas < 2500 THEN
             DBMS_OUTPUT.PUT_LINE('Cliente aceptable.');
          WHEN ventas < 5000 THEN
             DBMS_OUTPUT.PUT_LINE('Cliente bueno.');
        END CASE;
    
END ejercicio14;




PROCEDURE ejercicio15 IS
    
    id_forma_envio  forma_envio.id_fe%type;
    
    nfilas          NUMBER;
    nenvios         NUMBER;
    
    BEGIN
        
        FOR fila_forma_envio IN (SELECT id_fe FROM forma_envio) LOOP
        
            SELECT COUNT(nenvio) INTO nenvios 
                FROM envio WHERE forma_envio = fila_forma_envio.id_fe;
            
            DBMS_OUTPUT.PUT_LINE(fila_forma_envio.id_fe || ' ' || nenvios);
            
            IF nenvios = 0 THEN 
            
                DBMS_OUTPUT.PUT_LINE('La forma de envio numero ' || fila_forma_envio.id_fe || ' no tiene envios, finalizando bucle... ');
                EXIT;
                
            END IF;
            
            
        END LOOP;
        
        
END ejercicio15;





PROCEDURE ejercicio16 IS



    BEGIN
    
        DBMS_OUTPUT.PUT_line('');
        
        FOR fila_lpedido IN (SELECT referencia, descripcion, pvp, dto_venta, und_disponibles
                                FROM lpedido 
                                JOIN articulo USING(referencia)
                                WHERE npedido = 15 
                                FETCH FIRST 5 ROWS ONLY) LOOP
        
        /*
        select referencia, descripcion, pvp, dto_venta 
            from lpedido 
            join articulo using(referencia)
            where npedido = 15 
            fetch first 5 rows only;
        */
        
            IF fila_lpedido.pvp > 5 THEN
                DBMS_OUTPUT.PUT_line('Es mayor que 2');
                                
                DBMS_OUTPUT.PUT(fila_lpedido.referencia     || ' ');
                DBMS_OUTPUT.PUT(fila_lpedido.descripcion    || ' ');
                DBMS_OUTPUT.PUT(fila_lpedido.pvp            || ' ');
                DBMS_OUTPUT.PUT(fila_lpedido.dto_venta      || ' ');
                DBMS_OUTPUT.PUT_line('');
            
            ELSE 
                DBMS_OUTPUT.PUT_line('Es MENOR que 2');
                
                DBMS_OUTPUT.PUT(fila_lpedido.referencia         || ' ');
                DBMS_OUTPUT.PUT(fila_lpedido.descripcion        || ' ');
                DBMS_OUTPUT.PUT(fila_lpedido.und_disponibles    || ' ');
                DBMS_OUTPUT.PUT_line('');
            
            END IF;
            
        END LOOP;
    
    
END ejercicio16;


PROCEDURE ejercicio17 IS
    -- TOTAL DE FACTURA??
    BEGIN
    
        FOR fila IN (SELECT nfactura, fecha
                                FROM factura 
                                ORDER BY nfactura DESC
                                FETCH FIRST 5 ROWS ONLY) LOOP
                                
            DBMS_OUTPUT.PUT_line(
            fila.nfactura || ' ' || fila.fecha );

            
        END LOOP;
    
END ejercicio17;    



PROCEDURE ejercicio18 IS
    
    contador_lineas     NUMBER;
    suma_importes       NUMBER(8,2);
    
    BEGIN
        FOR dia IN 1..31 LOOP
            SELECT COUNT(npedido), SUM(precio-precio*dto)
                INTO contador_lineas, suma_importes
                FROM lpedido 
                JOIN pedido USING (npedido)
                WHERE EXTRACT (DAY FROM fecha) = dia
                AND EXTRACT (MONTH FROM fecha) = 1
                ;
            
            IF contador_lineas = 0 THEN
                DBMS_OUTPUT.PUT_LINE('DIA ' || dia || ' NO HAY LINEAS');
                --EXIT; -- SALIR DEL BUCLE CUANDO NO HAY LINEAS
            ELSE
                DBMS_OUTPUT.PUT_LINE(dia || ': ' ||
                contador_lineas || '    ' || suma_importes);
            END IF;
            
        END LOOP;
        

END ejercicio18;

PROCEDURE ejercicio19 IS

    nif             cliente.nif%type;
    nombre          cliente.nombre%type;
    apellidos       cliente.apellidos%type;
    nlineas         NUMBER;
    

    BEGIN
    
        FOR fila IN (SELECT npedido, total_pedido, nif 
                        FROM pedido 
                        FETCH FIRST 5 ROWS ONLY) LOOP
                        
            DBMS_OUTPUT.PUT(fila.npedido || ': ');
            
            -- lo cambio a 100 para ver las dos opciones
            IF fila.total_pedido >= 100 THEN
                
                SELECT nif, nombre, apellidos INTO nif, nombre, apellidos
                    FROM cliente WHERE nif = fila.nif;
                
                DBMS_OUTPUT.PUT_LINE(
                nif || ' ' || nombre || ' ' || apellidos);
                
            ELSE
                
                SELECT COUNT(npedido) INTO nlineas 
                    FROM lpedido WHERE npedido = fila.npedido;
                
                DBMS_OUTPUT.PUT_LINE('Tiene ' || nlineas || ' lineas');
                
            END IF;
            
        END LOOP;
    
END ejercicio19;    


--NO TERMINADO
PROCEDURE ejercicio20 IS
    
    nenvio      envio.nenvio%type;
    fecha       envio.fecha%type;
    
    BEGIN
    
        FOR fila IN (SELECT npedido
                        FROM lenvio
                        GROUP BY npedido
                        HAVING COUNT(nenvio) > 1) LOOP
                        
            DBMS_OUTPUT.PUT_LINE('POR HACER');
                       
        END LOOP;
        
        
    
END ejercicio20;



PROCEDURE ejercicio21 IS
    
    provincia_check direccion_envio.provincia%type;
    

    BEGIN
    
        FOR fila IN (SELECT DISTINCT npedido, fecha, total_pedido, nif, nombre, ventas, provincia
                        FROM pedido 
                        JOIN cliente USING(nif)
                        JOIN direccion_envio USING(nif)
                        FETCH FIRST 10 ROWS ONLY) LOOP
                        
            IF fila.provincia = 'Córdoba' THEN
                DBMS_OUTPUT.PUT_LINE(fila.nif || ' ' || fila.nombre || ' ' || fila.ventas);
            
            ELSE 
                DBMS_OUTPUT.PUT_LINE(fila.fecha || ' ' || fila.total_pedido);

            END IF;
        
        END LOOP;
    
END ejercicio21;


PROCEDURE ver_ventas_cliente(input_nif cliente.nif%TYPE) IS
    
    out_ventas cliente.ventas%type;
    
    BEGIN
    
        SELECT ventas INTO out_ventas FROM cliente WHERE nif = input_nif;
        DBMS_OUTPUT.PUT_LINE(out_ventas);

END ver_ventas_cliente;


PROCEDURE ejercicio22 IS

    BEGIN ver_ventas_cliente('30000005A');
    
END ejercicio22;



FUNCTION sumar_totales_pedido(input_nif cliente.nif%TYPE) 
RETURN NUMBER AS
    
    suma NUMBER;
    
    BEGIN
    
        SELECT SUM(total_pedido) 
            INTO suma 
            FROM pedido 
            WHERE nif = input_nif;
        
        RETURN suma;

END sumar_totales_pedido;


PROCEDURE ejercicio23 IS

    BEGIN
        DBMS_OUTPUT.PUT_LINE(sumar_totales_pedido('30000005A'));

END ejercicio23;


PROCEDURE ejercicio24 IS

    BEGIN
        DBMS_OUTPUT.PUT_LINE('TO DO');
END ejercicio24;



BEGIN
--ejercicio3;
--ejercicio4;
--ejercicio5;
--ejercicio6;
--ejercicio7;
--ejercicio8;
--ejercicio9;
--ejercicio10;
--ejercicio11;
--ejercicio12;
--ejercicio13;
--ejercicio14;
--ejercicio15;
--ejercicio16;
--ejercicio17; --COMO SACAR TOTAL FACTURA?
--ejercicio18;
--ejercicio19;
--ejercicio20; -- NO HECHO, no entiendo lo de leer los envios de los pedidos que tengan mas de un envio
--ejercicio21;

--ejercicio22;
--ejercicio23;
ejercicio24;

--DBMS_OUTPUT.PUT_LINE('a');

END;



    