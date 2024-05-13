{$reference NativeManager.dll}
unit MemoryClass;

var Memory := new System.MemoryInteractions.MemoryManager(system.Diagnostics.Process.GetProcessesByName('cs2')[0]);

end.