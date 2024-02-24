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

entity MemDonneesWideDual is
Port ( 
	clk 		: in std_logic;
	reset 		: in std_logic;
	i_MemRead	: in std_logic;
	i_MemWrite 	: in std_logic;
    i_Addresse 	: in std_logic_vector (31 downto 0);
	i_WriteData : in std_logic_vector (31 downto 0);
    o_ReadData 	: out std_logic_vector (31 downto 0);
	
	-- ports pour accès à large bus, adresse partagée
	i_MemReadWide       : in std_logic;
	i_MemWriteWide 		: in std_logic;
	i_WriteDataWide 	: in std_logic_vector (127 downto 0);
    o_ReadDataWide 		: out std_logic_vector (127 downto 0)
);
end MemDonneesWideDual;

architecture Behavioral of MemDonneesWideDual is
    signal ram_DataMemory : RAM(0 to 255) := ( -- type défini dans le package
------------------------
-- Insérez vos donnees ici
------------------------

------------------------
-- Fin de votre code
------------------------
    others => X"00000000");

    signal s_MemoryIndex 	: integer range 0 to 255; -- 0-127
	signal s_MemoryRangeValid 	: std_logic;
	
    signal s_WideMemoryRangeValid  : std_logic;

begin
    -- Transformation de l'adresse en entier à interval fixés
    s_MemoryIndex 	<= to_integer(unsigned(i_Addresse(9 downto 2)));
	s_MemoryRangeValid <= '1' when i_Addresse(31 downto 10) = (X"10010" & "00") else '0'; 


	s_WideMemoryRangeValid <= '1' when (i_Addresse(31 downto 10) = (X"10010" & "00") and i_Addresse(3 downto 2) = "00") else '0'; 
	
	-- message de simulation
	-- Dans une véritable mémoire SRAM, l'octet "bas" sors toujours sur les même pattes physiques. 
	-- Par exemple, sur un bus 32-bits et en accès 8-bits, l'octet de l'adresse 0x00 sera aux bits (7 downto 0), 
	-- et celui de l'adresse 0x01 sur (15 downto 8). Donc typiquement, l'adresse "vue" à la mémoire sera 0x00 dans les deux
	-- cas, et un multiplexeur viendra replacer la donnée au LSB du banc de registres.
	-- C'est la même chose pour les mémoires à large bus, comme notre cas ici. En assembleur, 
	-- il est plus réaliste d'incrémenter par bloc d'accès en blocs de 128 bits.
	-- L'assertion à la ligne suivante vous averti si cette condition n'est pas respectée pour la mémoire large modélisée pour la problématique. 
	-- Il est possible de modifier le modèle et retirer ce message, mais alors le modèle ne sera pas réaliste.
	process(clk, i_MemWriteWide,  i_MemReadWide, i_Addresse) --or i_MemReadWide = '1')
	begin
        if clk='0' and clk'event then -- sur front descendant
			if(i_MemWriteWide = '1' or i_MemReadWide = '1') then
				assert (i_Addresse(3 downto 0) = "0000") report "mauvais alignement de l'adresse pour une ecriture large" severity failure;
			end if;
	   end if;
	end process;
	
	-- Partie pour l'écriture
	process( clk )
    begin
        if clk='1' and clk'event then
            if i_MemWriteWide = '1' and reset = '0' and s_WideMemoryRangeValid = '1' then
				ram_DataMemory(s_MemoryIndex + 3) <= i_WriteDataWide(127 downto 96);
				ram_DataMemory(s_MemoryIndex + 2) <= i_WriteDataWide( 95 downto 64);
				ram_DataMemory(s_MemoryIndex + 1) <= i_WriteDataWide( 63 downto 32);
				ram_DataMemory(s_MemoryIndex + 0) <= i_WriteDataWide( 31 downto  0);
            elsif i_MemWrite = '1' and reset = '0' and s_MemoryRangeValid = '1' then
                ram_DataMemory(s_MemoryIndex) <= i_WriteData;
            end if;
        end if;
    end process;

    -- Valider que nous sommes dans le segment de mémoire, avec 256 addresses valides
    o_ReadData <= ram_DataMemory(s_MemoryIndex) when s_MemoryRangeValid = '1'
                    else (others => '0');
	
	-- valider le segment et l'alignement de l'adresse
	o_ReadDataWide <= ram_DataMemory(s_MemoryIndex + 3) & 
					  ram_DataMemory(s_MemoryIndex + 2) & 
					  ram_DataMemory(s_MemoryIndex + 1) & 
					  ram_DataMemory(s_MemoryIndex + 0)   when s_WideMemoryRangeValid = '1'
					else (others => '0');

end Behavioral;
