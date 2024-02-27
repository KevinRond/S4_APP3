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

entity MemInstructions is
Port ( 
    i_addresse 		: in std_logic_vector (31 downto 0);
    o_instruction 	: out std_logic_vector (31 downto 0)
);
end MemInstructions;

architecture Behavioral of MemInstructions is
    signal ram_Instructions : RAM(0 to 255) := (
------------------------
-- Insérez votre code ici
------------------------
------------------------
-- Test d'ACS
------------------------
--X"3c011001",
--X"34240000",
--X"3c011001",
--X"34250040",
--X"3c011001",
--X"34260050",
--X"0c100009",
--X"2402000a",
--X"0000000c",
--X"20080000",
--X"20090004",
--X"70b10000", -- LWV ICI
--X"0109082b",
--X"10200008",
--X"70900000", -- LWV ICI
--X"B6118020",
--X"c20a0000", -- VMIN ICI
--X"acca0000",
--X"24840010",
--X"24c60004",
--X"25080001",
--X"0810000c",
--X"03e00008",

------------------------
-- Test UNITAIRES
------------------------
-- LWV dans un registre vide
X"3c011001", -- LA $a0, (4 premieres donnees en memoire)
X"34240000",
X"70900000", -- LWV $s0, 0($a0)

-- LWV dans un registre utilisé
X"3c011001", -- LA $a0, (donnees aux adresses 10010010 a 101001c)
X"34240010",
X"70900000", -- LWV $s0, 0($a0)

-- VMIN dans un registre vide
X"3c011001", -- LA $a1, (donnees aux adresses 10010020 a 101002C)
X"34250020",
X"70b10000", -- LWV $s1, 0($a1)
X"C22A0000", -- vmin $t0, $s1

-- VMIN dans un registre utilisé
X"3c011001", -- LA $a0, (donnees aux adresses 10010030 a 101003C)
X"34250030",
X"70b10000", -- LWV $s1, 0($a0)
X"C22A0000", -- vmin $t0, $s1

-- ADDV de 2 vecteurs
X"3c011001", -- LA $a0, (4 premieres donnees en memoire)
X"34240000",
X"70b10000", -- LWV $s1, 0($a0)

X"3c011001", -- LA $a1, (donnees aux adresses 10010040 a 101004C)
X"34250040",
X"70D20000", -- LWV $s2, 0($a1)

X"B6818020", -- ADDV $s0, $s1, $s2 




------------------------
-- Fin de votre code
------------------------
    others => X"00000000"); --> SLL $zero, $zero, 0  

    signal s_MemoryIndex : integer range 0 to 255;

begin
    -- Conserver seulement l'indexage des mots de 32-bit/4 octets
    s_MemoryIndex <= to_integer(unsigned(i_addresse(9 downto 2)));

    -- Si PC vaut moins de 127, présenter l'instruction en mémoire
    o_instruction <= ram_Instructions(s_MemoryIndex) when i_addresse(31 downto 10) = (X"00400" & "00")
                    -- Sinon, retourner l'instruction nop X"00000000": --> AND $zero, $zero, $zero  
                    else (others => '0');

end Behavioral;

