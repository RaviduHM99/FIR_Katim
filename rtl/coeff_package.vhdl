library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use IEEE.fixed_pkg.all;

package coeff_package is
    constant bitWidth: integer := 16;
    constant fract: integer := 15;
    constant Taps: integer := integer(integer(floor(real(9/2))) + 1);

    type coeffFixedArray is array (0 to Taps-1) of sfixed (bitWidth-fract-1 downto -fract);
    type coeffIntArray is array (0 to Taps-1) of signed (bitWidth - 1 downto 0);

    constant coeffFixed: coeffFixedArray:= (
        to_sfixed(0.9, bitWidth-fract-1, -fract), to_sfixed(-0.9, bitWidth-fract-1, -fract), to_sfixed(0.5, bitWidth-fract-1, -fract),
        to_sfixed(-0.06, bitWidth-fract-1, -fract), to_sfixed(0.002, bitWidth-fract-1, -fract)
    );

    constant coeffH: coeffIntArray:= (
        to_signed(2, bitWidth), to_signed(-1, bitWidth), to_signed(5, bitWidth),
        to_signed(-3, bitWidth), to_signed(4, bitWidth)
    );
end package coeff_package;
