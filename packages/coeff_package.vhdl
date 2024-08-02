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

use work.params_package.all;

package coeff_package is
    type coeffFixedArray is array (0 to TAPS-1) of sfixed (BITWIDTH-FRACT-1 downto -FRACT);
    --type coeffIntArray is array (0 to TAPS-1) of signed (BITWIDTH - 1 downto 0);

    -- constant coeffFixed: coeffFixedArray := ( --Order = 8/9
    --     to_sfixed(-0.005069883484836009736, bitWidth-fract-1, -fract),
    --     to_sfixed(-0.02935816274751619492, bitWidth-fract-1, -fract),
    --     to_sfixed(0.1107437912657967261, bitWidth-fract-1, -fract),
    --     to_sfixed(-0.2193406809054964379, bitWidth-fract-1, -fract),
    --     to_sfixed(0.2709749631927091951, bitWidth-fract-1, -fract)
    -- );

    -- constant coeffFixed: coeffFixedArray := ( --Order = 10/11
    --     to_sfixed(0.00000000000000000074, bitWidth-fract-1, -fract),
    --     to_sfixed(0.00930428314501814506, bitWidth-fract-1, -fract),
    --     to_sfixed(0.04757776613441743602, bitWidth-fract-1, -fract),
    --     to_sfixed(0.12236354636114463168, bitWidth-fract-1, -fract),
    --     to_sfixed(0.20224655842984026743, bitWidth-fract-1, -fract),
    --     to_sfixed(0.23701569185915891125, bitWidth-fract-1, -fract)
    -- );

    constant coeffFixed: coeffFixedArray := ( --Order = 50/51
        to_sfixed(0.00000000000000000062, bitWidth-fract-1, -fract),
        to_sfixed(0.00065039553667658849, bitWidth-fract-1, -fract),
        to_sfixed(0.00124025457575402506, bitWidth-fract-1, -fract),
        to_sfixed(0.00154168856597617070, bitWidth-fract-1, -fract),
        to_sfixed(0.00121680726432840322, bitWidth-fract-1, -fract),
        to_sfixed(-0.00000000000000000131, bitWidth-fract-1, -fract),
        to_sfixed(-0.00201071739618534709, bitWidth-fract-1, -fract),
        to_sfixed(-0.00414071057825654044, bitWidth-fract-1, -fract),
        to_sfixed(-0.00521455172196734398, bitWidth-fract-1, -fract),
        to_sfixed(-0.00401474661944180387, bitWidth-fract-1, -fract),
        to_sfixed(0.00000000000000000309, bitWidth-fract-1, -fract),
        to_sfixed(0.00605036948985557526, bitWidth-fract-1, -fract),
        to_sfixed(0.01187422064884591753, bitWidth-fract-1, -fract),
        to_sfixed(0.01431762164553206963, bitWidth-fract-1, -fract),
        to_sfixed(0.01062571675306874137, bitWidth-fract-1, -fract),
        to_sfixed(-0.00000000000000000531, bitWidth-fract-1, -fract),
        to_sfixed(-0.01526134569229613443, bitWidth-fract-1, -fract),
        to_sfixed(-0.02969111861349210332, bitWidth-fract-1, -fract),
        to_sfixed(-0.03594907682468056337, bitWidth-fract-1, -fract),
        to_sfixed(-0.02723073776903542700, bitWidth-fract-1, -fract),
        to_sfixed(0.00000000000000000709, bitWidth-fract-1, -fract),
        to_sfixed(0.04400877614770940666, bitWidth-fract-1, -fract),
        to_sfixed(0.09741972657663529322, bitWidth-fract-1, -fract),
        to_sfixed(0.14882523646951956175, bitWidth-fract-1, -fract),
        to_sfixed(0.18597856426149592113, bitWidth-fract-1, -fract),
        to_sfixed(0.19952725455991524028, bitWidth-fract-1, -fract)
    );

    -- constant coeffH: coeffIntArray:= (
    --     to_signed(2, bitWidth),
    --     to_signed(-1, bitWidth),
    --     to_signed(5, bitWidth),
    --     to_signed(-3, bitWidth),
    --     to_signed(4, bitWidth)
    -- );

    procedure readCoffFromFile(signal coeffFixed: out coeffFixedArray);
end package coeff_package;

package body coeff_package is
    procedure readCoffFromFile(signal coeffFixed: out coeffFixedArray) is 
        file inputFile: text;
        variable inputData: real;
        variable fileLine : line;
        variable file_status: file_open_status;
        begin
            file_open(file_status, inputFile, "C:/Projects/FIR_Katim/packages/filter_coefficients.txt", read_mode);
            File_Avialablity_Assertion: assert  file_status = open_ok report "Filter Coefficients File not Found" severity failure;
            
            for i in 0 to TAPS-1 loop
                readline(inputFile, fileLine);
                read(fileLine, inputData);
                coeffFixed(i) <= to_sfixed(inputData, BITWIDTH-FRACT-1, -FRACT);
            end loop;

            report "End of Filter Coefficients File Reached" severity note;
            file_close(inputFile);
    end procedure readCoffFromFile;
end coeff_package;
