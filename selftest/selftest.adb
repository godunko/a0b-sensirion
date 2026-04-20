--
--  Copyright (C) 2026, Vadim Godunko
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

pragma Ada_2022;

with Ada.Command_Line;
with Ada.Text_IO;
with GNAT.Source_Info;

with A0B.Sensirion;
with A0B.Types.Arrays;

procedure Selftest is

   procedure Test_SCD4x;

   procedure Check_Codec
     (Encoded : A0B.Types.Arrays.Unsigned_8_Array;
      Decoded : A0B.Types.Arrays.Unsigned_8_Array;
      Name    : String);

   procedure Assert
     (Condition : Boolean;
      Name      : String;
      Message   : String;
      Location  : String := GNAT.Source_Info.Source_Location);

   ------------
   -- Assert --
   ------------

   procedure Assert
     (Condition : Boolean;
      Name      : String;
      Message   : String;
      Location  : String := GNAT.Source_Info.Source_Location) is
   begin
      if not Condition then
         Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
         Ada.Text_IO.Put_Line
           ("FAIL: " & Name & ": " & Message & " at " & Location);
      end if;
   end Assert;

   -----------------
   -- Check_Codec --
   -----------------

   procedure Check_Codec
     (Encoded : A0B.Types.Arrays.Unsigned_8_Array;
      Decoded : A0B.Types.Arrays.Unsigned_8_Array;
      Name    : String)
   is
      use type A0B.Types.Arrays.Unsigned_8_Array;
      use type A0B.Types.Unsigned_32;

      Encoder_Buffer : A0B.Types.Arrays.Unsigned_8_Array (Decoded'Range);
      Decoder_Buffer : A0B.Types.Arrays.Unsigned_8_Array (Encoded'Range);
      Length         : A0B.Types.Unsigned_32;
      Success        : Boolean := True;

   begin
      A0B.Sensirion.Decode_I2C_Packet
        (Packet  => Encoded,
         Data    => Encoder_Buffer,
         Length  => Length,
         Success => Success);

      Assert (Success, Name, "decoder failure");
      Assert (Length = Encoder_Buffer'Length, Name, "incorrect length");
      Assert (Encoder_Buffer = Decoded, Name, "wrong decoded data");

      A0B.Sensirion.Encode_I2C_Packet
        (Data   => Decoded,
         Packet => Decoder_Buffer,
         Length => Length);

      Assert (Length = Decoder_Buffer'Length, Name, "incorrect length");
      Assert (Decoder_Buffer = Encoded, Name, "wrong encoded data");
   end Check_Codec;

   ----------------
   -- Test_SCD4x --
   ----------------

   procedure Test_SCD4x is
      --  Test vectors are derived from examples in the SCD4x datasheet.

      read_measurement_Response_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 9) :=
          [16#01#, 16#F4#, 16#33#,
           16#66#, 16#67#, 16#A2#,
           16#5E#, 16#B9#, 16#3C#];
      read_measurement_Response_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 6) :=
          [16#01#, 16#F4#,
           16#66#, 16#67#,
           16#5E#, 16#B9#];

      set_temperature_offset_Input_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#07#, 16#E6#, 16#48#];
      set_temperature_offset_Input_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#07#, 16#E6#];

      get_temperature_offset_Response_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#09#, 16#12#, 16#63#];
      get_temperature_offset_Response_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#09#, 16#12#];

      set_sensor_altitude_Input_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#07#, 16#9E#, 16#09#];
      set_sensor_altitude_Input_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#07#, 16#9E#];

      get_sensor_altitude_Response_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#04#, 16#4C#, 16#42#];
      get_sensor_altitude_Response_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#04#, 16#4C#];

      set_ambient_pressure_Input_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#03#, 16#DB#, 16#42#];
      set_ambient_pressure_Input_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#03#, 16#DB#];

      perform_forced_recalibration_Input_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#01#, 16#E0#, 16#B4#];
      perform_forced_recalibration_Input_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#01#, 16#E0#];

      perform_forced_recalibration_Response_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#7F#, 16#CE#, 16#7B#];
      perform_forced_recalibration_Response_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#7F#, 16#CE#];

      set_automatic_self_calibration_enabled_Input_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#00#, 16#01#, 16#B0#];
      set_automatic_self_calibration_enabled_Input_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#00#, 16#01#];

      get_automatic_self_calibration_enabled_Response_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#00#, 16#00#, 16#81#];
      get_automatic_self_calibration_enabled_Response_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#00#, 16#00#];

      set_automatic_self_calibration_target_Input_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#01#, 16#B3#, 16#99#];
      set_automatic_self_calibration_target_Input_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#01#, 16#B3#];

      get_automatic_self_calibration_target_Response_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#01#, 16#A4#, 16#4D#];
      get_automatic_self_calibration_target_Response_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#01#, 16#A4#];

      get_data_ready_status_Response_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#80#, 16#00#, 16#A2#];
      get_data_ready_status_Response_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#80#, 16#00#];

      get_serial_number_Response_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 9) :=
          [16#F8#, 16#96#, 16#31#,
           16#9F#, 16#07#, 16#C2#,
           16#3B#, 16#BE#, 16#89#];
      get_serial_number_Response_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 6) :=
          [16#F8#, 16#96#,
           16#9F#, 16#07#,
           16#3B#, 16#BE#];

      get_sensor_variant_SCD40_Response_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#04#, 16#40#, 16#3F#];
      get_sensor_variant_SCD40_Response_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#04#, 16#40#];
      get_sensor_variant_SCD41_Response_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#14#, 16#40#, 16#51#];
      get_sensor_variant_SCD41_Response_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#14#, 16#40#];
      get_sensor_variant_SCD43_Response_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#54#, 16#41#, 16#E9#];
      get_sensor_variant_SCD43_Response_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#54#, 16#41#];

      set_automatic_self_calibration_initial_period_Input_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#00#, 16#4C#, 16#C1#];
      set_automatic_self_calibration_initial_period_Input_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#00#, 16#4C#];

      set_automatic_self_calibration_standard_period_Input_Encoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 3) :=
          [16#00#, 16#9C#, 16#C5#];
      set_automatic_self_calibration_standard_period_Input_Decoded : constant
        A0B.Types.Arrays.Unsigned_8_Array (1 .. 2) :=
          [16#00#, 16#9C#];

   begin
      Check_Codec
        (Encoded => read_measurement_Response_Encoded,
         Decoded => read_measurement_Response_Decoded,
         Name    => "Read Measurement");
      Check_Codec
        (Encoded => set_temperature_offset_Input_Encoded,
         Decoded => set_temperature_offset_Input_Decoded,
         Name    => "Set Temperature Offset");
      Check_Codec
        (Encoded => get_temperature_offset_Response_Encoded,
         Decoded => get_temperature_offset_Response_Decoded,
         Name    => "Get Temperature Offset");
      Check_Codec
        (Encoded => set_sensor_altitude_Input_Encoded,
         Decoded => set_sensor_altitude_Input_Decoded,
         Name    => "Set Sensor Altitude");
      Check_Codec
        (Encoded => get_sensor_altitude_Response_Encoded,
         Decoded => get_sensor_altitude_Response_Decoded,
         Name    => "Get Sensor Altitude");
      Check_Codec
        (Encoded => set_ambient_pressure_Input_Encoded,
         Decoded => set_ambient_pressure_Input_Decoded,
         Name    => "Set Ambient Pressure");
      Check_Codec
        (Encoded => perform_forced_recalibration_Input_Encoded,
         Decoded => perform_forced_recalibration_Input_Decoded,
         Name    => "Perform Forced Recalibration Input");
      Check_Codec
        (Encoded => perform_forced_recalibration_Response_Encoded,
         Decoded => perform_forced_recalibration_Response_Decoded,
         Name    => "Perform Forced Recalibration Response");
      Check_Codec
        (Encoded => set_automatic_self_calibration_enabled_Input_Encoded,
         Decoded => set_automatic_self_calibration_enabled_Input_Decoded,
         Name    => "Set Automatic Self-Calibration Enabled");
      Check_Codec
        (Encoded => get_automatic_self_calibration_enabled_Response_Encoded,
         Decoded => get_automatic_self_calibration_enabled_Response_Decoded,
         Name    => "Get Automatic Self-Calibration Enabled");
      Check_Codec
        (Encoded => set_automatic_self_calibration_target_Input_Encoded,
         Decoded => set_automatic_self_calibration_target_Input_Decoded,
         Name    => "Set Automatic Self-Calibration Target");
      Check_Codec
        (Encoded => get_automatic_self_calibration_target_Response_Encoded,
         Decoded => get_automatic_self_calibration_target_Response_Decoded,
         Name    => "Get Automatic Self-Calibration Target");
      Check_Codec
        (Encoded => get_data_ready_status_Response_Encoded,
         Decoded => get_data_ready_status_Response_Decoded,
         Name    => "Get Data Ready Status");
      Check_Codec
        (Encoded => get_serial_number_Response_Encoded,
         Decoded => get_serial_number_Response_Decoded,
         Name    => "Get Serial Number");
      Check_Codec
        (Encoded => get_sensor_variant_SCD40_Response_Encoded,
         Decoded => get_sensor_variant_SCD40_Response_Decoded,
         Name    => "Get Sensor Variant SCD40");
      Check_Codec
        (Encoded => get_sensor_variant_SCD41_Response_Encoded,
         Decoded => get_sensor_variant_SCD41_Response_Decoded,
         Name    => "Get Sensor Variant SCD41");
      Check_Codec
        (Encoded => get_sensor_variant_SCD43_Response_Encoded,
         Decoded => get_sensor_variant_SCD43_Response_Decoded,
         Name    => "Get Sensor Variant SCD43");
      Check_Codec
        (Encoded =>
           set_automatic_self_calibration_initial_period_Input_Encoded,
         Decoded =>
           set_automatic_self_calibration_initial_period_Input_Decoded,
         Name    => "Set Automatic Self-Calibration Initial Period");
      Check_Codec
        (Encoded =>
           set_automatic_self_calibration_standard_period_Input_Encoded,
         Decoded =>
           set_automatic_self_calibration_standard_period_Input_Decoded,
         Name    => "Set Automatic Self-Calibration Standard Period");
   end Test_SCD4x;

begin
   Test_SCD4x;
end Selftest;
