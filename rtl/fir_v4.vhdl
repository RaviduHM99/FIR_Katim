--
-- FIR Filter: Version 1.4

-- Filter Taps: 50

-- Fixed Point Quantization (16 bits - 15 bits fractional - (-0.9 to 0.9))
-- Symmetrical Filter
-- Enable Active (AXI Stream Compatible)
-- Pipelined Design
-- Even/Odd Number of Taps
-- Remove Resets in Data Vectors but for Add Resets for Pipeline
-- 

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

use IEEE.fixed_pkg.all;

entity firFilterv4 is
    generic(
        bitWidth: integer := 16;
        fract: integer := 15;
        Order: integer := 8;
        Taps: integer := integer(integer(floor(real(8/2))) + 1); -- Taps means floor(Order/2) + 1
        delayForw: integer := integer(floor(real(8/2)));
        delayBack: integer := integer(integer(floor(real(8/2))) + 1)
    );
    port (
        clk: in std_logic;
        rstn: in std_logic;
        enable: in std_logic;
        coeff: in signed (Taps*bitWidth - 1 downto 0);
        inX: in signed (bitWidth - 1 downto 0);
        outY: out signed (bitWidth - 1 downto 0)
    );
end firFilterv4;

architecture firBehav of firFilterv4 is
    type fixedPointArray is array (0 to Taps-1) of sfixed (bitWidth-fract-1 downto -fract);
    signal coeffFixed: fixedPointArray;

    signal outYFixed: sfixed (bitWidth-fract-1 downto -fract);

    type delayArray is array (natural range <>) of sfixed (bitWidth-fract-1 downto -fract);
    signal delayZ: delayArray(0 to delayForw);
    signal delayZPipe: delayArray(0 to delayForw-1);

    signal delayZBack: delayArray(0 to delayBack);
    signal delayZBackPipe: delayArray(0 to delayBack-1);

    signal mulPipe1: delayArray(0 to Taps-1);
    signal mulPipe2: delayArray(0 to Taps-1);
    signal mulPipe3: delayArray(0 to Taps-1);
    signal a: delayArray (0 to Taps-1);

    type multArray is array (natural range <>) of sfixed (bitWidth-fract-1 downto -fract);
    signal delayAdd: multArray (0 to Taps-1);
    signal delayMul: multArray (0 to Taps-1);

    begin
        process(coeff)
            begin
            for i in 0 to Taps-1 loop
                coeffFixed(i) <= to_sfixed(coeff((i+1)*bitWidth - 1 downto i*bitWidth), bitWidth-fract-1, -fract);
            end loop;
        end process;
        
        ODD_Order_DELAY: if ((Order mod 2) = 1) generate -- Even Taps
            delayZBack(0) <= delayZ(delayForw);
            process (clk)
                begin
                if (rising_edge(clk)) then
                    if (enable = '1') then
                        delayZ(0) <= to_sfixed(inX, bitWidth-fract-1, -fract);
                        delayZ(1 to delayForw) <= delayZPipe(0 to delayForw - 1);
                        delayZBack(1 to delayBack) <= delayZBackPipe(0 to delayBack-1);
                        delayZPipe(0 to delayForw-1) <= delayZ(0 to delayForw-1);
                        delayZBackPipe(0 to delayBack-1) <= delayZBack(0 to delayBack-1);
                    end if;
                end if;
            end process;
        end generate;

        EVEN_Order_DELAY: if ((Order mod 2) = 0) generate -- Odd Taps
            delayZBack(0) <= delayZ(delayForw);
            delayZBackPipe(0) <= delayZBack(0);
            delayZBack(1) <= delayZBackPipe(0);
            process (clk)
                begin
                if (rising_edge(clk)) then
                    if (enable = '1') then
                        delayZ(0) <= to_sfixed(inX, bitWidth-fract-1, -fract);
                        delayZ(1 to delayForw) <= delayZPipe(0 to delayForw - 1);
                        delayZBack(2 to delayBack) <= delayZBackPipe(1 to delayBack-1);
                        delayZPipe(0 to delayForw-1) <= delayZ(0 to delayForw-1);
                        delayZBackPipe(1 to delayBack-1) <= delayZBack(1 to delayBack-1);
                    end if;
                end if;
            end process;
        end generate;

        ODD_Order_Pipe: if ((Order mod 2) = 1) generate -- Even Taps
            process (clk)
                begin
                if (rising_edge(clk)) then
                    if (rstn = '1') then
                        mulPipe1(0 to Taps-1) <= (others => (others => '0'));
                        mulPipe2(0 to Taps-1) <= (others => (others => '0'));
                        mulPipe3(0 to Taps-1) <= (others => (others => '0'));
                    else
                        if (enable = '1') then
                            for i in 0 to Taps-1 loop
                                mulPipe1(i) <= delayAdd(i);
                                mulPipe2(i) <= delayMul(i);
                                mulPipe3(i) <= a(i);
                            end loop;
                        end if;
                    end if;
                end if;
            end process;
        end generate;

        EVEN_Order_Pipe: if ((Order mod 2) = 0) generate -- Odd Taps
            mulPipe1(Taps-1) <= delayAdd(Taps-1);
            process (clk)
                begin
                if (rising_edge(clk)) then
                    if (rstn = '1') then
                        mulPipe1(0 to Taps-2) <= (others => (others => '0'));
                        mulPipe2(0 to Taps-1) <= (others => (others => '0'));
                        mulPipe3(0 to Taps-1) <= (others => (others => '0'));
                    else
                        if (enable = '1') then
                            for i in 0 to Taps-2 loop
                                mulPipe1(i) <= delayAdd(i);
                            end loop;

                            for j in 0 to Taps-1 loop
                                mulPipe2(j) <= delayMul(j);
                                mulPipe3(j) <= a(j);
                            end loop;
                        end if;
                    end if;
                end if;
            end process;
        end generate;

        ODD_Order_MULT: if ((Taps mod 2) = 1) generate
            process (coeffFixed, delayZ, delayZBack, mulPipe1, mulPipe2, mulPipe3, a)
                begin
                delayAdd(0) <= resize((delayZ(0) + delayZBack(delayBack)), bitWidth-fract-1, -fract);
                delayMul(0) <= resize((mulPipe1(0) * coeffFixed(0)), bitWidth-fract-1, -fract);
                for i in 1 to Taps-1 loop
                    delayAdd(i) <= resize((delayZ(i) + delayZBack(delayBack-i)), bitWidth-fract-1, -fract);
                    delayMul(i) <= resize((mulPipe1(i) * coeffFixed(i)), bitWidth-fract-1, -fract);
                end loop;

                a(0) <= mulPipe2(0);
                for i in 1 to Taps-1 loop
                    a(i) <= resize(mulPipe2(i) + mulPipe3(i-1), bitWidth-fract-1, -fract);
                end loop;

                outYFixed <= mulPipe3(Taps-1);
            end process;
        end generate;

        EVEN_Order_MULT: if ((Taps mod 2) = 0) generate
            process (coeffFixed, delayZ, delayZBack, mulPipe1, mulPipe2, mulPipe3, a)
                begin
                delayAdd(0) <= resize((delayZ(0) + delayZBack(delayBack)), bitWidth-fract-1, -fract);
                delayMul(0) <= resize((mulPipe1(0) * coeffFixed(0)), bitWidth-fract-1, -fract);
                for i in 1 to Taps-2 loop
                    delayAdd(i) <= resize((delayZ(i) + delayZBack(delayBack-i)), bitWidth-fract-1, -fract);
                    delayMul(i) <= resize((mulPipe1(i) * coeffFixed(i)), bitWidth-fract-1, -fract);
                end loop;
                delayAdd(Taps-1) <= delayZ(delayForw);
                delayMul(Taps-1) <= resize((mulPipe1(Taps-1) * coeffFixed(Taps-1)), bitWidth-fract-1, -fract);

                a(0) <= mulPipe2(0);
                for i in 1 to Taps-1 loop
                    a(i) <= resize(mulPipe2(i) + mulPipe3(i-1), bitWidth-fract-1, -fract);
                end loop;

                outYFixed <= mulPipe3(Taps-1);
            end process;
        end generate;

        outY <= signed(outYFixed);
end firBehav;