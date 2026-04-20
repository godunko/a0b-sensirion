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

   CRC8_POLYNOMIAL : constant := 16#31#;
   CRC8_INIT       : constant := 16#FF#;

   -----------------
   -- Compute_CRC --
   -----------------

   function Compute_CRC
     (Data : A0B.Types.Arrays.Unsigned_8_Array) return A0B.Types.Unsigned_8
   is
      CRC : A0B.Types.Unsigned_8 := CRC8_INIT;

   begin
      for C of Data loop
         CRC := @ xor C;

         for J in reverse 0 .. 7 loop
            if (CRC and 16#80#) /= 0 then
               CRC := A0B.Types.Shift_Left (@, 1) xor CRC8_POLYNOMIAL;

            else
               CRC := A0B.Types.Shift_Left (@, 1);
            end if;
         end loop;
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

      procedure Process_Byte (B : A0B.Types.Unsigned_8) with Inline_Always;

      ------------------
      -- Process_Byte --
      ------------------

      procedure Process_Byte (B : A0B.Types.Unsigned_8) is
      begin
         CRC := @ xor B;

         for J in reverse 0 .. 7 loop
            if (CRC and 16#80#) /= 0 then
               CRC := A0B.Types.Shift_Left (@, 1) xor CRC8_POLYNOMIAL;

            else
               CRC := A0B.Types.Shift_Left (@, 1);
            end if;
         end loop;
      end Process_Byte;

   begin
      Process_Byte (Byte_1);
      Process_Byte (Byte_2);

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
