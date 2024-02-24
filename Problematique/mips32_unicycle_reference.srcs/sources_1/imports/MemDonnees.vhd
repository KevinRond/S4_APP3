---------------------------------------------------------------------------------------------
--
--	Université de Sherbrooke 
--  Département de génie électrique et génie informatique
--
--	S4i - APP4 
--	
--
--	Auteur: 		Marc-André Tétrault
--					Daniel Dalle
--					Sébastien Roy
-- 
---------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; -- requis pour la fonction "to_integer"
use work.MIPS32_package.all;

entity MemDonnees is
Port ( 
	clk 		: in std_logic;
	reset 		: in std_logic;
	i_MemRead 	: in std_logic;
	i_MemWrite 	: in std_logic;
    i_Addresse 	: in std_logic_vector (31 downto 0);
	i_WriteData : in std_logic_vector (127 downto 0);
    o_ReadData 	: out std_logic_vector (127 downto 0)
);
end MemDonnees;

architecture Behavioral of MemDonnees is
    signal ram_DataMemory : RAM128(0 to 255) := ( -- type défini dans le package
------------------------
-- Insérez vos donnees ici
------------------------
--  TestMirroir_data
X"00000000000000000000000012345678",
X"00000000000000000000000087654321",
X"000000000000000000000000bad0face",
X"00000000000000000000000000000001",
X"00000000000000000000000000000002",
X"00000000000000000000000000000003",
X"00000000000000000000000000000004",
X"00000000000000000000000000000005",
X"00000000000000000000000000000006",
X"0000000000000000000000005555cccc",
------------------------
-- Fin de votre code
------------------------
    others => X"00000000000000000000000000000000");

    signal s_MemoryIndex 	: integer range 0 to 255; -- 0-127
	signal s_MemoryRangeValid 	: std_logic;

begin
    process( clk )
    begin
        if clk='1' and clk'event then
            if i_MemWrite = '1' and reset = '0' and s_MemoryRangeValid = '1' then
				ram_DataMemory(s_MemoryIndex + 3)(31 downto 0) <= i_WriteData(127 downto 96);
				ram_DataMemory(s_MemoryIndex + 3)(127 downto 32) <= (others => '0');
				ram_DataMemory(s_MemoryIndex + 2)(31 downto 0) <= i_WriteData( 95 downto 64);
				ram_DataMemory(s_MemoryIndex + 2)(127 downto 32) <= (others => '0');
				ram_DataMemory(s_MemoryIndex + 1)(31 downto 0) <= i_WriteData( 63 downto 32);
				ram_DataMemory(s_MemoryIndex + 1)(127 downto 32) <= (others => '0');
				ram_DataMemory(s_MemoryIndex + 0)(31 downto 0) <= i_WriteData( 31 downto  0);
				ram_DataMemory(s_MemoryIndex + 0)(127 downto 32) <= (others => '0');
            elsif i_MemWrite = '1' and reset = '0' and s_MemoryRangeValid = '1' then
                ram_DataMemory(s_MemoryIndex) <= i_WriteData;
            end if;
        end if;
    end process;

    -- Valider que nous sommes dans le segment de m?moire, avec 256 addresses valides
    o_ReadData <= ram_DataMemory(s_MemoryIndex) when s_MemoryRangeValid = '1'
                    else (others => '0');
	
	-- valider le segment et l'alignement de l'adresse
	o_ReadData <= ram_DataMemory(s_MemoryIndex + 3)(31 downto 0) & 
					  ram_DataMemory(s_MemoryIndex + 2)(31 downto 0) & 
					  ram_DataMemory(s_MemoryIndex + 1)(31 downto 0) & 
					  ram_DataMemory(s_MemoryIndex + 0)(31 downto 0)   when s_MemoryRangeValid = '1'
					else (others => '0');


end Behavioral;

