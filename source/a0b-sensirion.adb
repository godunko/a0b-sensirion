--
--  Copyright (C) 2026, Vadim Godunko
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

pragma Ada_2022;

pragma Restrictions (No_Elaboration_Code);

package body A0B.Sensirion with Pure is

   use type A0B.Types.Unsigned_8;
   use type A0B.Types.Unsigned_32;

   CRC8_INIT : constant := 16#FF#;

   type CRC8_Table is array (A0B.Types.Unsigned_8) of A0B.Types.Unsigned_8;

   CRC8_LOOKUP_TABLE : constant CRC8_Table :=
     (16#00#, 16#31#, 16#62#, 16#53#, 16#C4#, 16#F5#, 16#A6#, 16#97#,
      16#B9#, 16#88#, 16#DB#, 16#EA#, 16#7D#, 16#4C#, 16#1F#, 16#2E#,
      16#43#, 16#72#, 16#21#, 16#10#, 16#87#, 16#B6#, 16#E5#, 16#D4#,
      16#FA#, 16#CB#, 16#98#, 16#A9#, 16#3E#, 16#0F#, 16#5C#, 16#6D#,
      16#86#, 16#B7#, 16#E4#, 16#D5#, 16#42#, 16#73#, 16#20#, 16#11#,
      16#3F#, 16#0E#, 16#5D#, 16#6C#, 16#FB#, 16#CA#, 16#99#, 16#A8#,
      16#C5#, 16#F4#, 16#A7#, 16#96#, 16#01#, 16#30#, 16#63#, 16#52#,
      16#7C#, 16#4D#, 16#1E#, 16#2F#, 16#B8#, 16#89#, 16#DA#, 16#EB#,
      16#3D#, 16#0C#, 16#5F#, 16#6E#, 16#F9#, 16#C8#, 16#9B#, 16#AA#,
      16#84#, 16#B5#, 16#E6#, 16#D7#, 16#40#, 16#71#, 16#22#, 16#13#,
      16#7E#, 16#4F#, 16#1C#, 16#2D#, 16#BA#, 16#8B#, 16#D8#, 16#E9#,
      16#C7#, 16#F6#, 16#A5#, 16#94#, 16#03#, 16#32#, 16#61#, 16#50#,
      16#BB#, 16#8A#, 16#D9#, 16#E8#, 16#7F#, 16#4E#, 16#1D#, 16#2C#,
      16#02#, 16#33#, 16#60#, 16#51#, 16#C6#, 16#F7#, 16#A4#, 16#95#,
      16#F8#, 16#C9#, 16#9A#, 16#AB#, 16#3C#, 16#0D#, 16#5E#, 16#6F#,
      16#41#, 16#70#, 16#23#, 16#12#, 16#85#, 16#B4#, 16#E7#, 16#D6#,
      16#7A#, 16#4B#, 16#18#, 16#29#, 16#BE#, 16#8F#, 16#DC#, 16#ED#,
      16#C3#, 16#F2#, 16#A1#, 16#90#, 16#07#, 16#36#, 16#65#, 16#54#,
      16#39#, 16#08#, 16#5B#, 16#6A#, 16#FD#, 16#CC#, 16#9F#, 16#AE#,
      16#80#, 16#B1#, 16#E2#, 16#D3#, 16#44#, 16#75#, 16#26#, 16#17#,
      16#FC#, 16#CD#, 16#9E#, 16#AF#, 16#38#, 16#09#, 16#5A#, 16#6B#,
      16#45#, 16#74#, 16#27#, 16#16#, 16#81#, 16#B0#, 16#E3#, 16#D2#,
      16#BF#, 16#8E#, 16#DD#, 16#EC#, 16#7B#, 16#4A#, 16#19#, 16#28#,
      16#06#, 16#37#, 16#64#, 16#55#, 16#C2#, 16#F3#, 16#A0#, 16#91#,
      16#47#, 16#76#, 16#25#, 16#14#, 16#83#, 16#B2#, 16#E1#, 16#D0#,
      16#FE#, 16#CF#, 16#9C#, 16#AD#, 16#3A#, 16#0B#, 16#58#, 16#69#,
      16#04#, 16#35#, 16#66#, 16#57#, 16#C0#, 16#F1#, 16#A2#, 16#93#,
      16#BD#, 16#8C#, 16#DF#, 16#EE#, 16#79#, 16#48#, 16#1B#, 16#2A#,
      16#C1#, 16#F0#, 16#A3#, 16#92#, 16#05#, 16#34#, 16#67#, 16#56#,
      16#78#, 16#49#, 16#1A#, 16#2B#, 16#BC#, 16#8D#, 16#DE#, 16#EF#,
      16#82#, 16#B3#, 16#E0#, 16#D1#, 16#46#, 16#77#, 16#24#, 16#15#,
      16#3B#, 16#0A#, 16#59#, 16#68#, 16#FF#, 16#CE#, 16#9D#, 16#AC#);

   -----------------
   -- Compute_CRC --
   -----------------

   function Compute_CRC
     (Data : A0B.Types.Arrays.Unsigned_8_Array) return A0B.Types.Unsigned_8
   is
      CRC : A0B.Types.Unsigned_8 := CRC8_INIT;

   begin
      for C of Data loop
         CRC := CRC8_LOOKUP_TABLE (CRC xor C);
      end loop;

      return CRC;
   end Compute_CRC;

   -----------------
   -- Compute_CRC --
   -----------------

   function Compute_CRC
     (Byte_1 : A0B.Types.Unsigned_8;
      Byte_2 : A0B.Types.Unsigned_8) return A0B.Types.Unsigned_8
   is
      CRC : A0B.Types.Unsigned_8 := CRC8_INIT;

   begin
      CRC := CRC8_LOOKUP_TABLE (CRC xor Byte_1);
      CRC := CRC8_LOOKUP_TABLE (CRC xor Byte_2);

      return CRC;
   end Compute_CRC;

   -----------------------
   -- Decode_I2C_Packet --
   -----------------------

   procedure Decode_I2C_Packet
     (Packet  : A0B.Types.Arrays.Unsigned_8_Array;
      Data    : out A0B.Types.Arrays.Unsigned_8_Array;
      Length  : out A0B.Types.Unsigned_32;
      Success : in out Boolean;
      Unknown : Boolean := False)
   is
      Current : A0B.Types.Unsigned_32 := Packet'First;

   begin
      Length := 0;

      if not Success then
         return;
      end if;

      while Current + 2 <= Packet'Last loop
         if Packet (Current + 2)
           /= Compute_CRC (Packet (Current), Packet (Current + 1))
         then
            exit;
         end if;

         if Length <= Data'Length then
            Data (Data'First + Length) := Packet (Current);
         end if;

         Length := @ + 1;

         if Length <= Data'Length then
            Data (Data'First + Length) := Packet (Current + 1);
         end if;

         Length := @ + 1;

         Current := Current + 3;
      end loop;

      if Current < Packet'Last and not Unknown then
         Success := False;
      end if;
   end Decode_I2C_Packet;

   -----------------------
   -- Encode_I2C_Packet --
   -----------------------

   procedure Encode_I2C_Packet
     (Data   : A0B.Types.Arrays.Unsigned_8_Array;
      Packet : out A0B.Types.Arrays.Unsigned_8_Array;
      Length : out A0B.Types.Unsigned_32)
   is
      Current : A0B.Types.Unsigned_32 := Data'First;

   begin
      Length := 0;

      while Current + 1 <= Data'Last loop
         if Length < Packet'Length then
            Packet (Packet'First + Length) := Data (Current);
         end if;

         Length := @ + 1;

         if Length < Packet'Length then
            Packet (Packet'First + Length) := Data (Current + 1);
         end if;

         Length := @ + 1;

         if Length < Packet'Length then
            Packet (Packet'First + Length) :=
              Compute_CRC (Data (Current), Data (Current + 1));
         end if;

         Length := @ + 1;

         Current := Current + 2;
      end loop;

      if Current <= Data'Last then
         if Length < Packet'Length then
            Packet (Packet'First + Length) := Data (Current);
         end if;

         Length := @ + 1;

         if Length < Packet'Length then
            Packet (Packet'First + Length) := 0;
         end if;

         Length := @ + 1;

         if Length < Packet'Length then
            Packet (Packet'First + Length) :=
              Compute_CRC (Data (Current), 0);
         end if;

         Length := @ + 1;
      end if;
   end Encode_I2C_Packet;

end A0B.Sensirion;
