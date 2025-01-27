library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopModule is
    Port (
        clk            : in  STD_LOGIC;            
        reset          : in  STD_LOGIC;            -- Bot�n de reinicio
        A              : in  STD_LOGIC_VECTOR(7 downto 0); -- vector A
        B              : in  STD_LOGIC_VECTOR(7 downto 0); -- vector B
        led            : out STD_LOGIC_VECTOR(15 downto 0); -- Resultado acumulado (salida)
        anodes         : out STD_LOGIC_VECTOR(7 downto 0); -- Control de anodos
        segments       : out STD_LOGIC_VECTOR(7 downto 0); -- Control de segmentos
        segments2      : out STD_LOGIC_VECTOR(7 downto 0)  -- Copia de segmentos
    );
end TopModule;

architecture Behavioral of TopModule is

    -- Se�ales internas
    signal internal_segments : STD_LOGIC_VECTOR(7 downto 0); -- Se�al para manejar segmentos
    signal acumulado         : STD_LOGIC_VECTOR(15 downto 0); -- Resultado acumulado interno
    signal bcd_unidad        : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_decenas       : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_centenas      : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_miles         : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_diezmiles     : STD_LOGIC_VECTOR(3 downto 0);
    signal signo             : STD_LOGIC; -- Indicador de n�mero negativo

begin

    -- Instancia del Multiplicador y Acumulador
    multiplicador_inst : entity work.Multiplicador
        port map (
            clk       => clk,
            reset     => reset,
            A         => A,
            B         => B,
            acumulado => acumulado
        );

    -- Instancia del Conversor Binario a BCD
    Convertidor_BCD_inst : entity work.Convertidor_BCD
        port map (
            input       => acumulado,
            unidad      => bcd_unidad,
            decena      => bcd_decenas,
            centena     => bcd_centenas,
            miles       => bcd_miles,
            diezmiles   => bcd_diezmiles,
            signo       => signo
        );

    -- Instancia del M�dulo de Display Multiplexado
    multiplexed_display_inst : entity work.multiplexed_display
        port map (
            clk             => clk,
            bcd_unidad      => bcd_unidad,
            bcd_decena      => bcd_decenas,
            bcd_centena     => bcd_centenas,
            bcd_miles       => bcd_miles,
            bcd_diezmiles   => bcd_diezmiles,
            signo           => signo,
            anodes          => anodes,
            segments        => internal_segments -- Usamos una se�al interna
        );

    -- Conexi�n de internal_segments a las salidas
    segments <= internal_segments; -- Conecta a la salida original
    segments2 <= internal_segments; -- Copia en la nueva salida

    -- Conexi�n de acumulado a la salida
    led <= acumulado;

end Behavioral;


