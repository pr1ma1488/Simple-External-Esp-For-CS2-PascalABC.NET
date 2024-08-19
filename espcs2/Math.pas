unit Math;
uses System, System.Numerics, MemoryClass;

type Calc = class
  public static function WorldToScreen(matrix:array of single; pos:vector3; windowSize:vector2):Vector2;
  begin
    var screenW := (matrix[12] * pos.X) + (matrix[13] * pos.Y) + (matrix[14] * pos.Z) + matrix[15];
    
    if screenW > single(0.001) then begin
      var screenX := (matrix[0] * pos.X) + (matrix[1] * pos.Y) + (matrix[2] * pos.Z) + matrix[3];
      var screenY := (matrix[4] * pos.X) + (matrix[5] * pos.Y) + (matrix[6] * pos.Z) + matrix[7];
      
      var X := (windowSize.X / 2) + (windowSize.X / 2) * screenX / screenW;
      var Y := (windowSize.Y / 2) - (windowSize.Y / 2) * screenY / screenW;
      
      result := new Vector2(X,Y);
    end
    else
      result := new Vector2(-99,-99);
  end;
  
  public static function ReadMatrix(address:IntPtr):array of single;
  begin
    var bytes := Memory.ReadBytes(address, 4 * 16);
    var matrix := new single[bytes.Length];

    matrix[0] := BitConverter.ToSingle(bytes, 0 * 4);
    matrix[1] := BitConverter.ToSingle(bytes, 1 * 4);
    matrix[2] := BitConverter.ToSingle(bytes, 2 * 4);
    matrix[3] := BitConverter.ToSingle(bytes, 3 * 4);

    matrix[4] := BitConverter.ToSingle(bytes, 4 * 4);
    matrix[5] := BitConverter.ToSingle(bytes, 5 * 4);
    matrix[6] := BitConverter.ToSingle(bytes, 6 * 4);
    matrix[7] := BitConverter.ToSingle(bytes, 7 * 4);

    matrix[8] := BitConverter.ToSingle(bytes, 8 * 4);
    matrix[9] := BitConverter.ToSingle(bytes, 9 * 4);
    matrix[10] := BitConverter.ToSingle(bytes, 10 * 4);
    matrix[11] := BitConverter.ToSingle(bytes, 11 * 4);

    matrix[12] := BitConverter.ToSingle(bytes, 12 * 4);
    matrix[13] := BitConverter.ToSingle(bytes, 13 * 4);
    matrix[14] := BitConverter.ToSingle(bytes, 14 * 4);
    matrix[15] := BitConverter.ToSingle(bytes, 15 * 4);

    result := matrix;
  end;
end;

end.
