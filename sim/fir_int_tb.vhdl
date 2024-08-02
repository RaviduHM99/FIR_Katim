--
-- FIR Filter TestBench Integer: Version 1.0

-- Filter Taps: 50

-- Signed/Unsigned Integers Only
-- Symmetrical Filter
-- Enable Active (AXI Stream Compatible)
-- Pipelined Design
-- Even/Odd Number of Taps
-- Add Coefficients as a package
-- 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library work;
use work.coeff_package.all;

entity fir_int_tb is
end entity fir_int_tb;

architecture testBench of fir_int_tb is
    constant n: integer := 16;
    constant Order: integer := 9;
    constant Taps: integer := integer(integer(floor(real(9/2))) + 1); -- Taps means floor(Order/2) + 1
    constant delayForw: integer := integer(floor(real(9/2)));
    constant delayBack: integer := integer(integer(floor(real(9/2))) + 1);

    component firFilterv6
        generic(
            n: integer := 16;
            Order: integer := 9;
            Taps: integer := integer(integer(floor(real(9/2))) + 1); -- Taps means floor(Order/2) + 1
            delayForw: integer := integer(floor(real(9/2)));
            delayBack: integer := integer(integer(floor(real(9/2))) + 1)
        );
        port(
            clk: in std_logic;
            rstn: in std_logic;
            enable: in std_logic;
            inX: in signed (n - 1 downto 0);
            outY: out signed (n - 1 downto 0)
        );
    end component;

    signal clk, rstn: std_logic:= '0';
    signal enable: std_logic:= '0';
    signal inX: signed (n - 1 downto 0):= (others => '0');
    signal outY: signed (n - 1 downto 0);

    constant clk_period : time := 10 ns;
    begin
        DUT: entity work.firFilterv6
          generic map (
            n => n,
            Order => Order,
            Taps => Taps,
            delayForw => delayForw,
            delayBack => delayBack
        ) port map (
            clk => clk,
            rstn => rstn,
            enable => enable,
            inX => inX,
            outY => outY
        );

        clk_process: process
        begin
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end process;

        stim_process: process
        begin
            wait until rising_edge(clk);
            rstn <= '1';

            wait for clk_period*2;
            rstn <= '0';
            enable <= '1';
            inX <= to_signed(15, n);
            wait for clk_period;

            for i in 21 to 25 loop
                inX <= to_signed(i, n);
                wait for clk_period;
            end loop;

        
            wait for clk_period*5;
            wait; -- stop simulation
        end process;


end testBench ; -- testBench