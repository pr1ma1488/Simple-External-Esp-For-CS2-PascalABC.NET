unit EntityClass;
uses System.Numerics;

type Entity = class
  public position:vector3;
  public viewOffset:vector3;
  public position2D:vector2;
  public viewPosition2D:vector2;
  public team:integer;
end;

end.