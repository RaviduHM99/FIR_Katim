--
-- FIR Filter: Version 1.3

-- Filter Order: 50

-- Fixed Point Quantization (16 bits - 15 bits fractional - (-0.9 to 0.9))
-- Symmetrical Filter
-- Enable Active (AXI Stream Compatible)
-- Pipelined Design
-- Even/Odd Number of Taps
-- 

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

use IEEE.fixed_pkg.all;

entity firFilterv3 is
    generic(
        n: integer := 16;
        fract: integer :=15;
        Order: integer := 3 -- Coefficients = Order + 1
    );
    port (
        clk: in std_logic;
        rstn: in std_logic;
        enable: in std_logic;
        coeff: in signed ((Order + 1)*n - 1 downto 0);
        inX: in signed (n - 1 downto 0);
        outY: out signed (n - 1 downto 0)
    );
end firFilterv3;

architecture firBehav of firFilterv3 is
    type fixedPointArray is array (0 to Order) of sfixed (n-fract-1 downto -fract);
    signal coeffFixed: fixedPointArray;

    signal outYFixed: sfixed (n-fract-1 downto -fract);

    type delayArray is array (natural range <>) of sfixed (n-fract-1 downto -fract);
    signal delayZ: delayArray(0 to Order);
    signal delayZPipe: delayArray(0 to Order-1);

    signal delayZBack: delayArray(0 to Order);
    signal delayZBackPipe: delayArray(0 to Order-1);

    signal mulPipe1: delayArray(0 to Order-1);
    signal mulPipe2: delayArray(0 to Order-1);
    signal a: delayArray (0 to Order);

    begin
        process(coeff)
            begin
            for i in 0 to Order loop
                coeffFixed(i) <= to_sfixed(coeff((i+1)*n - 1 downto i*n), n-fract-1, -fract);
            end loop;
        end process;
        
        delayZ(0) <= to_sfixed(inX, n-fract-1, -fract);
        
        ODD_ORDER_DELAY: if ((Order mod 2) = 1) generate
            process (clk)
                begin
                if (rising_edge(clk)) then
                    if (rstn = '1') then
                        delayZ(1 to Order) <= (others => (others => '0'));
                        delayZBack(0 to Order) <= (others => (others => '0'));
                        delayZPipe(0 to Order-1) <= (others => (others => '0'));
                        delayZBackPipe(0 to Order-1) <= (others => (others => '0'));
                    else
                        if (enable = '1') then
                            delayZ(1 to Order) <= delayZPipe(0 to Order - 1);
                            delayZBack(0) <= delayZ(Order);
                            delayZBack(1 to Order) <= delayZBackPipe(0 to Order - 1);
                            delayZPipe(0 to Order-1) <= delayZ(0 to Order - 1);
                            delayZBackPipe(0 to Order-1) <= delayZBack(0 to Order - 1);
                        end if;
                    end if;
                end if;
            end process;
        end generate;

        EVEN_ORDER_DELAY: if ((Order mod 2) = 0) generate
            delayZBack(0) <= delayZ(Order);
            process (clk)
                begin
                if (rising_edge(clk)) then
                    if (rstn = '1') then
                        delayZ(1 to Order) <= (others => (others => '0'));
                        delayZBack(1 to Order) <= (others => (others => '0'));
                        delayZPipe(0 to Order-1) <= (others => (others => '0'));
                        delayZBackPipe(0 to Order-1) <= (others => (others => '0'));
                    else
                        if (enable = '1') then
                            delayZ(1 to Order) <= delayZPipe(0 to Order - 1);
                            delayZBack(1 to Order) <= delayZBackPipe(0 to Order - 1);
                            delayZPipe(0 to Order-1) <= delayZ(0 to Order - 1);
                            delayZBackPipe(0 to Order-1) <= delayZBack(0 to Order - 1);
                        end if;
                    end if;
                end if;
            end process;
        end generate;

        process (clk)
            begin
            if (rising_edge(clk)) then
                if (rstn = '1') then
                    mulPipe1(0 to Order-1) <= (others => (others => '0'));
                    mulPipe2(0 to Order-1) <= (others => (others => '0'));
                else
                    if (enable = '1') then
                        mulPipe2(0 to Order-1) <= mulPipe1(0 to Order-1);
                        for i in 0 to Order-1 loop
                            mulPipe1(i) <= a(i);
                        end loop;
                    end if;
                end if;
            end if;
        end process;

        ODD_ORDER_MULT: if ((Order mod 2) = 1) generate
            process (coeffFixed, delayZ, delayZBack, mulPipe2, a)
                type multArray is array (natural range <>) of sfixed (n-fract-1 downto -fract);
                variable y: multArray (0 to Order);

                begin

                y(0) := resize((delayZ(0) + delayZBack(Order)) * coeffFixed(0), n-fract-1, -fract);
                for i in 1 to Order loop
                    y(i) := resize((delayZ(i) + delayZBack(Order-i)) * coeffFixed(i), n-fract-1, -fract);
                end loop;
                

                a(0) <= y(0);
                for i in 1 to Order loop
                    a(i) <= resize(y(i) + mulPipe2(i-1), n-fract-1, -fract);
                end loop;

                outYFixed <= a(Order);
            end process;
        end generate;

        EVEN_ORDER_MULT: if ((Order mod 2) = 0) generate
            process (coeffFixed, delayZ, delayZBack, mulPipe2, a)
                type multArray is array (natural range <>) of sfixed (n-fract-1 downto -fract);
                variable y: multArray (0 to Order);

                begin

                y(0) := resize((delayZ(0) + delayZBack(Order)) * coeffFixed(0),  n-fract-1, -fract);
                for i in 1 to Order-1 loop
                    y(i) := resize(((delayZ(i) + delayZBack(Order-i)) * coeffFixed(i)), n-fract-1, -fract);
                end loop;
                y(Order) := resize((delayZ(Order) * coeffFixed(Order)), n-fract-1, -fract);
                
                a(0) <= y(0);
                for i in 1 to Order loop
                    a(i) <= resize(y(i) + mulPipe2(i-1), n-fract-1, -fract);
                end loop;

                outYFixed <= a(Order);
            end process;
        end generate;

        outY <= signed(outYFixed);
end firBehav;