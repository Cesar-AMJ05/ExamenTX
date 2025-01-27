
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Convertidor_BCD is
    port ( 
        input      :   in   std_logic_vector (15 downto 0);  -- Entrada de 16 bits
        unidad     :   out  std_logic_vector (3 downto 0);
        decena     :   out  std_logic_vector (3 downto 0);
        centena    :   out  std_logic_vector (3 downto 0);
        miles      :   out  std_logic_vector (3 downto 0);
        diezmiles  :   out std_logic_vector (3 downto 0);  -- Nueva salida para diez mil
        signo      :   out std_logic  -- Indicador de n�mero negativo
    );
end entity;

architecture fum of Convertidor_BCD is
    alias Hex_Display_Data: std_logic_vector (15 downto 0) is input;
    alias d_1:    std_logic_vector (3 downto 0) is unidad;
    alias d_10:   std_logic_vector (3 downto 0) is decena;
    alias d_100:  std_logic_vector (3 downto 0) is centena;
    alias d_1000: std_logic_vector (3 downto 0) is miles;
    alias d_10000: std_logic_vector (3 downto 0) is diezmiles;  
begin
    process (Hex_Display_Data)  -- Este proceso se activa siempre que la entrada cambie.
        type fourbits is array (3 downto 0) of std_logic_vector(3 downto 0);
        variable bcd:   std_logic_vector (19 downto 0);  -- Usamos 20 bits para BCD (5 d�gitos)
        variable bint:  std_logic_vector (15 downto 0);  -- Usamos todos los 16 bits de la entrada
        variable is_negative: boolean := false; -- Variable para controlar si el n�mero es negativo
    begin
        -- Se reinicia 'bcd' a 0 cada vez que se recibe una nueva entrada
        bcd := (others => '0');      
        -- 'bint' se carga con los 16 bits de entrada.
        bint := Hex_Display_Data;  

        -- Verificaci�n si el n�mero es negativo (bit m�s significativo de la entrada)
        if bint(15) = '1' then
            is_negative := true;
            signo <= '1';  -- Activamos la se�al l�gica de n�mero negativo
            -- Convertimos el n�mero a positivo (valor absoluto) usando complemento a dos
            bint := std_logic_vector(unsigned(not bint) + 1);  -- Complemento a dos para obtener el valor absoluto
        else
            is_negative := false;
            signo <= '0';  -- Desactivamos la se�al l�gica de n�mero negativo
        end if;

        -- Conversi�n de binario a BCD con el algoritmo de "doble desplazamiento"
        for i in 0 to 15 loop
            -- Desplazamiento de 'bcd' a la izquierda y agregado del bit m�s significativo de 'bint'
            bcd(19 downto 1) := bcd(18 downto 0);
            bcd(0) := bint(15);
            bint(15 downto 1) := bint(14 downto 0);
            bint(0) := '0';

            -- Ajuste para mantener la validez BCD (si el valor de un nibble es mayor que 4, se suma 3)
            if i < 15 and bcd(3 downto 0) > "0100" then
                bcd(3 downto 0) := std_logic_vector(unsigned(bcd(3 downto 0)) + 3);
            end if;
            if i < 15 and bcd(7 downto 4) > "0100" then
                bcd(7 downto 4) := std_logic_vector(unsigned(bcd(7 downto 4)) + 3);
            end if;
            if i < 15 and bcd(11 downto 8) > "0100" then
                bcd(11 downto 8) := std_logic_vector(unsigned(bcd(11 downto 8)) + 3);
            end if;
            if i < 15 and bcd(15 downto 12) > "0100" then
                bcd(15 downto 12) := std_logic_vector(unsigned(bcd(15 downto 12)) + 3);
            end if;
            if i < 15 and bcd(19 downto 16) > "0100" then
                bcd(19 downto 16) := std_logic_vector(unsigned(bcd(19 downto 16)) + 3);
            end if;
        end loop;

        -- Asignamos las salidas BCD correspondientes a los cinco d�gitos: diez mil, millar, centenas, decenas y unidades
        d_10000 <= bcd(19 downto 16);  -- Diez mil
        d_1000  <= bcd(15 downto 12);  -- Mil
        d_100   <= bcd(11 downto 8);   -- Centenas
        d_10    <= bcd(7 downto 4);    -- Decenas
        d_1     <= bcd(3 downto 0);    -- Unidades
    end process;
end architecture;
