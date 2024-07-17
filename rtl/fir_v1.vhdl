--
-- FIR Filter: Version 1.0
-- Filter Order: 50
-- Signed/Unsigned Integers Only
-- 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity firFilterv1 is
    generic(
        n: integer := 32;
        Order: integer := 4
    );
    port (
        clk: in std_logic;
        rstn: in std_logic;
        coeff: in signed ((Order + 1)*n - 1 downto 0);
        inX: in signed (n - 1 downto 0);
        outY: out signed (n - 1 downto 0)
    );
end firFilterv1;

architecture firBehav of firFilterv1 is
    type coeffArray is array (0 to Order) of signed (n - 1 downto 0);
    signal coeffH: coeffArray;

    type delayArray is array (0 to Order) of signed (n - 1 downto 0);
    signal delayZ: delayArray;

    begin
        process(coeff)
            begin
            for i in 0 to Order loop
                coeffH(i) <= coeff((i+1)*n - 1 downto i*n);
            end loop;
        end process;

        delayZ(0) <= inX;

        process (clk)
            begin
            if (rising_edge(clk)) then
                if (rstn = '1') then
                    delayZ(1 to Order) <= (others => (others => '0'));
                else
                    delayZ(1 to Order) <= delayZ(0 to Order - 1);
                end if;
            end if;
        end process;

        process (coeffH, delayZ)
            variable y: signed (n - 1 downto 0);
            begin
            y := to_signed(to_integer(delayZ(0) * coeffH(0)), outY'length);
            for i in 1 to Order loop
                y := y + to_signed(to_integer(delayZ(i) * coeffH(i)), outY'length);
            end loop;
            outY <= y;
        end process;
end firBehav;