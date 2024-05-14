unit EntityLoopClass;
uses System, System.Numerics, System.Threading, Overlay, MemoryClass, EntityClass, Offsets, Math;

var DrawOnTeammates:boolean := false; // can be changed

type EntityLoop = class
  public static procedure Init();
  begin
    var Renderer := new MainRenderer;
    var screensize := Renderer.Screensize;
    
    var entities := new List&<Entity>();
    var localPlayer := new Entity;

    var client := system.Diagnostics.Process.GetProcessesByName('cs2')[0].Modules[144].BaseAddress;
    
    var main_thread := new Thread(procedure -> begin while true do begin
    entities.Clear;
    
    var entityList:intptr := Memory.Read&<intptr>(client + Offset.dwEntityList);
    
    var listEntry := Memory.Read&<intptr>(entitylist + $10);
    
    var localPlayerPawn := Memory.Read&<intptr>(client + Offset.dwLocalPlayerPawn);
    
    localPlayer.team := Memory.Read&<integer>(localPlayerPawn + Offset.m_iTeamNum);
    
    Renderer.Draw;
    
    for var i := 0 to 63 do begin
      if listEntry = intptr.Zero then continue;
      
      var currentController := Memory.Read&<intptr>(listEntry + i * $78);
      if currentController = intptr.Zero then continue;
      
      var pawnHandle := Memory.Read&<integer>(currentController + Offset.m_hPlayerPawn);
      if pawnHandle = 0 then continue;
      
      var listEntry2 := Memory.Read&<intptr>(entityList + $8 * ((pawnHandle and $7FFF) shr 9) + $10);
      if listEntry2 = intptr.Zero then continue;
      
      var currentPawn := Memory.Read&<intptr>(listEntry2 + $78 * (pawnHandle and $1FF));
      if currentPawn = intptr.Zero then continue;
      
      var lifeState := Memory.Read&<integer>(currentPawn + Offset.m_lifeState);
      if lifestate <> 256 then continue;
      
      var viewMatrix := Calc.ReadMatrix(client + Offset.dwViewMatrix);
      var _entity := new Entity;

      _entity.team := Memory.Read&<integer>(currentPawn + Offset.m_iTeamNum);
      _entity.position := Memory.Read&<Vector3>(currentPawn + Offset.m_vOldOrigin);
      _entity.viewOffset := Memory.Read&<Vector3>(currentPawn + Offset.m_vecViewOffset);
      _entity.Position2D := Calc.WorldToScreen(viewMatrix, _entity.position, screenSize);
      _entity.viewPosition2D := Calc.WorldToScreen(viewMatrix, Vector3.Add(_entity.position, _entity.viewOffset), screenSize);
      
      if DrawOnTeammates then begin
        if (currentPawn <> localPlayerPawn) then
          entities.Add(_entity)
      end
      else begin
        if (currentPawn <> localPlayerPawn) and (_entity.team <> localPlayer.team) then
          entities.Add(_entity)
      end;
    end;
    Renderer.UpdateLocalPlayer(localPlayer);
    Renderer.UpdateEntities(entities);
  end;
  end);
  main_thread.Start;
  end;
end;

end.
