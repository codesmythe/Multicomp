proc read_file { filename rom_size bytes_in } { 
    upvar 1 $bytes_in bytes
    set fp [open $filename r]
    set file_data [read $fp]
    close $fp

    set lines [split $file_data "\n"]
    foreach line $lines { 
        set record_type_str [string range $line 7 8]
        set record_type [expr 0x$record_type_str]
        if { $record_type == 1} { 
            break
        }
        set byte_count_str [string range $line 1 2]
        set byte_count [expr 0x$byte_count_str]
        set addr_str [string range $line 3 6]
        set addr [expr 0x$addr_str]
        set data_str [string range $line 9 [expr 8 + $byte_count * 2]]
        set data_str_len [string length $data_str]
        # puts "addr: $addr, data_str: $data_str"
        for { set i 0 } { $i < $data_str_len } { set i [expr $i + 2] } { 
            set byte_addr [expr $addr + $i/2]
            set byte_str [string range $data_str $i [expr $i + 1]]
            # puts "  i: $i, byte_addr: $byte_addr, byte_str: $byte_str"
            set byte_val [expr 0x$byte_str]
            set bytes($byte_addr) $byte_val
        }
    }
}

proc write_vhdl { rom_name rom_size rom_hex_file bytes_in } { 
    upvar 1 $bytes_in bytes
    set addr_width [expr int(log($rom_size)/log(2.0)) - 1]
    puts "-- This ROM file has been automatically generated from the HEX file $rom_hex_file"
    puts "--     command: hex2vhdl.tcl $rom_name $rom_size $rom_hex_file"
    puts "-- Do not edit.\n"
    puts "LIBRARY ieee;"
    puts "USE ieee.std_logic_1164.all;"
    puts "USE ieee.std_logic_unsigned.all;"

    puts ""

    puts "ENTITY $rom_name IS"
    puts "PORT"
    puts "("
    puts "    address  : IN STD_LOGIC_VECTOR ($addr_width DOWNTO 0);"
    puts "    clock    : IN STD_LOGIC  := '1';"
    puts "    q        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)"
    puts ");"
    puts "END $rom_name;"
    puts ""
    puts "ARCHITECTURE SYN OF $rom_name IS"
    puts "    TYPE rom_type IS ARRAY (0 to [expr $rom_size-1]) OF std_logic_vector(7 downto 0);"
    puts ""
    puts "    SIGNAL ROM : rom_type := ("

    for { set i 0 } { $i < $rom_size } { incr i } { 
        if { [expr $i % 16] == 0 } { 
            puts -nonewline "\n        "
        }
        set byte_val $bytes($i)
        puts -nonewline "X\"[format "%02x" $byte_val]\""
        if { $i != [expr $rom_size - 1] } { 
            puts -nonewline ", "
        }
    }
    puts "\n\n    );"

    puts "BEGIN"
    puts "    PROCESS(clock)"
    puts "    BEGIN"
    puts "        IF rising_edge(clock) THEN"
    puts "            q <= ROM(conv_integer(address));"
    puts "        END IF;"
    puts "    END PROCESS;"
    puts "END SYN;"
}

proc main { argc argv } { 

    if { $argc != 3 } {
        set progname "hex2vhdl.tcl"
        puts "usage: $progname ROM_NAME ROM_SIZE ROM_HEX_FILE"
        puts ""
        puts "example: hex2vhdl.tcl Z80_BASIC_ROM 8192 ../ROMS/Z80/BASIC.HEX"
        exit 1;
    }

    set rom_name [lindex $argv 0]
    set rom_size [lindex $argv 1]
    set rom_hex_file [lindex $argv 2]
    array set bytes {}

    for { set i 0 } { $i < $rom_size } { incr i } { 
        set bytes($i) 0
    }
    read_file $rom_hex_file $rom_size bytes
    write_vhdl $rom_name $rom_size $rom_hex_file bytes
}

main $argc $argv
