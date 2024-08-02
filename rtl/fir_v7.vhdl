--
-- FIR Filter: Version 1.7

-- Filter TAPS: 50

-- Fixed Point Quantization (16 bits - 15 bits FRACTional - (-0.9 to 0.9))
-- Symmetrical Filter
-- Enable Active (AXI Stream Compatible)
-- Pipelined Design
-- Even/Odd Number of TAPS
-- Add Coefficients as a package
-- Add Generic Parameters as a package
-- 

library IEEE;
library work;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

use IEEE.fixed_pkg.all;
use work.coeff_package.all;
use work.params_package.all;

entity firFilterv7 is
    generic(
        BITWIDTH: integer := BITWIDTH;
        FRACT: integer := FRACT; -- Fractional Bits
        ORDER: integer := ORDER; -- Filter Order
        TAPS: integer := TAPS; -- TAPS = floor(ORDER/2) + 1
        DELAYFORW: integer := DELAYFORW;
        DELAYBACK: integer := DELAYBACK
    );
    port (
        clk: in std_logic;
        rstn: in std_logic;
        enable: in std_logic;
        inX: in signed (BITWIDTH - 1 downto 0);
        outY: out signed (BITWIDTH - 1 downto 0)
    );
end firFilterv7;

architecture firBehav of firFilterv7 is
    signal outYFixed: sfixed (BITWIDTH-FRACT-1 downto -FRACT);

    signal delayZ: delayArray(0 to DELAYFORW);
    signal delayZPipe: delayArray(0 to DELAYFORW-1);

    signal delayZBack: delayArray(2 to DELAYBACK);
    signal delayZBackStart1: sfixed (BITWIDTH-FRACT-1 downto -FRACT);
    signal delayZBackStart2: sfixed (BITWIDTH-FRACT-1 downto -FRACT);

    signal mulPipe1: delayArray(0 to TAPS-2);
    signal mulPipe1Last: sfixed (BITWIDTH-FRACT-1 downto -FRACT);

    signal mulPipe2: delayArray(0 to TAPS-1);
    signal mulPipe3: delayArray(0 to TAPS-1);
    signal a: delayArray (0 to TAPS-1);

    signal delayAdd: multArray (0 to TAPS-2);
    signal delayAddLast: sfixed (BITWIDTH-FRACT-1 downto -FRACT);

    signal delayMul: multArray (0 to TAPS-1);

    --signal coeffFixed: coeffFixedArray;
    begin
        --readCoffFromFile(coeffFixed); -- Initialize Filter Coefficients
        ODD_ORDER_DELAY: if ((ORDER mod 2) = 1) generate -- Even TAPS
            delayZBackStart1 <= delayZ(DELAYFORW);
            process (clk)
                begin
                if (rising_edge(clk)) then
                    if (rstn = '1') then
                        delayZ(0 to DELAYFORW) <= (others => (others => '0'));
                        delayZBack(2 to DELAYBACK) <= (others => (others => '0'));
                        delayZPipe(0 to DELAYFORW-1) <= (others => (others => '0'));
                        delayZBackStart2 <= (others => '0');
                    else
                        if (enable = '1') then
                            delayZ(0) <= to_sfixed(inX, BITWIDTH-FRACT-1, -FRACT);
                            delayZ(1 to DELAYFORW) <= delayZPipe(0 to DELAYFORW - 1);
                            delayZBackStart2 <= delayZBackStart1;
                            for i in 2 to DELAYBACK loop
                                delayZBack(i) <= delayZBackStart1;
                            end loop;
                            delayZPipe(0 to DELAYFORW-1) <= delayZ(0 to DELAYFORW-1);
                        end if;
                    end if;
                end if;
            end process;
        end generate;

        EVEN_ORDER_DELAY: if ((ORDER mod 2) = 0) generate -- Odd TAPS
            delayZBackStart1 <= delayZPipe(DELAYFORW-1);
            delayZBackStart2 <= delayZBackStart1;
            process (clk)
                begin
                if (rising_edge(clk)) then
                    if (rstn = '1') then
                        delayZ(0 to DELAYFORW) <= (others => (others => '0'));
                        delayZBack(2 to DELAYBACK) <= (others => (others => '0'));
                        delayZPipe(0 to DELAYFORW-1) <= (others => (others => '0'));
                    else
                        if (enable = '1') then
                            delayZ(0) <= to_sfixed(inX, BITWIDTH-FRACT-1, -FRACT);
                            delayZ(1 to DELAYFORW) <= delayZPipe(0 to DELAYFORW-1);
                            for i in 2 to DELAYBACK loop
                                delayZBack(i) <= delayZBackStart2;
                            end loop;
                            delayZPipe(0 to DELAYFORW-1) <= delayZ(0 to DELAYFORW-1);
                        end if;
                    end if;
                end if;
            end process;
        end generate;

        ODD_ORDER_Pipe: if ((ORDER mod 2) = 1) generate -- Even TAPS
            process (clk)
                begin
                if (rising_edge(clk)) then
                    if (rstn = '1') then
                        mulPipe1(0 to TAPS-2) <= (others => (others => '0'));
                        mulPipe2(0 to TAPS-1) <= (others => (others => '0'));
                        mulPipe3(0 to TAPS-1) <= (others => (others => '0'));
                        mulPipe1Last <= (others => '0');
                    else
                        if (enable = '1') then
                            for i in 0 to TAPS-2 loop
                                mulPipe1(i) <= delayAdd(i);
                                mulPipe2(i) <= delayMul(i);
                                mulPipe3(i) <= a(i);
                            end loop;
                            mulPipe1Last <= delayAddLast;
                            mulPipe2(TAPS-1) <= delayMul(TAPS-1);
                            mulPipe3(TAPS-1) <= a(TAPS-1);
                        end if;
                    end if;
                end if;
            end process;

            process (delayZ, delayZBack, mulPipe1, mulPipe1Last, mulPipe2, mulPipe3, a)
                begin
                for i in 0 to TAPS-2 loop
                    delayAdd(i) <= resize((delayZ(i) + delayZBack(DELAYBACK-i)), BITWIDTH-FRACT-1, -FRACT);
                    delayMul(i) <= resize((mulPipe1(i) * coeffFixed(i)), BITWIDTH-FRACT-1, -FRACT);
                end loop;
                delayAddLast <= resize((delayZ(TAPS-1) + delayZBackStart2), BITWIDTH-FRACT-1, -FRACT);
                delayMul(TAPS-1) <= resize((mulPipe1Last * coeffFixed(TAPS-1)), BITWIDTH-FRACT-1, -FRACT);

                a(0) <= mulPipe2(0);
                for i in 1 to TAPS-1 loop
                    a(i) <= resize(mulPipe2(i) + mulPipe3(i-1), BITWIDTH-FRACT-1, -FRACT);
                end loop;

                outYFixed <= mulPipe3(TAPS-1);
            end process;
        end generate;

        EVEN_ORDER_Pipe: if ((ORDER mod 2) = 0) generate -- Odd TAPS
            process (clk)
                begin
                if (rising_edge(clk)) then
                    if (rstn = '1') then
                        mulPipe1(0 to TAPS-2) <= (others => (others => '0'));
                        mulPipe2(0 to TAPS-1) <= (others => (others => '0'));
                        mulPipe3(0 to TAPS-1) <= (others => (others => '0'));
                        mulPipe1Last <= (others => '0');
                    else
                        if (enable = '1') then
                            for i in 0 to TAPS-2 loop
                                mulPipe1(i) <= delayAdd(i);
                            end loop;

                            for i in 0 to TAPS-1 loop
                                mulPipe2(i) <= delayMul(i);
                                mulPipe3(i) <= a(i);
                            end loop;
                            mulPipe1Last <= delayAddLast;
                        end if;
                    end if;
                end if;
            end process;

            
            delayAddLast <= delayZ(DELAYFORW);

            process (delayZ, delayZBack, mulPipe1, mulPipe1Last, mulPipe2, mulPipe3, a)
                begin
                for i in 0 to TAPS-2 loop
                    delayAdd(i) <= resize((delayZ(i) + delayZBack(DELAYBACK-i)), BITWIDTH-FRACT-1, -FRACT);
                    delayMul(i) <= resize((mulPipe1(i) * coeffFixed(i)), BITWIDTH-FRACT-1, -FRACT);
                end loop;
                delayMul(TAPS-1) <= resize((mulPipe1Last * coeffFixed(TAPS-1)), BITWIDTH-FRACT-1, -FRACT);

                a(0) <= mulPipe2(0);
                for i in 1 to TAPS-1 loop
                    a(i) <= resize(mulPipe2(i) + mulPipe3(i-1), BITWIDTH-FRACT-1, -FRACT);
                end loop;

                outYFixed <= mulPipe3(TAPS-1);
            end process;
        end generate;

        outY <= signed(outYFixed);
end firBehav;