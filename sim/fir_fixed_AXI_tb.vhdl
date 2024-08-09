--
-- FIR Filter TestBench Integer: Version 1.0

-- Filter Taps: 50

-- Use TextIO Library to get Inputs and Outputs from a textfile
-- Use Separate Process for read and write data
-- Self Checking Testbench - Assertion
-- 
-- 
-- 
-- 
-- 

library IEEE;
library work;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use IEEE.fixed_pkg.all;
use std.textio.all;
use IEEE.std_logic_textio.all;

use work.coeff_package.all;
use work.params_package.all;

entity fir_fixed_AXI_tb is
end entity fir_fixed_AXI_tb;

architecture testBench of fir_fixed_AXI_tb is
    component firFixedAXI
        generic(
            AXI_BITWIDTH: integer := AXI_BITWIDTH;
            BITWIDTH: integer := BITWIDTH;
            FRACT: integer := FRACT; -- Fractional Bits
            ORDER: integer := ORDER; -- Filter Order
            TAPS: integer := TAPS; -- TAPS = floor(ORDER/2) + 1
            DELAYFORW: integer := DELAYFORW;
            DELAYBITS: integer := DELAYBITS;
            DELAYBACK: integer := DELAYBACK
        );
        port(
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
    end component;

    signal clk, rstn: std_logic:= '0';
    -- AXI Stream Input
    signal s_axis_tdata :signed (AXI_BITWIDTH - 1 downto 0) := (others => '0');
    signal s_axis_tready :std_logic;
    signal s_axis_tvalid :std_logic := '0';
    signal s_axis_tlast :std_logic := '0';

    -- AXI Stream Output
    signal m_axis_tdata :signed (AXI_BITWIDTH - 1 downto 0);
    signal m_axis_tready :std_logic := '0';
    signal m_axis_tvalid :std_logic;
    signal m_axis_tlast :std_logic;

    constant CLK_PERIOD : time := 10 ns;

    constant inputNum: integer := ORDER;
    signal readDone: std_logic := '0';
    signal writeDone: std_logic := '0';
    signal assertDone: std_logic := '0';

    --variable coeffFixed: coeffFixedArray;
    begin
        --readCoffFromFile(coeffFixed); -- Initialize Filter Coefficients
        DUT: entity work.firFixedAXI
          generic map (
            AXI_BITWIDTH => AXI_BITWIDTH,
            BITWIDTH => BITWIDTH,
            FRACT => FRACT,
            ORDER => ORDER,
            TAPS => TAPS,
            DELAYFORW => DELAYFORW,
            DELAYBITS => DELAYBITS,
            DELAYBACK => DELAYBACK
        ) port map (
            clk => clk,
            rstn => rstn,

            s_axis_tdata => s_axis_tdata,
            s_axis_tready => s_axis_tready,
            s_axis_tvalid => s_axis_tvalid,
            s_axis_tlast => s_axis_tlast,
    
            m_axis_tdata => m_axis_tdata,
            m_axis_tready => m_axis_tready,
            m_axis_tvalid => m_axis_tvalid,
            m_axis_tlast => m_axis_tlast
        );

        clk_process: process
        begin
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end process;

        Read_Process: process
            file inputFile: text;
            variable inputData: real;
            variable fileLine : line;
            variable file_status: file_open_status;

            begin
                file_open(file_status, inputFile, "C:/Projects/FIR_Katim/sim/filter_inputs.txt", read_mode);
                READ_File_Avialablity_Assertion: assert  file_status = open_ok report "Input File not Found" severity failure;

                wait until rising_edge(clk);
                rstn <= '1';
                wait for CLK_PERIOD*2;
                rstn <= '0';

                s_axis_tvalid <= '1';
                s_axis_tlast <= '0';
                m_axis_tready <= '1';

                while not endfile(inputFile) loop
                    readline(inputFile, fileLine);
                    read(fileLine, inputData);
                    s_axis_tdata <= resize(signed(to_sfixed(inputData, BITWIDTH-FRACT-1, -FRACT)), AXI_BITWIDTH);
                    wait for CLK_PERIOD;
                end loop;

                report "End of Read File Reached" severity note;
                file_close(inputFile);
                readDone <= '1';
                wait;
        end process;

        
        Write_Process: process
            file outputFile: text;
            variable outputData: real;
            variable fileLine : line;
            variable file_status: file_open_status;

            begin
                file_open(file_status, outputFile, "C:/Projects/FIR_Katim/sim/filter_outputs.txt", write_mode);
                WRITE_File_Avialablity_Assertion: assert  file_status = open_ok report "Output File not Found" severity failure;

                if (ORDER mod 2 = 0) then
                    wait until rising_edge(m_axis_tvalid);
                    for i in 0 to inputNum loop
                        outputData := to_real(sfixed(m_axis_tdata))/2.0**FRACT; -- Convert to Real Number Also need to Divide By Fractional Bits 
                        write(fileLine, outputData);
                        writeline(outputFile, fileLine);
                        wait for CLK_PERIOD;
                    end loop;
                else
                    wait until rising_edge(m_axis_tvalid);
                    for i in 0 to inputNum+1 loop
                        outputData := to_real(sfixed(resize(m_axis_tdata, BITWIDTH)))/2.0**FRACT; -- Convert to Real Number Also need to Divide By Fractional Bits 
                        write(fileLine, outputData);
                        writeline(outputFile, fileLine);
                        wait for CLK_PERIOD;
                    end loop;
                end if;

                report "End of Write File Reached" severity note;
                file_close(outputFile);
                writeDone <= '1';
                wait;
        end process;
 
end testBench ; -- testBench