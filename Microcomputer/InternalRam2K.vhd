LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY InternalRam2K IS
    PORT
    (
        address        : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        clock          : IN STD_LOGIC := '1';
        data           : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        wren           : IN STD_LOGIC;
        q              : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END InternalRam2K;

ARCHITECTURE SYN OF InternalRam2K IS
   TYPE ram_type IS ARRAY (0 to 2047) OF std_logic_vector (7 downto 0);
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
