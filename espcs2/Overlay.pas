{$reference System.Drawing.dll}
{$reference System.Windows.Forms.dll}
unit Overlay;
uses System, System.Collections.Concurrent, System.Numerics, GraphABC, System.Windows.Forms, EntityClass;

type ExternalOverlay = class
  protected static function SetWindowLong(hWnd:intptr; nIndex:integer; dwNewLong:int64):int64;
  external 'user32.dll';

  protected static function GetWindowLong(hWnd:intptr; nIndex:integer): int64;
  external 'user32.dll';
  
  public static procedure Init();
  begin
    setsmoothingoff;
    setwindowtitle('Overlay');
    mainform.TransparencyKey := mainform.BackColor;
    mainform.FormBorderStyle := formborderstyle.None;
    setwindowsize(screen.PrimaryScreen.Bounds.Width, screen.PrimaryScreen.Bounds.Height);
    centerwindow;
    maximizewindow;
    mainform.TopMost := true;
    mainform.ShowIcon := false;
    var initstyle := GetWindowLong(mainform.Handle, -20);
    setwindowlong(mainform.Handle, -20, initstyle or $8000 or $20);
    
    // shitty method to draw text on transparent overlay normally. fully crap cuz DrawString "1" on -10 -10 )))))))
    {var gr := MainForm.CreateGraphics;
    gr.TextRenderingHint := System.Drawing.Text.TextRenderingHint.SingleBitPerPixel;
    gr.DrawString('1', mainform.Font, new SolidBrush(Color.Black), -10, -10);}
  end;
end;

type MainRenderer = class
  private entities:concurrentqueue<entity> := new ConcurrentQueue&<entity>();
  private localPlayer:Entity := new Entity();
  private entitylock := new object();
  
  private boxColor := clRed;
  
  public screensize := new Vector2(SystemInformation.PrimaryMonitorSize.Width, SystemInformation.PrimaryMonitorSize.Height);
  
  private procedure DoRender();
  begin
    foreach var Entity in entities do begin
      if IsOnScreen(entity) then begin
        DrawBox(entity);
      end;
    end;
  end;
  
  private function IsOnScreen(entity:Entity):boolean;
  begin
    if (entity.position2D.X > 0) and (entity.position2D.X < screensize.X) and (entity.position2D.Y > 0) and (entity.position2D.Y < screensize.Y) then
      result := true;
  end;
  
  private procedure DrawBox(entity:Entity);
  begin
    var entityHeight:single := entity.viewPosition2D.Y - entity.position2D.Y;
    var entityWidth:single := (entityHeight / 2) * 1.3;
    
    var rectTop:Vector2 := new Vector2(entity.viewPosition2D.X - (entityWidth / 2), entity.position2D.Y - (entityHeight / 8) + 1);
    var rectBottom:Vector2 := new Vector2(entity.position2D.X - (entityWidth / 2) + entityWidth, entity.position2D.Y + entityHeight + (entityHeight / 8));
    
    setpencolor(boxColor);
    GraphABC.DrawRectangle(integer(rectTop.X), integer(rectTop.Y), integer(rectBottom.X), integer(rectBottom.Y));
  end;
  
  public procedure UpdateEntities(newEntities:IEnumerable<Entity>);
  begin
    entities := new ConcurrentQueue&<Entity>(newEntities);
  end;
  
  public procedure UpdateLocalPlayer(newEntity:entity);
  begin
    lock (entitylock) do begin
      localplayer := newEntity;
    end;
  end;
  
  public function GetLocalPlayer():Entity;
  begin
    lock (entitylock) do begin
      result := localplayer;
    end;
  end;
  
  public procedure Draw();
  begin
    clearwindow;
    lockdrawing;
    DoRender;
    redraw;
  end;
end;

end.