-- ***********************************************************************
-- FIR Filter: Version 1.8

-- Filter TAPS: 50

-- Fixed Point Quantization (16 bits - 15 bits FRACTional - (-0.9 to 0.9))
-- Symmetrical Filter
-- Enable Active (AXI Stream Compatible)
-- Pipelined Design
-- Even/Odd Number of TAPS
-- Add Coefficients as a package
-- Add Generic Parameters as a package
-- Add AXI Interface for input/output
-- ***********************************************************************

library IEEE;
library work;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use IEEE.fixed_pkg.all;
use work.coeff_package.all;
use work.params_package.all;

entity firFixedAXI is
    generic (
        AXI_BITWIDTH: integer := AXI_BITWIDTH;
        BITWIDTH: integer := BITWIDTH;
        FRACT: integer := FRACT; -- Fractional Bits
        ORDER: integer := ORDER; -- Filter Order
        TAPS: integer := TAPS; -- TAPS = floor(ORDER/2) + 1
        DELAYFORW: integer := DELAYFORW;
        DELAYBITS: integer := DELAYBITS;
        DELAYBACK: integer := DELAYBACK
    );
    port (
        clk   : in std_logic;
        rstn : in std_logic;
        
        -- AXI Stream Input
        s_axis_tdata : in signed (AXI_BITWIDTH - 1 downto 0);
        s_axis_tready : out std_logic;
        s_axis_tvalid : in std_logic;
        s_axis_tlast : in std_logic;

        -- AXI Stream Output
        m_axis_tdata : out signed (AXI_BITWIDTH - 1 downto 0);
        m_axis_tready : in std_logic;
        m_axis_tvalid : out std_logic;
        m_axis_tlast : out std_logic
    );
end entity;

architecture rtl of firFixedAXI is
    signal enable: std_logic;
    signal inX, outY: signed (BITWIDTH - 1 downto 0);
    signal delayCount: signed (DELAYBITS - 1 downto 0);
    signal shiftVal: std_logic_vector (FILTERDELAY - 1 downto 0);
    signal shiftLast: std_logic_vector (FILTERDELAY - 1 downto 0);
begin
    enable <= '1' when (m_axis_tready = '1') else '0';
    
    process (clk)
    begin
        if (rising_edge(clk)) then
            if (rstn = '1') then
                delayCount <= (others => '0');
            else
                if ((s_axis_tvalid = '1') and (m_axis_tready = '1')) then
                    delayCount <= delayCount + 1;
                end if;
            end if;
        end if;
    end process;

    process (clk)
    begin
        if (rising_edge(clk)) then
            if (rstn = '1') then
                shiftVal <= (others => '0');
                shiftLast <= (others => '0');
            else
                if (s_axis_tvalid = '1') and (m_axis_tready = '1') then
                    shiftVal(0) <= '1';
                    shiftVal(FILTERDELAY - 1 downto 1) <= shiftVal(FILTERDELAY - 2 downto 0);
                else
                    shiftVal(0) <= '0';
                    shiftVal(FILTERDELAY - 1 downto 1) <= shiftVal(FILTERDELAY - 2 downto 0);
                end if;
                shiftLast(0) <= s_axis_tlast;
                shiftLast(FILTERDELAY - 1 downto 1) <= shiftLast(FILTERDELAY - 2 downto 0);
            end if;
        end if;
    end process;

    m_axis_tvalid <= shiftVal(FILTERDELAY-1);   --'1' when ((s_axis_tvalid = '1') and (to_integer(delayCount) > FILTERDELAY - 1)) else '0';
    s_axis_tready <= m_axis_tready;
    m_axis_tlast <= shiftLast(FILTERDELAY-1);   --s_axis_tlast;

    inX <= resize(s_axis_tdata, BITWIDTH);

    m_axis_tdata <= resize(outY, AXI_BITWIDTH);

    DUT: entity work.firFilterv7
    generic map (
      BITWIDTH => BITWIDTH,
      FRACT => FRACT,
      ORDER => ORDER,
      TAPS => TAPS,
      DELAYFORW => DELAYFORW,
      DELAYBACK => DELAYBACK
  ) port map (
      clk => clk,
      rstn => rstn,
      enable => enable,
      inX => inX,
      outY => outY
  );
end architecture;