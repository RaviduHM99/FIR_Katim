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

entity fir_fixed_tb is
end entity fir_fixed_tb;

architecture testBench of fir_fixed_tb is
    component firFilterv7
        generic(
            BITWIDTH: integer := BITWIDTH;
            FRACT: integer := FRACT; -- FRACTional Bits
            ORDER: integer := ORDER; -- Filter Order
            TAPS: integer := TAPS; -- TAPS = floor(ORDER/2) + 1
            DELAYFORW: integer := DELAYFORW;
            DELAYBACK: integer := DELAYBACK
        );
        port(
            clk: in std_logic;
            rstn: in std_logic;
            enable: in std_logic;
            inX: in signed (BITWIDTH - 1 downto 0);
            outY: out signed (BITWIDTH - 1 downto 0)
        );
    end component;

    signal clk, rstn: std_logic:= '0';
    signal enable: std_logic:= '0';
    signal inX: signed (BITWIDTH - 1 downto 0) := (others => '0');
    signal outY: signed (BITWIDTH - 1 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    signal inputNum: integer := 0;
    signal readDone: std_logic := '0';
    signal writeDone: std_logic := '0';
    signal assertDone: std_logic := '0';

    --variable coeffFixed: coeffFixedArray;
    begin
        --readCoffFromFile(coeffFixed); -- Initialize Filter Coefficients
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
                enable <= '1';

                while not endfile(inputFile) loop
                    inputNum <= inputNum + 1;
                    readline(inputFile, fileLine);
                    read(fileLine, inputData);
                    inX <= signed(to_sfixed(inputData, BITWIDTH-FRACT-1, -FRACT));
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

                wait until rising_edge(clk);
                wait for CLK_PERIOD*2;
                wait for CLK_PERIOD; -- after 1 cycle delay

                if (ORDER mod 2 = 0) then
                    wait for CLK_PERIOD*((ORDER/2) + 3); -- Here 2 cycle delay means start and end flipflops
                    for i in 0 to inputNum loop
                        outputData := to_real(sfixed(outY))/2.0**FRACT; -- Convert to Real Number Also need to Divide By Fractional Bits 
                        write(fileLine, outputData);
                        writeline(outputFile, fileLine);
                        wait for CLK_PERIOD;
                    end loop;
                else
                    wait for CLK_PERIOD*((ORDER-1)/2 + 3);
                    for i in 0 to inputNum+1 loop
                        outputData := to_real(sfixed(outY))/2.0**FRACT; -- Convert to Real Number Also need to Divide By Fractional Bits 
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
  
        -- Assertion_Process: process
        --     file inputFileAssert: text;
        --     file outputFileAssert: text;

        --     variable inputData: real;
        --     variable fileLineIn : line;
        --     variable outputData: real;
        --     variable fileLineOut : line;
        --     variable Readfile_status: file_open_status;
        --     variable Writefile_status: file_open_status;

        --     variable numLine: integer := 0;
        --     begin
        --         wait until writeDone = '1';

        --         while (assertDone = '0') loop -- Here after READ and WRITE Process
        --             file_open(Readfile_status, inputFileAssert, "C:/Projects/FIR_Katim/sim/filter_reference.txt", read_mode);
        --             InFile_Avialablity_Assertion: assert  Readfile_status = open_ok report "Input File not Found" severity failure;
        --             file_open(Writefile_status, outputFileAssert, "C:/Projects/FIR_Katim/sim/filter_outputs.txt", read_mode);
        --             OutFile_Avialablity_Assertion: assert  Writefile_status = open_ok report "Output File not Found" severity failure;

        --             while not endfile(outputFileAssert) loop
        --                 numLine := numLine + 1;
        --                 readline(inputFileAssert, fileLineIn);
        --                 read(fileLineIn, inputData);
        --                 readline(outputFileAssert, fileLineOut);
        --                 read(fileLineOut, outputData);
        --                 fir_filter_assertion: assert inputData = outputData report "Data Mismatched!!! Expected Data :" & real'image(inputData) & " but Output Data: " & real'image(outputData) severity error;
        --                 if inputData = outputData  then
        --                     report "Data Valid!!!!!!! Input Data ID: " & integer'image(numLine) severity note;
        --                 end if;
        --             end loop;

        --             assertDone <= '1';
        --         end loop;
        --     wait;
        -- end process;
 
end testBench ; -- testBench