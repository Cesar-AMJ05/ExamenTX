library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplexed_display is
    port (
        clk: in std_logic; 
        bcd_unidad, bcd_decena, bcd_centena, bcd_miles, bcd_diezmiles: in std_logic_vector(3 downto 0); -- Datos BCD
        signo : in std_logic; -- Bandera de signo negativo
        anodes: out std_logic_vector(7 downto 0); -- Control de los displays
        segments: out std_logic_vector(7 downto 0) -- Salida com�n de los segmentos (8 bits)
    );
end entity;

architecture behavior of multiplexed_display is
    signal current_display: integer range 0 to 7 := 0; -- Selecci�n del display actual
    signal clk_div: std_logic := '0'; -- Clk dividido
    signal counter: integer range 0 to 999 := 0; -- Contador para dividir el reloj
    signal decoded_segments: std_logic_vector(7 downto 0); -- Segmentos decodificados
begin

    -- Divisi�n del reloj a 10 kHz
    process(clk)
    begin
        if rising_edge(clk) then
            if counter = 999 then -- 100 MHz / 10 kHz = 1000 ciclos
                counter <= 0;
                clk_div <= not clk_div; -- Alternar se�al cada 10 �s
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- Cambio de display en cada flanco de clk_div
    process(clk_div)
    begin
        if rising_edge(clk_div) then
            current_display <= (current_display + 1) mod 8; -- Alternar entre los 6 displays
        end if;
    end process;

    -- Decodificaci�n de los segmentos
    process(current_display, bcd_unidad, bcd_decena, bcd_centena, bcd_miles, bcd_diezmiles,signo)
    begin
        case current_display is
            when 0 => -- Display de unidades
                case bcd_unidad is
                    when "0000" => decoded_segments <= "11000000"; -- 0
                    when "0001" => decoded_segments <= "11111001"; -- 1
                    when "0010" => decoded_segments <= "10100100"; -- 2
                    when "0011" => decoded_segments <= "10110000"; -- 3
                    when "0100" => decoded_segments <= "10011001"; -- 4
                    when "0101" => decoded_segments <= "10010010"; -- 5
                    when "0110" => decoded_segments <= "10000010"; -- 6
                    when "0111" => decoded_segments <= "11111000"; -- 7
                    when "1000" => decoded_segments <= "10000000"; -- 8
                    when "1001" => decoded_segments <= "10010000"; -- 9
                    when others => decoded_segments <= "11111111"; -- Apagado
                end case;
            when 1 => -- Display de decenas
                case bcd_decena is
                    when "0000" => decoded_segments <= "11000000"; -- 0
                    when "0001" => decoded_segments <= "11111001"; -- 1
                    when "0010" => decoded_segments <= "10100100"; -- 2
                    when "0011" => decoded_segments <= "10110000"; -- 3
                    when "0100" => decoded_segments <= "10011001"; -- 4
                    when "0101" => decoded_segments <= "10010010"; -- 5
                    when "0110" => decoded_segments <= "10000010"; -- 6
                    when "0111" => decoded_segments <= "11111000"; -- 7
                    when "1000" => decoded_segments <= "10000000"; -- 8
                    when "1001" => decoded_segments <= "10010000"; -- 9
                    when others => decoded_segments <= "11111111"; -- Apagado
                end case;
            when 2 => -- Display de centenas
                case bcd_centena is
                    when "0000" => decoded_segments <= "11000000"; -- 0
                    when "0001" => decoded_segments <= "11111001"; -- 1
                    when "0010" => decoded_segments <= "10100100"; -- 2
                    when "0011" => decoded_segments <= "10110000"; -- 3
                    when "0100" => decoded_segments <= "10011001"; -- 4
                    when "0101" => decoded_segments <= "10010010"; -- 5
                    when "0110" => decoded_segments <= "10000010"; -- 6
                    when "0111" => decoded_segments <= "11111000"; -- 7
                    when "1000" => decoded_segments <= "10000000"; -- 8
                    when "1001" => decoded_segments <= "10010000"; -- 9
                    when others => decoded_segments <= "11111111"; -- Apagado
                end case;
            when 3 => -- Display de millares
                case bcd_miles is
                    when "0000" => decoded_segments <= "11000000"; -- 0
                    when "0001" => decoded_segments <= "11111001"; -- 1
                    when "0010" => decoded_segments <= "10100100"; -- 2
                    when "0011" => decoded_segments <= "10110000"; -- 3
                    when "0100" => decoded_segments <= "10011001"; -- 4
                    when "0101" => decoded_segments <= "10010010"; -- 5
                    when "0110" => decoded_segments <= "10000010"; -- 6
                    when "0111" => decoded_segments <= "11111000"; -- 7
                    when "1000" => decoded_segments <= "10000000"; -- 8
                    when "1001" => decoded_segments <= "10010000"; -- 9
                    when others => decoded_segments <= "11111111"; -- Apagado
                end case;
            when 4 => -- Display de diez millares
                case bcd_diezmiles is
                    when "0000" => decoded_segments <= "11000000"; -- 0
                    when "0001" => decoded_segments <= "11111001"; -- 1
                    when "0010" => decoded_segments <= "10100100"; -- 2
                    when "0011" => decoded_segments <= "10110000"; -- 3
                    when "0100" => decoded_segments <= "10011001"; -- 4
                    when "0101" => decoded_segments <= "10010010"; -- 5
                    when "0110" => decoded_segments <= "10000010"; -- 6
                    when "0111" => decoded_segments <= "11111000"; -- 7
                    when "1000" => decoded_segments <= "10000000"; -- 8
                    when "1001" => decoded_segments <= "10010000"; -- 9
                    when others => decoded_segments <= "11111111"; -- Apagado
                end case;
            when 5 => -- Display de signo
                if signo = '1' then
                    decoded_segments <= "10111111"; -- Signo negativo "-"
                else
                    decoded_segments <= "11111111"; -- Apagado
                end if;
            when others =>
                decoded_segments <= "11111111"; -- Apagado
        end case;
    end process;

    anodes <= "11111110" when current_display = 0 else -- Activar "unidades"
              "11111101" when current_display = 1 else -- Activar "decenas"
              "11111011" when current_display = 2 else -- Activar "centenas"
              "11110111" when current_display = 3 else -- Activar "miles"
              "11101111" when current_display = 4 else -- Activar "diezmiles"
              "11011111" when current_display = 5 else -- Activar "signo"
              "11111111" when current_display = 6 else
              "11111111"; -- Apagar no utilizado

    -- Salida de los segmentos comunes
    segments <= decoded_segments;

end architecture;
