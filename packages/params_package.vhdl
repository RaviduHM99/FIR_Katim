library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use IEEE.fixed_pkg.all;

package params_package is
    constant AXI_BITWIDTH: integer := 32;
    constant BITWIDTH: integer := 16;
    constant FRACT: integer := 15; -- Fractional Bits
    constant ORDER: integer := 50; -- Filter Order
    constant TAPS: integer := integer(integer(floor(real(ORDER/2))) + 1); -- TAPS = floor(ORDER/2) + 1
    constant DELAYFORW: integer := integer(floor(real(ORDER/2)));
    constant DELAYBITS: integer := integer(floor(real(ORDER/2)));
    constant DELAYBACK: integer := integer(integer(floor(real(ORDER/2))) + 1);

    constant DELAYPIPE: integer := 3; -- Pipeline Delay of the filter
    constant DELAYAXIFIFO: integer := 4;
    constant FILTERDELAY: integer := (TAPS + DELAYPIPE);

    type delayArray is array (natural range <>) of sfixed (BITWIDTH-FRACT-1 downto -FRACT);
    type multArray is array (natural range <>) of sfixed (BITWIDTH-FRACT-1 downto -FRACT);
    
end package params_package;
