LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY InternalRam1K IS
    PORT
    (
        address        : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
        clock          : IN STD_LOGIC := '1';
        data           : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        wren           : IN STD_LOGIC;
        q              : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END InternalRam1K;

ARCHITECTURE SYN OF InternalRam1K IS
   TYPE ram_type IS ARRAY (0 to 1023) OF std_logic_vector (7 downto 0);
   SIGNAL RAM : ram_type;

BEGIN
   process(clock)
   begin
       if rising_edge(clock) then 
           if (wren = '1') then 
               RAM(conv_integer(address)) <= data;
           end if;
           q <= RAM(conv_integer(address));
       end if;
   end process;

END SYN;
