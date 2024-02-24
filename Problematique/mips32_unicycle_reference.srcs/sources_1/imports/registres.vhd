---------------------------------------------------------------------------------------------
--
--	Universit� de Sherbrooke 
--  D�partement de g�nie �lectrique et g�nie informatique
--
--	S4i - APP4 
--	
--
--	Auteur: 		Marc-Andr� T�trault
--					Daniel Dalle
--					S�bastien Roy
-- 
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS32_package.all;

entity BancRegistres is
    Port ( clk       : in  std_logic;
           reset     : in  std_logic;
           i_RS1     : in  std_logic_vector (4 downto 0);
           i_RS2     : in  std_logic_vector (4 downto 0);
           i_Wr_DAT  : in  std_logic_vector (127 downto 0);
           i_WDest   : in  std_logic_vector (4 downto 0);
           i_WE 	 : in  std_logic;
           o_RS1_DAT : out std_logic_vector (127 downto 0);
           o_RS2_DAT : out std_logic_vector (127 downto 0));
end BancRegistres;

architecture comport of BancRegistres is
    signal regs: RAM(0 to 23) := (21 => X"100103FC", -- registre $SP
                                others => (others => '0'));
    signal vregs: VRAM(0 to 7) := (others => (others => '0'));
    
    signal s_RS1   : integer range 0 to 31 := 0;
    signal s_RS2   : integer range 0 to 31 := 0;
    signal s_WDest : integer range 0 to 31 := 0;
    
begin

    s_RS1 <= TO_INTEGER(unsigned(i_RS1));
    s_RS2 <= TO_INTEGER(unsigned(i_RS2));
    s_WDest <= TO_INTEGER(unsigned(i_WDest));
    
    process( clk )
    begin
        if clk='1' and clk'event then
            if i_WE = '1' and reset = '0' and i_WDest /= "00000" then
                if (s_WDest < 16) then
                    regs(s_WDest) <= i_Wr_DAT(31 downto 0);
                elsif (s_WDest >= 16 AND s_WDest <= 23) then
                    vregs(s_WDest - 16) <= i_Wr_DAT;
                else
                    regs(s_WDest - 8) <= i_Wr_DAT(31 downto 0);
                end if;
            end if;
        end if;
    end process;
    
    process(regs, vregs, s_RS1)
    begin
        if (s_RS1 < 16) then
            o_RS1_DAT(31 downto 0) <= regs(s_RS1);
            o_RS1_DAT(127 downto 32) <= (others => '0'); 
        elsif (s_RS1 >= 16 AND s_RS1 <= 23) then
            o_RS1_DAT <= vregs(S_RS1 - 16);
        else
            o_RS1_DAT(31 downto 0) <= regs(s_RS1 - 8);
            o_RS1_DAT(127 downto 32) <= (others => '0'); 
        end if;
    end process;
    
    process(regs, vregs, s_RS2)
    begin
        if (s_RS2 < 16) then
            o_RS2_DAT(31 downto 0) <= regs(s_RS2);
            o_RS2_DAT(127 downto 32) <= (others => '0'); 
        elsif (s_RS2 >= 16 AND s_RS1 <= 23) then
            o_RS2_DAT <= vregs(S_RS2 - 16);
        else
            o_RS2_DAT(31 downto 0) <= regs(s_RS2 - 8);
            o_RS2_DAT(127 downto 32) <= (others => '0'); 
        end if;
    end process;
    
end comport;

