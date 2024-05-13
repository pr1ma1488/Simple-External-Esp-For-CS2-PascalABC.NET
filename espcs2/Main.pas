uses Overlay, EntityLoopClass;

type MainClass = class
  public static procedure Init();
  begin
    ExternalOverlay.Init();
    EntityLoop.Init();
  end;
end;

begin
  MainClass.Init();
end.