--
-- FIR Main Module with Filter

-- FIR Filter v1.3
-- Filter Order : 50
-- AXI Stream Compatible Input/Output
-- AXI Lite Enabled Input 
--

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use IEEE.fixed_pkg.all;


entity axiliteMaster is 
    generic (
        bitWidth: integer := 32;
        bitWidthFIR: integer := 16;
        Fract: integer := 15;
        Order: integer := 5
    );
    port (
        clk: in std_logic;
        rstn: in std_logic;
 
        -- AXI Lite Input Coefficients from BRAM
        bram_axi_araddr: out std_logic_vector (bitWidth - 1 downto 0);
        bram_axi_arready: in std_logic; ---------------------------------------
        bram_axi_arvalid: out std_logic;

        bram_axi_awaddr: out std_logic_vector (bitWidth - 1 downto 0);
        bram_axi_awready: in std_logic;---------------------------------------
        bram_axi_awvalid: out std_logic;
    
        bram_axi_bresp: in std_logic_vector (1 downto 0);---------------------------------------
        bram_axi_bready: out std_logic;
        bram_axi_bvalid: in std_logic;---------------------------------------

        bram_axi_rdata: in signed (bitWidth - 1 downto 0);---------------------------------------
        bram_axi_rready: out std_logic;
        bram_axi_rvalid: in std_logic;---------------------------------------
        bram_axi_rresp: in std_logic_vector (1 downto 0);---------------------------------------

        bram_axi_wdata: out std_logic_vector (bitWidth - 1 downto 0);
        bram_axi_wready: in std_logic;---------------------------------------
        bram_axi_wvalid: out std_logic;
        bram_axi_wstrb: out std_logic_vector (3 downto 0);

        -- Reg File Outputs
        regfileOuts: out signed ((Order + 1)*bitWidthFIR - 1 downto 0);
        coeffReady: out std_logic
    );
   
end axiliteMaster;

architecture axiliteMasterBehav of axiliteMaster is
    type state_type is (iAXIL, rAddrAXIL, rAXIL, wAddrAXIL, wAXIL, wrespAXIL);
    type regfile is array (0 to Order) of signed (bitWidth -1 downto 0);

    signal state: state_type;
    signal memCoff: regfile;

    signal counter: integer;

    begin
        process(clk)
        begin
            if (rising_edge(clk)) then
                if (rstn = '1') then 
                    counter <= 0;
                else
                    counter <= counter + 1 when ((bram_axi_arready = '1') and (bram_axi_rready = '1') and (bram_axi_rresp = "00") and (counter < Order + 2)) else counter;
                end if;
            end if;
        end process;

        process(clk)
        begin
            if (rising_edge(clk)) then
                if (rstn = '1') then 
                    memCoff <= (others => (others => '0'));
                else
                    memCoff(counter) <= bram_axi_rdata when ((bram_axi_rvalid = '1') and (state = rAXIL)) else memCoff(counter);
                end if;
            end if;
        end process;

        process(clk)
        begin
            if (rising_edge(clk)) then
                if (rstn = '1') then 
                    state <= iAXIL;

                    bram_axi_araddr <= (others => '0');
                    bram_axi_arvalid <=  '0';

                    bram_axi_awaddr <= (others => '0');
                    bram_axi_awvalid <= '0';

                    bram_axi_bready <= '0';

                    bram_axi_rready <= '0';

                    bram_axi_wdata <= (others => '0');
                    bram_axi_wvalid <= '0';
                    bram_axi_wstrb <= (others => '0');
                else
                    bram_axi_araddr <= (others => '0');
                    bram_axi_arvalid <=  '0';

                    bram_axi_awaddr <= (others => '0');
                    bram_axi_awvalid <= '0';

                    bram_axi_bready <= '0';

                    bram_axi_rready <= '0';

                    bram_axi_wdata <= (others => '0');
                    bram_axi_wvalid <= '0';
                    bram_axi_wstrb <= (others => '0');

                    case state is
                        when iAXIL =>
                            bram_axi_araddr <= (others => '0');
                            bram_axi_arvalid <=  '0';

                            bram_axi_awaddr <= (others => '0');
                            bram_axi_awvalid <= '0';

                            bram_axi_bready <= '0';

                            bram_axi_rready <= '0';

                            bram_axi_wdata <= (others => '0');
                            bram_axi_wvalid <= '0';
                            bram_axi_wstrb <= (others => '0');
                        
                        when rAddrAXIL =>
                            bram_axi_araddr <= std_logic_vector(counter);
                            bram_axi_arvalid <=  '1';

                        when rAXIL =>
                            bram_axi_rready <= '1';
                        
                        when others =>
                            bram_axi_awaddr <= (others => '0');
                            bram_axi_awvalid <= '0';

                            bram_axi_bready <= '0';

                            bram_axi_wdata <= (others => '0');
                            bram_axi_wvalid <= '0';
                            bram_axi_wstrb <= (others => '0');
                    end case;

                    if ((bram_axi_arready= '1') and (state = iAXIL) and (counter < Order + 2))  then
                        state <= rAddrAXIL;
                    elsif ((bram_axi_rvalid = '1') and (state = rAddrAXIL) and (counter < Order + 2)) then
                        state <= rAXIL;
                    else 
                        state <= iAXIL;
                    end if;

                end if;
            end if;
        end process;

        process (memCoff)
        begin
            for i in 0 to Order loop
                regfileOuts((i+1)*bitWidthFIR - 1 downto i*bitWidthFIR) <= to_signed(to_integer(memCoff(i)), bitWidthFIR);
            end loop;
        end process;
        
        coeffReady <= '1' when (counter < Order + 2) else '0';
        
end axiliteMasterBehav;