--
-- FIR Filter: Version 1.2

-- Filter Taps: 50

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
        Order: integer := 8;
        Taps: integer := integer(integer(floor(real(8/2))) + 1); -- Taps means floor(Order/2) + 1
        delayForw: integer := integer(floor(real(8/2)));
        delayBack: integer := integer(integer(floor(real(8/2))) + 1)
    );
    port (
        clk: in std_logic;
        rstn: in std_logic;
        enable: in std_logic;
        coeff: in signed (Taps*n - 1 downto 0);
        inX: in signed (n - 1 downto 0);
        outY: out signed (n - 1 downto 0)
    );
end firFilterv2;

architecture firBehav of firFilterv2 is
    type coeffArray is array (0 to Taps-1) of signed (n - 1 downto 0);
    signal coeffH: coeffArray;

    type delayArray is array (natural range <>) of signed (n - 1 downto 0);
    signal delayZ: delayArray(0 to delayForw);
    signal delayZPipe: delayArray(0 to delayForw-1);

    signal delayZBack: delayArray(0 to delayBack);
    signal delayZBackPipe: delayArray(0 to delayBack-1);

    signal mulPipe1: delayArray(0 to Taps-1);
    signal mulPipe2: delayArray(0 to Taps-1);
    signal mulPipe3: delayArray(0 to Taps-1);
    signal a: delayArray (0 to Taps-1);

    type multArray is array (natural range <>) of signed (n - 1 downto 0);
    signal delayAdd: multArray (0 to Taps-1);
    signal delayMul: multArray (0 to Taps-1);

    begin
        process(coeff)
            begin
            for i in 0 to Taps-1 loop
                coeffH(i) <= coeff((i+1)*n - 1 downto i*n);
            end loop;
        end process;

        ODD_Order_DELAY: if ((Order mod 2) = 1) generate -- Even Taps
            delayZBack(0) <= delayZ(delayForw);
            process (clk)
                begin
                if (rising_edge(clk)) then
                    if (rstn = '1') then
                        delayZ(0 to delayForw) <= (others => (others => '0'));
                        delayZBack(1 to delayBack) <= (others => (others => '0'));
                        delayZPipe(0 to delayForw-1) <= (others => (others => '0'));
                        delayZBackPipe(0 to delayBack-1) <= (others => (others => '0'));
                    else
                        if (enable = '1') then
                            delayZ(0) <= inX;
                            delayZ(1 to delayForw) <= delayZPipe(0 to delayForw - 1);
                            delayZBack(1 to delayBack) <= delayZBackPipe(0 to delayBack-1);
                            delayZPipe(0 to delayForw-1) <= delayZ(0 to delayForw-1);
                            delayZBackPipe(0 to delayBack-1) <= delayZBack(0 to delayBack-1);
                        end if;
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
                    if (rstn = '1') then
                        delayZ(0 to delayForw) <= (others => (others => '0'));
                        delayZBack(2 to delayBack) <= (others => (others => '0'));
                        delayZPipe(0 to delayForw-1) <= (others => (others => '0'));
                        delayZBackPipe(1 to delayBack-1) <= (others => (others => '0'));
                    else
                        if (enable = '1') then
                            delayZ(0) <= inX;
                            delayZ(1 to delayForw) <= delayZPipe(0 to delayForw - 1);
                            delayZBack(2 to delayBack) <= delayZBackPipe(1 to delayBack-1);
                            delayZPipe(0 to delayForw-1) <= delayZ(0 to delayForw-1);
                            delayZBackPipe(1 to delayBack-1) <= delayZBack(1 to delayBack-1);
                        end if;
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

                            for i in 0 to Taps-1 loop
                                mulPipe2(i) <= delayMul(i);
                                mulPipe3(i) <= a(i);
                            end loop;
                        end if;
                    end if;
                end if;
            end process;
        end generate;
  
        ODD_Order_MULT: if ((Order mod 2) = 1) generate -- Even Taps
            process (coeffH, delayZ, delayZBack, mulPipe1, mulPipe2, mulPipe3, a)
                begin
                delayAdd(0) <= to_signed(to_integer(delayZ(0) + delayZBack(delayBack)), outY'length);
                delayMul(0) <= to_signed(to_integer(mulPipe1(0) * coeffH(0)), outY'length);
                for i in 1 to Taps-1 loop
                    delayAdd(i) <= to_signed(to_integer(delayZ(i) + delayZBack(delayBack-i)), outY'length);
                    delayMul(i) <= to_signed(to_integer(mulPipe1(i) * coeffH(i)), outY'length);
                end loop;

                a(0) <= mulPipe2(0);
                for i in 1 to Taps-1 loop
                    a(i) <= mulPipe2(i) + mulPipe3(i-1);
                end loop;

                outY <= mulPipe3(Taps-1);
            end process;
        end generate;

        EVEN_Order_MULT: if ((Order mod 2) = 0) generate -- Odd Taps
            process (coeffH, delayZ, delayZBack, mulPipe1, mulPipe2, mulPipe3, a)
                begin
                delayAdd(0) <= to_signed(to_integer(delayZ(0) + delayZBack(delayBack)), outY'length);
                delayMul(0) <= to_signed(to_integer(mulPipe1(0) * coeffH(0)), outY'length);
                for i in 1 to Taps-2 loop
                    delayAdd(i) <= to_signed(to_integer(delayZ(i) + delayZBack(delayBack-i)), outY'length);
                    delayMul(i) <= to_signed(to_integer(mulPipe1(i) * coeffH(i)), outY'length);
                end loop;
                delayAdd(Taps-1) <= delayZ(delayForw);
                delayMul(Taps-1) <= to_signed(to_integer(mulPipe1(Taps-1) * coeffH(Taps-1)), outY'length);

                a(0) <= mulPipe2(0);
                for i in 1 to Taps-1 loop
                    a(i) <= mulPipe2(i) + mulPipe3(i-1);
                end loop;

                outY <= mulPipe3(Taps-1);
            end process;
        end generate;

end firBehav;