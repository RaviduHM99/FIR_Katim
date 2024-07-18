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

use IEEE.fixed_pkg.all;


entity firMain is 
    generic (
        bitWidth: integer := 32;
        bitWidthFIR: integer := 16;
        Fract: integer := 15;
        Order: integer := 5
    );
    port (
        in clk: std_logic;
        in rstn: std_logic;

        -- AXI Stream Input X
        out fifoIN_tready: std_logic;
        in fifoIN_tvalid: std_logic;
        in fifoIN_tdata: signed (bitWidth - 1 downto 0);
        in fifoIN_tlast: std_logic;

        -- AXI Stream Output Y
        in fifoIN_tready: std_logic;
        out fifoIN_tvalid: std_logic;
        out fifoIN_tdata: signed (bitWidth - 1 downto 0);
        out fifoIN_tlast: std_logic;   

        -- AXI Lite Input Coefficients from BRAM
        out bram_axi_araddr: std_logic_vector (bitWidth - 1 downto 0);
        in bram_axi_arready: std_logic;
        out bram_axi_arvalid: std_logic;

        out bram_axi_awaddr: std_logic_vector (bitWidth - 1 downto 0);
        in bram_axi_awready: std_logic;
        out bram_axi_awvalid: std_logic;
    
        in bram_axi_bresp: std_logic_vector (1 downto 0);
        out bram_axi_bready: std_logic;
        in bram_axi_bvalid: std_logic;

        in bram_axi_rdata: std_logic_vector (bitWidth - 1 downto 0);
        out bram_axi_rready: std_logic;
        in bram_axi_rvalid: std_logic;
        in bram_axi_rresp: std_logic_vector (1 downto 0);

        out bram_axi_wdata: std_logic_vector (bitWidth - 1 downto 0);
        in bram_axi_wready: std_logic;
        out bram_axi_wvalid: std_logic;
        out bram_axi_wstrb: std_logic_vector (3 downto 0);
    );

        
end firMain;