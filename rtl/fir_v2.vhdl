--
-- FIR Filter: Version 1.2

-- Filter Order: 50

-- Signed/Unsigned Integers Only
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

entity firFilterv2 is
    generic(
        n: integer := 32;
        Order: integer := 50 -- Coefficients = Order + 1
    );
    port (
        clk: in std_logic;
        rstn: in std_logic;
        enable: in std_logic;
        coeff: in signed ((Order + 1)*n - 1 downto 0);
        inX: in signed (n - 1 downto 0);
        outY: out signed (n - 1 downto 0)
    );
end firFilterv2;

architecture firBehav of firFilterv2 is
    type coeffArray is array (0 to Order) of signed (n - 1 downto 0);
    signal coeffH: coeffArray;

    type delayArray is array (natural range <>) of signed (n - 1 downto 0);
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
                coeffH(i) <= coeff((i+1)*n - 1 downto i*n);
            end loop;
        end process;

        delayZ(0) <= inX;
        
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
            process (coeffH, delayZ, delayZBack, mulPipe2, a)
                type multArray is array (natural range <>) of signed (n - 1 downto 0);
                variable y: multArray (0 to Order);

                begin

                y(0) := to_signed(to_integer((delayZ(0) + delayZBack(Order)) * coeffH(0)), outY'length);
                for i in 1 to Order loop
                    y(i) := to_signed(to_integer((delayZ(i) + delayZBack(Order-i)) * coeffH(i)), outY'length);
                end loop;
                

                a(0) <= y(0);
                for i in 1 to Order loop
                    a(i) <= y(i) + mulPipe2(i-1);
                end loop;

                outY <= a(Order);
            end process;
        end generate;

        EVEN_ORDER_MULT: if ((Order mod 2) = 0) generate
            process (coeffH, delayZ, delayZBack, mulPipe2, a)
                type multArray is array (natural range <>) of signed (n - 1 downto 0);
                variable y: multArray (0 to Order);

                begin

                y(0) := to_signed(to_integer((delayZ(0) + delayZBack(Order)) * coeffH(0)), outY'length);
                for i in 1 to Order-1 loop
                    y(i) := to_signed(to_integer((delayZ(i) + delayZBack(Order-i)) * coeffH(i)), outY'length);
                end loop;
                y(Order) := to_signed(to_integer(delayZ(Order) * coeffH(Order)), outY'length);
                

                a(0) <= y(0);
                for i in 1 to Order loop
                    a(i) <= y(i) + mulPipe2(i-1);
                end loop;

                outY <= a(Order);
            end process;
        end generate;
end firBehav;